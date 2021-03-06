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

@property (nonatomic, copy) NSString *name;
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
- (void)goToTarget:(CGPoint)target withSpeedMultiplier:(CGFloat)multiplier;
- (void)takeSteps:(NSInteger)steps towardsDirection:(Direction)direction;

/**
 * Talking related methods
 */
- (void)sayWords:(NSArray *)words;

/**
 * Our base walk method. All character moving methods call this to walk.
 * Our current walk implementation only support walking in one direction.
 * This method also handles collision checking.
 *
 * By default multiplier is 1, but this can be changes to walk faster or slower
 */
- (void)walk:(CGFloat)distance inDirection:(Direction)direction;
- (void)walk:(CGFloat)distance inDirection:(Direction)direction
                       withSpeedMultiplier:(CGFloat)multiplier;

// Makes the character jump
- (void)jump;

// This animates a balloon on the character's head
- (void)showBalloon:(BalloonType)balloonType
       forDuration:(ccTime)duration
          animated:(BOOL)animated
   speedMultiplier:(CGFloat)multiplier;

// Called every screen update interval
- (void)update:(ccTime)dt;

- (void)stopAllAnimations;

@end
