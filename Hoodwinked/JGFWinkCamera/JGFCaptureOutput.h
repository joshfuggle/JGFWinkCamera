//
//  JGFCaptureOutput.h
//  JGFWinkCamera
//
//  Created by Joshua Fuglsang on 6/11/2015.
//  Copyright © 2015 Joshua Fuglsang. All rights reserved.
//

#pragma once

@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

/**
 If you want to be added as a capture output to a session controller, then you must conform to this protocol.
 */
@protocol JGFCaptureOutput <NSObject>

/**
 The object to be added to an AVCaptureSession instance as an output.
 */
- (AVCaptureOutput *)captureOutput;

@end

NS_ASSUME_NONNULL_END
