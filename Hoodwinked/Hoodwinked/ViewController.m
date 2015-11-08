//
//  ViewController.m
//  Hoodwinked
//
//  Created by Joshua Fuglsang on 4/11/2015.
//  Copyright © 2015 Joshua Fuglsang. All rights reserved.
//

#import "ViewController.h"

@import JGFWinkCamera;
@import CoreText;

@interface ViewController () <JGFCameraDelegate>
@property (nonatomic, weak) UIImageView *lastCapture;
@end

@implementation ViewController

#pragma mark - Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _setupCamera];
    [self _setupImageView];
}

- (void)_setupCamera
{
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
}

- (void)_setupImageView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:imageView];
    
    NSDictionary *views = @{ @"imageView" : imageView };
    NSDictionary *metrics = @{ @"size" : @70, @"padding" : @20 };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView(size)]-(padding)-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView(size)]-(padding)-|" options:0 metrics:metrics views:views]];
    
    self.lastCapture = imageView;
}

#pragma mark - JGFCameraDelegate

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

- (void)camera:(JGFWinkCamera *)camera didCapturePhoto:(UIImage *)photo
{
    [self.lastCapture setImage:photo];
}

#pragma mark - Animations

- (void)_animateRemainingTime:(NSTimeInterval)timeInterval animationDuration:(NSTimeInterval)animationDuration
{
    // Build the attributed string
    NSString *string = [NSNumberFormatter localizedStringFromNumber:@(timeInterval) numberStyle:NSNumberFormatterNoStyle]; // Expensive, but W/E. This is a demo.
    
    // White text with a black border, so that we can see it on light and on dark backgrounds.
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont fontWithName:@"Avenir-Medium" size:144],
                                  (id)kCTForegroundColorAttributeName: (id)[UIColor whiteColor].CGColor,
                                  (id)kCTStrokeWidthAttributeName: @(-1.0),
                                  (id)kCTStrokeColorAttributeName: (id)[UIColor colorWithWhite:0.2 alpha:1.0].CGColor };
    
    NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    
    
    
    // Calculate the optimal frame
    CGRect textFrame = CGRectZero;
    textFrame.size = [attributed size];
    textFrame.origin.x = ( CGRectGetWidth( self.view.layer.frame ) - textFrame.size.width ) / 2;
    textFrame.origin.y = ( CGRectGetHeight( self.view.layer.frame ) - textFrame.size.height ) / 2;
    
    // Initialize the text layer
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    textLayer.frame = textFrame;
    textLayer.string = attributed;
    textLayer.opacity = 0;
    [self.view.layer addSublayer:textLayer];
    
    [self _performInAndOutAnimationOnLayer:textLayer duration:animationDuration];
}

- (void)_animateShutter
{
    CALayer *shutterLayer = [[CALayer alloc] init];
    shutterLayer.frame = self.view.layer.bounds;
    shutterLayer.backgroundColor = [UIColor whiteColor].CGColor;
    shutterLayer.opacity = 0;
    [self.view.layer addSublayer:shutterLayer];
    
    [self _performInAndOutAnimationOnLayer:shutterLayer duration:0.5f];
}

- (void)_performInAndOutAnimationOnLayer:(CALayer *)layer duration:(NSTimeInterval)duration
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:NSStringFromSelector(@selector(opacity))];
    animation.duration = duration;
    animation.keyTimes = @[@0, @(duration / 2), @(duration)];
    animation.values = @[@0, @1, @0];
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeBoth;
    [layer addAnimation:animation forKey:nil];
}

@end
