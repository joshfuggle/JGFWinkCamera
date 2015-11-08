//
//  JGFVideoCaptureDevice.m
//  JGFWinkCamera
//
//  Created by Joshua Fuglsang on 5/11/2015.
//  Copyright © 2015 Joshua Fuglsang. All rights reserved.
//

#import "JGFCaptureDevice.h"

@implementation JGFCaptureDevice

#pragma mark - Setup

+ (__nullable instancetype)captureDeviceWithMediaType:(NSString * _Nonnull)mediaType preferredPosition:(AVCaptureDevicePosition)position
{
    AVCaptureDevice *device = [self _makeDeviceWithMediaType:mediaType preferredPosition:position];
    AVCaptureDeviceInput *input = [self _makeVideoDeviceInputWithDevice:device];
    
    if ( ( device != nil ) && ( input != nil ) )
    {
        return [[self alloc] initWithCaptureDevice:device deviceInput:input];
    }
    
    NSLog(@"Failed to create video capture device with position: %ld", (long)position);
    
    return nil;
}

- (__nonnull instancetype)initWithCaptureDevice:(AVCaptureDevice * _Nonnull)captureDevice deviceInput:(AVCaptureDeviceInput * _Nonnull)deviceInput
{
    if ( self = [super init] )
    {
        self->_device = captureDevice;
        self->_deviceInput = deviceInput;
    }
    return self;
}

#pragma mark - Helpers

+ (AVCaptureDevice * _Nullable)_makeDeviceWithMediaType:(NSString *)mediaType preferredPosition:(AVCaptureDevicePosition)position
{
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:mediaType])
    {
        if ( device.position == position )
        {
            return device;
        }
    }
    
    NSLog(@"Could not find device for requested position. Falling back to default.");
    
    return [AVCaptureDevice defaultDeviceWithMediaType:mediaType];
}

+ (AVCaptureDeviceInput * _Nullable)_makeVideoDeviceInputWithDevice:(AVCaptureDevice * _Nullable)device
{
    if ( device == nil )
    {
        return nil;
    }
    
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if ( error != NULL )
    {
        NSLog(@"Encountered issue when constructing device input: %@", error);
    }
    
    return input;
}

@end
