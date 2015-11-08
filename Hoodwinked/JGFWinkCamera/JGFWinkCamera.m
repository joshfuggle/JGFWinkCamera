//
//  JGFWinkCamera.m
//  JGFWinkCamera
//
//  Created by Joshua Fuglsang on 4/11/2015.
//  Copyright © 2015 Joshua Fuglsang. All rights reserved.
//

#import "JGFWinkCamera.h"

#import "JGFSessionController.h"
#import "JGFCaptureDevice.h"
#import "JGFWinkDetector.h"
#import "JGFStillImageOutput.h"

NSTimeInterval JGFCameraDefaultPauseBeforeShutterInterval = 2.0f;
NSTimeInterval JGFCameraDefaultFeedbackIntervalWhileWaitingForShutter = 1.0f;
NSTimeInterval JGFCameraDefaultMinimumWinkDurationForAutomaticTrigger = 0.3f; // By trial and error, I found this to be a pretty good value.

@interface JGFWinkCamera () <JGFWinkDetectorDelegate>

@property (nonatomic, strong) JGFSessionController *sessionController;
@property (nonatomic, strong) JGFCaptureDevice *captureDevice;
@property (nonatomic, strong) JGFWinkDetector *winkDetector;
@property (nonatomic, strong) JGFStillImageOutput *stillImageOutput;

#pragma mark - Timer Management

@property (nonatomic, strong) NSTimer *shutterTimer;
@property (nonatomic, assign) NSTimeInterval cummulativeTimeInterval;

@end

@implementation JGFWinkCamera

#pragma mark - Setup

+ (__nullable instancetype)cameraWithDelegate:(id <JGFCameraDelegate> _Nullable)delegate
{
    JGFSessionController *session = [JGFSessionController sessionController];
    
    JGFCaptureDevice *device = [JGFCaptureDevice captureDeviceWithMediaType:AVMediaTypeVideo preferredPosition:AVCaptureDevicePositionFront];
    if ( ! [session addInput:device] )
    {
        return nil;
    }
    
    JGFWinkDetector *winkDetector = [JGFWinkDetector winkDetector];
    if ( ! [session addOutput:winkDetector] )
    {
        return nil;
    }
    
    JGFStillImageOutput *stillImageOutput = [JGFStillImageOutput stillOutput];
    if ( ! [session addOutput:stillImageOutput] )
    {
        return nil;
    }
    
    return [[self alloc] initWithSession:session device:device winkDetector:winkDetector stillImageOutput:stillImageOutput delegate:delegate];
}

- (__nonnull instancetype)initWithSession:(JGFSessionController * _Nonnull)session
                                   device:(JGFCaptureDevice * _Nonnull)device
                             winkDetector:(JGFWinkDetector * _Nonnull)detector
                         stillImageOutput:(JGFStillImageOutput * _Nonnull)stillImageOutput
                                 delegate:(id <JGFCameraDelegate> _Nullable)delegate
{
    if ( self = [super init] )
    {
        self->_delegate = delegate;
        
        self->_feedbackIntervalWhileWaitingForShutter = JGFCameraDefaultFeedbackIntervalWhileWaitingForShutter;
        self->_pauseAfterWinkDetectionBeforeShutter = JGFCameraDefaultPauseBeforeShutterInterval;
        self->_minimumWinkDurationForAutomaticTrigger = JGFCameraDefaultMinimumWinkDurationForAutomaticTrigger;
        
        self->_sessionController = session;
        self->_captureDevice = device;
        self->_stillImageOutput = stillImageOutput;
        
        detector.delegate = self;
        detector.minimumWinkDurationForAutomaticTrigger = self.minimumWinkDurationForAutomaticTrigger;
        self->_winkDetector = detector;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.sessionController start];
    
    // Add in the preview layer
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.sessionController.captureSession];
    previewLayer.frame = self.view.layer.bounds;
    [self.view.layer addSublayer:previewLayer];
}

#pragma mark - JGFWinkDetectorDelegate

- (void)winkDetectorDetectedWink:(JGFWinkDetector *)detector
{
    [self _scheduleShutterTimer];
}

- (void)_scheduleShutterTimer
{
    NSLog(@"Confirmed wink count passed accuracy threshold!");
    
    // Test if a timer is already in progress.
    if ( self.shutterTimer != nil )
    {
        return;
    }
    
    [self _notifyDelegateOfImpendingShutter:self.pauseAfterWinkDetectionBeforeShutter];
    
    // Begin the timer.
    NSTimer *timer = [NSTimer timerWithTimeInterval:self.feedbackIntervalWhileWaitingForShutter target:self selector:@selector(_shutterIntervalLapsed:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.shutterTimer = timer;
}

- (void)_shutterIntervalLapsed:(NSTimer *)timer
{
    self.cummulativeTimeInterval += timer.timeInterval;
    
    NSTimeInterval timeUntilShutter = ( self.pauseAfterWinkDetectionBeforeShutter - self.cummulativeTimeInterval );
    [self _notifyDelegateOfImpendingShutter:timeUntilShutter];
    
    [self _testForAutomaticShutterAndFireIfAppropriate];
}

- (void)_notifyDelegateOfImpendingShutter:(NSTimeInterval)timeUntilShutter
{
    if ( [self.delegate respondsToSelector:@selector(camera:willShutterIn:)] )
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate camera:self willShutterIn:timeUntilShutter];
        });
    }
}

- (void)_testForAutomaticShutterAndFireIfAppropriate
{
    if ( self.cummulativeTimeInterval >= self.pauseAfterWinkDetectionBeforeShutter )
    {
        [self.shutterTimer invalidate];
        self.shutterTimer = nil;
        self.cummulativeTimeInterval = 0;
        
        __weak typeof (self) weakSelf = self;
        
        [self.stillImageOutput captureStillImage:^(UIImage * _Nullable image, NSError * _Nullable error) {
            
            if ( error != nil )
            {
                NSLog(@"Failed to capture image. Error: %@", error);
            }
            else if ( ( image != nil ) && [weakSelf.delegate respondsToSelector:@selector(camera:didCapturePhoto:)] )
            {
                __strong typeof (weakSelf) strongSelf = weakSelf;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.delegate camera:strongSelf didCapturePhoto:image];
                });
            }
            
        }];
    }
}

@end
