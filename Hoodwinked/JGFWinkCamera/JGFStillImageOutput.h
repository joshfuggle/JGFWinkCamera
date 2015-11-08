//
//  JGFStillImageOutput.h
//  JGFWinkCamera
//
//  Created by Joshua Fuglsang on 7/11/2015.
//  Copyright © 2015 Joshua Fuglsang. All rights reserved.
//

@import AVFoundation;

#import "JGFCaptureOutput.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^JGFStillImageCaptureBlock)(UIImage * __nullable image, NSError * __nullable error);

/**
 Class that be used to capture still images from a JGFSessionController object.
 */
@interface JGFStillImageOutput : NSObject <JGFCaptureOutput>

/**
 Creates a new still image output instance.
 */
+ (instancetype)stillOutput;

/**
 Designated initializer.
 */
- (instancetype)initWithStillImageOutput:(AVCaptureStillImageOutput *)stillImageOutput;

#pragma mark - Capture

/**
 Trigger the shutter to take a still photo asynchronously. You will be notified of completion on the callback block.
 */
- (void)captureStillImage:(JGFStillImageCaptureBlock)block;

@end

NS_ASSUME_NONNULL_END
