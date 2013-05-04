//
//  GSDemoViewController.m
//  Tab Hint Demo
//
//  Created by Simon Whitaker on 04/05/2013.
//  Copyright (c) 2013 Goo Software Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "GSDemoViewController.h"

@implementation GSDemoViewController

- (void)loadView {
    
    UIView *rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [rootView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [downloadButton setTitle:@"Download a thing" forState:UIControlStateNormal];
    [downloadButton setFrame:CGRectMake(50, 300, 200, 50)];
    [downloadButton addTarget:self action:@selector(GS_handleDownloadButton:) forControlEvents:UIControlEventTouchUpInside];
    [rootView addSubview:downloadButton];
    
    downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [downloadButton setTitle:@"Download a thing" forState:UIControlStateNormal];
    [downloadButton setFrame:CGRectMake(250, 500, 200, 50)];
    [downloadButton addTarget:self action:@selector(GS_handleDownloadButton:) forControlEvents:UIControlEventTouchUpInside];
    [rootView addSubview:downloadButton];

    downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [downloadButton setTitle:@"Download a thing" forState:UIControlStateNormal];
    [downloadButton setFrame:CGRectMake(800, 400, 200, 50)];
    [downloadButton addTarget:self action:@selector(GS_handleDownloadButton:) forControlEvents:UIControlEventTouchUpInside];
    [rootView addSubview:downloadButton];

    [self setView:rootView];
    
}

__autoreleasing NSArray* GS_pointsForGravityDrop(CGPoint startPoint, CGPoint endPoint, CFTimeInterval duration, CGFloat gravity) {
    
    // Gravity should be expressed in positive units; origin in iOS coordinates is top left, so y values decrease as we go up, increase as we go down
    NSCAssert(gravity > 0.0, @"Gravity should be negative");
    
    // Calculate some values we'll need
    CGFloat dx = endPoint.x - startPoint.x;
    CGFloat dy = endPoint.y - startPoint.y;
    
    // Calculate the number of points we need in our array. This has been empirically determined to be about right. Basically the stronger the gravity, the more violent the animation and the more points we need to maintain precision. But maybe you could try deriving this from the duration instead, which might make more sense.
    NSUInteger numberOfPoints = (NSUInteger)(gravity/40.0);
    
    CGFloat timePerIncrement = duration/(CGFloat)numberOfPoints;

    // Now calculate our initial vertical velocity. We can work out the average vertical velocity by looking at the change in y value over time. The velocity will change during the animation, but the rate of that change is constant (it's our gravity value). The total change in velocity will be gravity * duration. Given this, we can work out what the initial velocity will be, and what the velocity change per increment will be.
    CGFloat averageVelocityY = dy/duration;
    CGFloat totalVelocityChangeY = gravity * duration;
    CGFloat initialVelocityY = averageVelocityY - totalVelocityChangeY / 2.0;
    CGFloat incrementalVelocityChangeY = totalVelocityChangeY / (CGFloat)numberOfPoints;
    
    NSMutableArray *mutableResult = [NSMutableArray arrayWithCapacity:numberOfPoints];
    CGFloat y = startPoint.y;
    
    // Now generate some points and stick 'em in an array
    for (NSUInteger i = 0; i < numberOfPoints; i++) {
        CGFloat t = timePerIncrement * i;
        CGFloat progress = t/duration; // normalised progress between 0.0 (start) and 1.0 (end)
        
        // x simply progresses linearly...
        CGFloat x = startPoint.x + dx * progress;
        
        [mutableResult addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        
        CGFloat velocityY = initialVelocityY + incrementalVelocityChangeY * i;
        y = y + velocityY * timePerIncrement;
    }
    
    return [NSArray arrayWithArray:mutableResult];
}


- (void)GS_handleDownloadButton:(id)sender {
    
    UIButton *downloadButton = (UIButton*)sender;

    // Find the frame of the download button
    UIView *downloadButtonView;
    NSUInteger downloadButtonIndex = 2;
    NSUInteger currentIndex = 0;
    for (UIView *subview in [[[self tabBarController] tabBar] subviews]) {
        if ([subview isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            if (currentIndex == downloadButtonIndex) {
                downloadButtonView = subview;
                break;
            } else {
                currentIndex++;
            }
        }
    }
    
    // Get the horizontal center of the download button on the tab bar. We'll use this in a minute...
    CGFloat downloadTabHorizontalCenter = [downloadButtonView center].x;

    // Create a view that you'll animate down to the downloads tab to indicate where it is. This might be, for example, an icon or thumbnail image representing the thing you're downloading.
    UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    [indicatorView setBackgroundColor:[UIColor redColor]];
    
    // Place the indicator view immediately above the download button
    CGPoint viewCenter = [downloadButton center];
    viewCenter.y -= ([indicatorView frame].size.height / 2 + [downloadButton frame].size.height / 2);
    [indicatorView setCenter:viewCenter];

    // Add the indicator view, set a completion block on the current Core Animation transaction to remove it when we're done
    [[self view] addSubview:indicatorView];
    [CATransaction setCompletionBlock:^{
        [indicatorView removeFromSuperview];
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(incrementDownloadBadge)];
    }];

    // Declare a couple of parameters we'll use throughout the animation
    CFTimeInterval duration = 0.7;
    CGFloat finalScale = 0.5;

    // Create the position animation
    CGPoint fromPosition = [[indicatorView layer] position];
    CGPoint toPosition = CGPointMake(downloadTabHorizontalCenter, [self view].frame.size.height - [indicatorView frame].size.height / 2 * finalScale);
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGFloat gravity = 4000; // Play around with this. Larger values give a stronger upwards launch at the start of the animation.
    
    NSArray *values = GS_pointsForGravityDrop(fromPosition, toPosition, duration, gravity);
    [positionAnimation setValues:values];
    [positionAnimation setDuration:duration];

    // Create the scale animation
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [scaleAnimation setFromValue:@(1.0)];
    [scaleAnimation setToValue:@(finalScale)];
    [scaleAnimation setDuration:duration];

    // Create an animation group, add our animations to it
    CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc] init];
    [animationGroup setDuration:duration];
    [animationGroup setAnimations:@[positionAnimation, scaleAnimation]];

    // Finally, perform the animation. Simple! :-)
    [[indicatorView layer] addAnimation:animationGroup forKey:@"showDownloadsButtonHint"];
    [[indicatorView layer] setPosition:toPosition];
    
}

@end
