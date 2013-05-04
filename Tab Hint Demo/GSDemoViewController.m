//
//  GSDemoViewController.m
//  Tab Hint Demo
//
//  Created by Simon Whitaker on 04/05/2013.
//  Copyright (c) 2013 Goo Software Ltd. All rights reserved.
//

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
    
    [self setView:rootView];
    
}

- (void)GS_handleDownloadButton:(id)sender {
    
    //UIButton *downloadButton = (UIButton*)sender;
    
    
}

@end
