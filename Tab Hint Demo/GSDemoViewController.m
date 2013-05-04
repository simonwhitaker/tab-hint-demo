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

__autoreleasing NSArray* GS_pointsForGravityDrop(CGPoint startPoint, CGPoint endPoint, CFTimeInterval *duration) {

    NSCAssert(startPoint.y < endPoint.y, @"Start point must be above end point");
    
    static CGFloat gravity = 4000; // pixels per second squared. Play around with this. Larger values mean the animated view returns to earth more quickly
    static CGFloat frameRate = 0.02;
    static CGFloat initialVerticalVelocity = -1000.0; // pixels per second. Negative implies upwards movement, positive implies downwards movement.

    CGFloat incrementalVelocityChangeY = gravity * frameRate;
    
    NSMutableArray *points = [NSMutableArray array];
    
    // Define initial values for y axis calculations
    CGFloat y = startPoint.y;
    CGFloat velocityY = initialVerticalVelocity;
    
    // Now generate some points and stick 'em in an array
    while (y < endPoint.y) {
        // For now set x to 0, we'll come back and fill in the x values once we know the duration of the animation
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(0, y)]];
        
        velocityY = velocityY + incrementalVelocityChangeY;
        y = y + velocityY * frameRate;
    }
    
    // Now we know how many points we've got, go back through filling in the X values
    CGFloat incrementalDisplacementChangeX = (endPoint.x - startPoint.x) / [points count];
    [points enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGPoint p = [obj CGPointValue];
        p.x = startPoint.x + (CGFloat)idx * incrementalDisplacementChangeX;
        [points replaceObjectAtIndex:idx withObject:[NSValue valueWithCGPoint:p]];
    }];
    
    if (duration != NULL) {
        *duration = frameRate * [points count];
    }
    
    return [NSArray arrayWithArray:points];
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
    CFTimeInterval duration;
    CGFloat finalScale = 0.5;

    // Create the position animation
    CGPoint fromPosition = [[indicatorView layer] position];
    CGPoint toPosition = CGPointMake(downloadTabHorizontalCenter, [self view].frame.size.height - [indicatorView frame].size.height / 2 * finalScale);
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    NSArray *values = GS_pointsForGravityDrop(fromPosition, toPosition, &duration);
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
