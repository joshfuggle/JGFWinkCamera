//
//  JGFSessionController.m
//  JGFWinkCamera
//
//  Created by Joshua Fuglsang on 5/11/2015.
//  Copyright © 2015 Joshua Fuglsang. All rights reserved.
//

#import "JGFSessionController.h"

#import "JGFCaptureDevice.h"

@implementation JGFSessionController

#pragma mark - Setup

+ (__nonnull instancetype)sessionController
{
    return [[self alloc] initWithSession:[self _makeCaptureSession]];
}

- (__nonnull instancetype)initWithSession:(AVCaptureSession * _Nonnull)session
{
    if ( self = [super init] )
    {
        self->_captureSession = session;
    }
    return self;
}

+ (AVCaptureSession * _Nullable)_makeCaptureSession
{
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetHigh;
    return session;
}

#pragma mark - Inputs

- (BOOL)addInput:(JGFCaptureDevice * _Nonnull)device
{
    if ( [self.captureSession canAddInput:device.deviceInput] )
    {
        [self.captureSession addInput:device.deviceInput];
        return YES;
    }
    return NO;
}

#pragma mark - Outputs

- (BOOL)addOutput:(id <JGFCaptureOutput>)output
{
    if ( [self.captureSession canAddOutput:[output captureOutput]] )
    {
        [self.captureSession addOutput:[output captureOutput]];
        return YES;
    }
    return NO;
}

#pragma mark - Start and Stop Running

- (void)start
{
    if ( ! [self.captureSession isRunning] )
    {
        [self.captureSession startRunning];
    }
}

- (void)stop
{
    if ( [self.captureSession isRunning] )
    {
        [self.captureSession stopRunning];
    }
}

@end
