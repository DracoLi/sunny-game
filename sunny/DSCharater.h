//
//  DSCharater.h
//  sunny
//
//  Created by Draco on 2013-08-20.
//  Copyright 2013 Draco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class DSLayer;

@interface DSCharater : CCNode

@property (nonatomic, copy) NSString *characterName;
@property (nonatomic, weak) DSLayer *mapLayer;
@property (nonatomic, strong) CCSprite *sprite;
@property (nonatomic) Direction direction;

+ (id)characterWithSpriteFrameName:(NSString *)frameName
                             atPos:(CGPoint)pos
                        onMapLayer:(DSLayer *)layer;
- (id)initWithSpriteFrameName:(NSString *)frameName
                        atPos:(CGPoint)pos
                   onMapLayer:(DSLayer *)layer;

// Makes this character to turn to face a point
- (void)rotateToTarget:(CGPoint)target;

- (void)animateWalkInSamePosition;

// Walk this character to the specified target
- (void)goToTarget:(CGPoint)target;
- (void)goToTarget:(CGPoint)target speedMultiplier:(CGFloat)multiplier;

// Makes the character jump
- (void)jump;

// This animates a ballon on the character's head
- (void)showBallon:(BallonType)ballon;

// Called every screen update interval
- (void)update:(ccTime)dt;

- (void)stopAllAnimations;

@end
