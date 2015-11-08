//
//  JGFFacialFeaturesDetector.h
//  JGFWinkCamera
//
//  Created by Joshua Fuglsang on 6/11/2015.
//  Copyright © 2015 Joshua Fuglsang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JGFCaptureOutput.h"

NS_ASSUME_NONNULL_BEGIN

@class JGFWinkDetector;

/**
 Defines an interface for you to be notified of detected winks.
 */
@protocol JGFWinkDetectorDelegate <NSObject>

@required;

/**
 Called when a frame is successfully processed, and it contains a wink!
 */
- (void)winkDetectorDetectedWink:(JGFWinkDetector *)detector;

@optional;

/**
 Called when a frame is successfully processed, but it contains no winks.
 */
- (void)winkDetectorFailedToDetectWink:(JGFWinkDetector *)detector;

@end

/**
 Class that can be used to detect winks.
 Works by attaching to a JGFSessionController and consuming capture output data.
 */
@interface JGFWinkDetector : NSObject <JGFCaptureOutput>

/**
 Convenience method for creating a new wink detector class.
 Sets up its own AVCaptureVideoDataOutput instance.
 */
+ (instancetype)winkDetector;

/**
 Designated initializer. Create a wink detector with a VideoDataOutput object.
 */
- (instancetype)initWithVideoDataOutput:(AVCaptureVideoDataOutput *)output;

/**
 Assign yourself as a delegate of this class to be notified when a wink is detected.
 */
@property (nonatomic, weak) id <JGFWinkDetectorDelegate> delegate;

/**
 The minimum amount of time that needs to pass for a wink to be detected. Setting this value can reduce the chance of false-positive results.
 */
@property (nonatomic, assign) NSTimeInterval minimumWinkDurationForAutomaticTrigger;

@end

NS_ASSUME_NONNULL_END
