//
//  JGFStillImageOutput.h
//  JGFWinkCamera
//
//  Created by Joshua Fuglsang on 7/11/2015.
//  Copyright © 2015 Joshua Fuglsang. All rights reserved.
//

#import "JGFStillImageOutput.h"

@import UIKit;

@interface JGFStillImageOutput ()
@property (nonatomic, strong) AVCaptureStillImageOutput *captureOutput;
@end


@implementation JGFStillImageOutput

#pragma mark - Setup

+ (_Nonnull instancetype)stillOutput
{
    return [[self alloc] initWithStillImageOutput:[self _makeStillImageOutput]];
}

- (_Nonnull instancetype)initWithStillImageOutput:(AVCaptureStillImageOutput * __nonnull)stillImageOutput
{
    if ( self = [super init] )
    {
        self->_captureOutput = stillImageOutput;
    }
    return self;
}

+ (AVCaptureStillImageOutput * __nonnull)_makeStillImageOutput
{
    AVCaptureStillImageOutput *output = [[AVCaptureStillImageOutput alloc] init];
    output.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
    return output;
}

#pragma mark - Capture

- (void)captureStillImage:(JGFStillImageCaptureBlock)block
{
    if ( block == NULL )
    {
        return;
    }
    
    AVCaptureConnection *connection = [self.captureOutput connectionWithMediaType:AVMediaTypeVideo];
    
    // Respect the orientation at which the user is holding the device, so that the images are output
    // the correct way.
    if ( [connection isVideoOrientationSupported] )
    {
        connection.videoOrientation = [self _currentVideoOrientation];
    }
    
    [self.captureOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        if ( error == nil )
        {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            
            block( image, nil );
        }
        else
        {
            block( nil, error );
        }
        
    }];
}

- (AVCaptureVideoOrientation)_currentVideoOrientation
{
    switch ([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
            
        case UIDeviceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
            
        case UIDeviceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
            
        case UIDeviceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
            
        default:
            return AVCaptureVideoOrientationPortrait;
    }
}

@end
