//
//  JGFVideoCaptureDevice.h
//  JGFWinkCamera
//
//  Created by Joshua Fuglsang on 5/11/2015.
//  Copyright © 2015 Joshua Fuglsang. All rights reserved.
//

@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

/** 
 Class used to initialize and configure a capture device and a capture input. These objects can be plugged in to a JGFSessionController object.
 */
@interface JGFCaptureDevice : NSObject

#pragma mark - Setup

/**
 Attempts to construct a capture device of the given type and preferred position. 
 @discussion If no device can be found with the preferredPosition, then the default device will be used.
 */
+ (__nullable instancetype)captureDeviceWithMediaType:(NSString *)mediaType preferredPosition:(AVCaptureDevicePosition)position;

/**
 Init with a previously created capture device and capture device input. Neither parameter can be nil.
 */
- (instancetype)initWithCaptureDevice:(AVCaptureDevice *)captureDevice deviceInput:(AVCaptureDeviceInput *)deviceInput;

#pragma mark - Device

/**
 A capture device.
 */
@property (nonatomic, strong, readonly) AVCaptureDevice *device;

/**
 A capture device input.
 */
@property (nonatomic, strong, readonly) AVCaptureDeviceInput *deviceInput;

@end

NS_ASSUME_NONNULL_END
