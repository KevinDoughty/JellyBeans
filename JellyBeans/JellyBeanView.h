//
//  JellyBeanView.h
//  JellyBeans
//
//  Created by Kevin Doughty on 8/11/12.
//  Copyright (c) 2012 Kevin Doughty. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JellyBeanView : NSView

@property (assign) CGFloat animationDuration;
@property (assign) BOOL useAdditiveAnimation;
@property (assign) BOOL useDeferredAnimation;
@property (assign) NSUInteger layerCount;
@property (retain) CAMediaTimingFunction *timingFunction;
@property (retain) NSArray *runLoopModes;
@property (retain) NSEnumerator *layerEnumerator;

@end
