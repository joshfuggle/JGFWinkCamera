# About

JGFWinkCamera is an iOS camera framework that will take a photo when you wink.

This is a fun example of the power of AVFoundation.

To use in your own app you need to create an instance of JGFWinkController, then you need to make that instance a child of one of your own view controllers.
JGFWinkCamera doesn't come with any UI for capturing photos, you need to build that yourself. However, I believe that that is part of the flexibility of this project. You can create whatever UI you want.

![Example](https://raw.githubusercontent.com/josh-fuggle/JGFWinkCamera/master/demo.gif)

# Sample usage

    JGFWinkCamera *camera = [JGFWinkCamera cameraWithDelegate:self];

    if ( camera != nil )
    {
        [self addChildViewController:camera];

        camera.view.translatesAutoresizingMaskIntoConstraints = NO;

        [self.view addSubview:camera.view];

        NSDictionary *views = @{ @"camera" : camera.view };

        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[camera]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[camera]|" options:0 metrics:nil views:views]];

        [self.view addSubview:camera.view];

        [camera didMoveToParentViewController:self];
    }

JGFWinkCamera will let you know when key events have occurred:

    #pragma mark - JGFCameraDelegate

    // Callback designed for you to provide feedback of an impending photo capture to your users.
    - (void)camera:(JGFWinkCamera *)camera willShutterIn:(NSTimeInterval)time
    {
        if ( time > 0 )
        {
            [self _animateRemainingTime:time animationDuration:camera.feedbackIntervalWhileWaitingForShutter];
        }
        else
        {
            [self _animateShutter];
        }
    }

    // Called when a photo is captured. This is your chance to save the photo.
    - (void)camera:(JGFWinkCamera *)camera didCapturePhoto:(UIImage *)photo
    {
        [self.lastCapture setImage:photo];
    }
