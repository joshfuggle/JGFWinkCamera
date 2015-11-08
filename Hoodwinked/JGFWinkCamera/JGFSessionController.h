//
//  JGFSessionController.h
//  JGFWinkCamera
//
//  Created by Joshua Fuglsang on 5/11/2015.
//  Copyright © 2015 Joshua Fuglsang. All rights reserved.
//

@import AVFoundation;

#import "JGFCaptureOutput.h"

@class JGFCaptureDevice;

NS_ASSUME_NONNULL_BEGIN

/** 
 Class that is used for coordinating AVCaptureSession objects. 
 */
@interface JGFSessionController : NSObject

#pragma mark - Setup

/**
 Constructs a new session controller.
 */
+ (instancetype)sessionController;

/**
 Returns a new session controller using the provided capture session. The sessionController constructor calls this method internally.
 */
- (instancetype)initWithSession:(AVCaptureSession *)session;

/**
 Capture session associated with the session controller.
 */
@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;

#pragma mark - Inputs

/** 
 Adds a device to the session if able to. Else we return with a NO result. 
 */
- (BOOL)addInput:(JGFCaptureDevice *)device;

#pragma mark - Outputs

/**
 Adds an output to the session if able to. Else we return with a NO result.
 */
- (BOOL)addOutput:(id <JGFCaptureOutput>)output;

#pragma mark - Start and Stop Running

/** 
 Start running. 
 */
- (void)start;

/** 
 Stop running. 
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
