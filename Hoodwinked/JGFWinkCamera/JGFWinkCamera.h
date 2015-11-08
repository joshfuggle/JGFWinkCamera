//
//  JGFWinkCamera.h
//  JGFWinkCamera
//
//  Created by Joshua Fuglsang on 4/11/2015.
//  Copyright © 2015 Joshua Fuglsang. All rights reserved.
//

@import UIKit;

@class JGFWinkCamera;

/**
 Default delay between recognizing a wink and triggering the shutter.
 */
extern NSTimeInterval JGFCameraDefaultPauseBeforeShutterInterval; // 2.0f

/**
 The default rate at which the delegate will be notified about an impending shutter.
 */
extern NSTimeInterval JGFCameraDefaultFeedbackIntervalWhileWaitingForShutter; // 1.0f

/**
 The default duration for the minimumWinkDurationForAutomaticTrigger property.
 */
extern NSTimeInterval JGFCameraDefaultMinimumWinkDurationForAutomaticTrigger; // 0.3f

NS_ASSUME_NONNULL_BEGIN

/**
 Delegate protocol for receiving updates from the camera.
 */
@protocol JGFCameraDelegate <NSObject>

@optional;

/**
 Once it is determined that the shutter will be automatically triggered, we begin a count down and will let the delegate know
 periodically when the event will occur.
 */
- (void)camera:(JGFWinkCamera *)camera willShutterIn:(NSTimeInterval)time;

/**
 When a still image is captured, the delegate will be notified via this callback.
 */
- (void)camera:(JGFWinkCamera *)camera didCapturePhoto:(UIImage *)photo;

@end

/**
 Key controller class for presenting a camera. You can add instances of this as a child to one of your own view controllers.
 This view controller doesn't come with any UI for capturing photos, you need to build that yourself. This class feeds data from your capture device
 in its own viewfinder layer.
 */
@interface JGFWinkCamera : UIViewController

#pragma mark - Setup

/**
 Create a new wink camera instance. Returns nil if for some reason the input device could not be discovered.
 */
+ (__nullable instancetype)cameraWithDelegate:(id <JGFCameraDelegate> _Nullable)delegate;

/**
 Set the delegate to be notified of key events.
 */
@property (nonatomic, weak) id <JGFCameraDelegate> delegate;

#pragma mark - Configuration

/**
 After the camera decides to automatically shutter, there is a period of time before the shutter will be triggered. 
 */
@property (nonatomic, assign) NSTimeInterval pauseAfterWinkDetectionBeforeShutter;

/**
 After the camera decides to automatically shutter, we will begin notifying the delegate that a shutter is about to happen.
 Setting this flag will control that rate at which we will notify you. This is useful for presenting a count down to the user.
 */
@property (nonatomic, assign) NSTimeInterval feedbackIntervalWhileWaitingForShutter;

/** 
 The minimum amount of time that needs to pass for a wink to be detected. Setting this value can reduce the chance of false-positive results.
 */
@property (nonatomic, assign) NSTimeInterval minimumWinkDurationForAutomaticTrigger;

@end

NS_ASSUME_NONNULL_END
