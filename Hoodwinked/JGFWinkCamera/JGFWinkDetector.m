//
//  JGFFacialFeaturesDetector.m
//  JGFWinkCamera
//
//  Created by Joshua Fuglsang on 6/11/2015.
//  Copyright © 2015 Joshua Fuglsang. All rights reserved.
//

#import "JGFWinkDetector.h"

@import CoreImage;

@interface JGFWinkDetector () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong, readonly) AVCaptureVideoDataOutput *captureOutput;

/** A queue for us to perform expensive, blocking operations on. */
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

@property (nonatomic, strong) NSDate *startedDetectingWinkDate;

@end

@implementation JGFWinkDetector

#pragma mark - Setup

+ (__nonnull instancetype)winkDetector
{
    return [[self alloc] initWithVideoDataOutput:[self _makeVideoDataOutput]];
}

- (__nonnull instancetype)initWithVideoDataOutput:(AVCaptureVideoDataOutput * _Nonnull)output
{
    if ( self = [super init] )
    {
        self->_captureOutput = output;
        self->_dispatchQueue = dispatch_queue_create("coffee.josh.VideoOutputQueue", NULL);
        [output setSampleBufferDelegate:self queue:self.dispatchQueue];
    }
    return self;
}

+ (AVCaptureVideoDataOutput * _Nonnull)_makeVideoDataOutput
{
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    
    output.videoSettings = @{ ( id ) kCVPixelBufferPixelFormatTypeKey : @( kCVPixelFormatType_32BGRA ) };
    output.alwaysDiscardsLateVideoFrames = YES;
    
    return output;
}

#pragma mark - JGFLiveFrameOutputDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *image = [CIImage imageWithCVImageBuffer:imageBuffer];
    
    NSDictionary *options = @{ CIDetectorImageOrientation : @6, CIDetectorEyeBlink : @YES, CIDetectorSmile : @YES };
    NSArray *features = [detector featuresInImage:image options:options];
    
    BOOL foundWink = NO;
    
    for ( CIFaceFeature *feature in features )
    {
        BOOL leftEyeFound = [feature hasLeftEyePosition];
        BOOL rightEyeFound = [feature hasRightEyePosition];
        
        // No eyes in the frame
        if ( ! leftEyeFound && ! rightEyeFound )
        {
            continue;
        }
        
        BOOL leftEyeClosed = [feature leftEyeClosed];
        BOOL rightEyeClosed = [feature rightEyeClosed];
        
        // Both eyes are open
        if ( ! leftEyeClosed && ! rightEyeClosed )
        {
            continue;
        }
        
        // Both eyes are closed, that's a blink!
        if ( leftEyeClosed && rightEyeClosed )
        {
            continue;
        }
        
        foundWink = YES;
    }
    
    if ( foundWink )
    {
        if ( self.startedDetectingWinkDate == nil )
        {
            self.startedDetectingWinkDate = [NSDate date];
        }
        
        NSDate *now = [NSDate date];
        NSTimeInterval timeDifference = [now timeIntervalSinceDate:self.startedDetectingWinkDate];
        
        NSLog(@"Time difference: %f", timeDifference);
        
        if ( timeDifference >= self.minimumWinkDurationForAutomaticTrigger )
        {
            self.startedDetectingWinkDate = nil; // Wink successfully passed minimum duration. Clear so we don't fire the callback again.
            
            if ( [self.delegate respondsToSelector:@selector(winkDetectorDetectedWink:)] )
            {
                [self.delegate winkDetectorDetectedWink:self];
            }
        }
    }
    else
    {
        self.startedDetectingWinkDate = nil; // Not a wink, restart the detection date.
        
        if ( [self.delegate respondsToSelector:@selector(winkDetectorFailedToDetectWink:)] )
        {
            [self.delegate winkDetectorFailedToDetectWink:self];
        }
    }
}

@end
