//
//  AppDelegate.h
//  JellyBeans
//
//  Created by Kevin Doughty on 8/11/12.
//  Copyright (c) 2012 Kevin Doughty. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class JellyBeanView;
@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet JellyBeanView *viewOne;
@property (assign) IBOutlet JellyBeanView *viewTwo;
@end
