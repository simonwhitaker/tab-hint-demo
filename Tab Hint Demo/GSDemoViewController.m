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

__autoreleasing NSArray* GS_pointsForGravityDrop(CGPoint startPoint, CGPoint endPoint, CFTimeInterval duration, CGFloat gravity, NSUInteger numberOfPoints) {
    CGFloat dx = endPoint.x - startPoint.x;
    CGFloat dy = endPoint.y - startPoint.y;
    
    CGFloat incrementalTimeChange = duration/(CGFloat)numberOfPoints;
    
    // Gravity should be expressed in negative units: displacement decreases as we go up, increases as we go down
    NSCAssert(gravity > 0.0, @"Gravity should be negative");
    
    CGFloat averageVelocityY = dy/duration;
    CGFloat totalVelocityChangeY = gravity * duration;
    CGFloat initialVelocityY = averageVelocityY - totalVelocityChangeY / 2.0;
    CGFloat incrementalVelocityChangeY = totalVelocityChangeY / (CGFloat)numberOfPoints;
    
    NSMutableArray *mutableResult = [NSMutableArray arrayWithCapacity:numberOfPoints];
    CGFloat y = startPoint.y;
    
    for (NSUInteger i = 0; i < numberOfPoints; i++) {
        CGFloat t = incrementalTimeChange * i;
        CGFloat progress = t/duration;
        
        // x simply progresses linearly...
        CGFloat x = startPoint.x + dx * progress;
        
        [mutableResult addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        
        // y's velocity changes according to gravity
        CGFloat velocityY = initialVelocityY + incrementalVelocityChangeY * i;
        y = y + velocityY * incrementalTimeChange;
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

    // Create an animation group
    CFTimeInterval duration = 0.7;
    CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc] init];
    [animationGroup setDuration:duration];

    // Create the position animation
    CGPoint fromPosition = [[indicatorView layer] position];
    CGPoint toPosition = CGPointMake(downloadTabHorizontalCenter, [self view].frame.size.height - [indicatorView frame].size.height / 4);
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGFloat gravity = 4000;
    NSUInteger numberOfValues = 100;
    
    NSArray *values = GS_pointsForGravityDrop(fromPosition, toPosition, duration, gravity, numberOfValues);
    [positionAnimation setValues:values];
    [positionAnimation setDuration:duration];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [scaleAnimation setFromValue:@(1.0)];
    [scaleAnimation setToValue:@(0.5)];
    [scaleAnimation setDuration:duration];

    [animationGroup setAnimations:@[positionAnimation, scaleAnimation]];
    
    [[indicatorView layer] addAnimation:animationGroup forKey:@"showDownloadsButtonHint"];
    [[indicatorView layer] setPosition:toPosition];
    
}

@end
