//
//  JellyBeanView.m
//  JellyBeans
//
//  Created by Kevin Doughty on 8/11/12.
//  Copyright (c) 2012 Kevin Doughty. All rights reserved.
//

#import "JellyBeanView.h"
#import <QuartzCore/QuartzCore.h>

@implementation JellyBeanView

@synthesize animationDuration, useAdditiveAnimation, useDeferredAnimation, layerCount;
@synthesize timingFunction, runLoopModes, layerEnumerator;

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self initStuff];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)theDecoder {
    if ((self = [super initWithCoder:theDecoder])) {
        [self initStuff];
    }
    return self;
}

-(void) initStuff {
    layerCount = 0;
    self.animationDuration = 1.0;
    self.useAdditiveAnimation = YES;
    self.useDeferredAnimation = YES;
    self.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.5 :0 :.5 :1];
    self.runLoopModes = [NSArray arrayWithObjects:@"NSDefaultRunLoopMode",@"NSEventTrackingRunLoopMode",nil];
    self.layerEnumerator = nil;
}

-(void) awakeFromNib {
    srandomdev();
    self.layer = [CALayer layer];
    self.wantsLayer = YES;
    
    CGFloat red = (random() % 256) / 256.0;
	CGFloat green =  (random() % 256) / 256.0;
	CGFloat blue =  (random() % 256) / 256.0;
	CGColorRef backgroundColorRef = CGColorCreateGenericRGB(red,green,blue,0.5);
	self.layer.backgroundColor = backgroundColorRef;
	CGColorRelease(backgroundColorRef);
    
    self.layerCount = 500;
}


-(void)setFrame:(NSRect)theRect {
    [super setFrame:theRect];
	[self layoutSublayers];
	
}
-(BOOL) isFlipped {
    return YES;
}

-(NSUInteger) layerCount {
	return layerCount;
}
-(void)setLayerCount:(NSUInteger)theCount {
	if (self.wantsLayer) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(layoutPass) object:nil];
        self.layerEnumerator = nil;
        
        [CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        
        NSUInteger theIndex = layerCount;
        NSArray *theSublayers = self.layer.sublayers;
        while (theIndex > theCount) {
            theIndex--;
            [[theSublayers objectAtIndex:theIndex] removeFromSuperlayer];
        }
        while (theIndex < theCount) {
            theIndex++;
            [self createLayer];
        }
        [CATransaction commit];
        
        [self layoutSublayers];
    }
    layerCount = theCount;
}

-(void) createLayer {
    CGFloat theDiameter = 20.0;
    
    CALayer *theLayer = [CALayer layer];
    theLayer.bounds = CGRectMake(0,0,theDiameter, theDiameter);
    theLayer.cornerRadius = theDiameter/2.0;
    theLayer.anchorPoint = CGPointZero;
    
    CGFloat red = (random() % 256) / 256.0;
	CGFloat green =  (random() % 256) / 256.0;
	CGFloat blue =  (random() % 256) / 256.0;
	CGColorRef backgroundColorRef = CGColorCreateGenericRGB(red,green,blue,0.5);
	theLayer.backgroundColor = backgroundColorRef;
	CGColorRelease(backgroundColorRef);
    
    CGColorRef borderColorRef = CGColorCreateGenericRGB(1.0-red,1.0-green,1.0-blue,0.5);
	theLayer.borderColor = borderColorRef;
	CGColorRelease(borderColorRef);
    theLayer.borderWidth = 2.0;
    
    [self.layer addSublayer:theLayer];
}


-(void) layoutSublayers {
	
    if (!self.wantsLayer) return;
    
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(layoutPass) object:nil];
	
	if (self.useDeferredAnimation) {
		@autoreleasepool {
            NSArray *theSublayers = self.layer.sublayers;
            NSArray *notLaidOut = [self.layerEnumerator allObjects];
            NSMutableArray *alreadyLaidOut = [[NSMutableArray alloc] initWithArray:theSublayers];
            [alreadyLaidOut removeObjectsInArray:notLaidOut];
            NSMutableArray *sortedArray = [[NSMutableArray alloc] initWithArray:notLaidOut];
            [sortedArray addObjectsFromArray:alreadyLaidOut];
            self.layerEnumerator = [sortedArray objectEnumerator];
		}
		[self performSelector:@selector(layoutPass) withObject:nil afterDelay:0 inModes:runLoopModes];
		
	} else {
		@autoreleasepool {
            NSArray *theSublayers = self.layer.sublayers;
            
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            for (CALayer* theLayer in theSublayers) {
                [self layoutLayer:theLayer];
            }
            [CATransaction commit];
        }
    }
    
}
-(void) layoutPass {
	CALayer *theLayer = [self.layerEnumerator nextObject];
	if (theLayer != nil) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [self layoutLayer:theLayer];
        [CATransaction commit];
		
		[self performSelector:@selector(layoutPass) withObject:nil afterDelay:0 inModes:runLoopModes];
	}
	
}

-(void) layoutLayer:(CALayer*)theLayer {
    CGPoint destinationPoint = [self gridPointForLayer:theLayer];
	[self animateLayer:theLayer toPoint:destinationPoint];
}



-(void) animateLayer:(CALayer*)theLayer toPoint:(CGPoint)newPoint {
	CABasicAnimation *positionAnimation = [[CABasicAnimation alloc] init];
    positionAnimation.keyPath = @"position";
	positionAnimation.timingFunction = self.timingFunction;
    positionAnimation.duration = self.animationDuration;
	if (self.useAdditiveAnimation) {
		positionAnimation.additive = YES;
        CGPoint oldPoint = theLayer.position;
        NSPoint deltaPoint = NSMakePoint(oldPoint.x-newPoint.x, oldPoint.y-newPoint.y);
		theLayer.position = newPoint;
        NSValue *fromValue = [[NSValue alloc] initWithBytes:&deltaPoint objCType:@encode(NSPoint)];
		positionAnimation.fromValue = fromValue;
		
		NSValue *toValue = [[NSValue alloc] initWithBytes:&NSZeroPoint objCType:@encode(NSPoint)];
		positionAnimation.toValue = toValue;
        
		[theLayer addAnimation:positionAnimation forKey:nil];
	} else {
		theLayer.position = newPoint;
		[theLayer addAnimation:positionAnimation forKey:@"position"];
	}
}

-(CABasicAnimation *) additiveAnimationWithKeyPath:(NSString*)theKeyPath {
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:theKeyPath];
	animation.duration = self.animationDuration;
	animation.timingFunction = self.timingFunction;
	animation.additive = YES;
    animation.fillMode = kCAFillModeBoth; // This fixes the flash of un-animated content
	return animation;
}

-(CGPoint) gridPointForLayer:(CALayer*)theLayer {
	NSUInteger theIndex = [self.layer.sublayers indexOfObject:theLayer];
	CGFloat itemDimension = theLayer.bounds.size.width;
	if (itemDimension < 1.0) itemDimension = 1;
	NSUInteger countPerRow = self.bounds.size.width / itemDimension;
	if (!countPerRow) countPerRow = 1;
	CGFloat x = (itemDimension * theLayer.anchorPoint.x) + ((CGFloat)(theIndex % countPerRow) * (itemDimension));
	CGFloat y = (itemDimension * theLayer.anchorPoint.y) + (floor((CGFloat)theIndex / (CGFloat)countPerRow) * itemDimension);
	return CGPointMake(x,y);
	
}

@end
