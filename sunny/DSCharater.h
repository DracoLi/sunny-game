//
//  DSCharater.h
//  sunny
//
//  Created by Draco on 2013-08-20.
//  Copyright 2013 Draco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface DSCharater : CCNode {

}

@property (nonatomic, weak) CCLayer *mapLayer;
@property (nonatomic, strong) CCSprite *sprite;

+ (id)characterWithSpriteFrameName:(NSString *)frameName
                             atPos:(CGPoint)pos
                        onMapLayer:(CCLayer *)layer;
- (id)initWithSpriteFrameName:(NSString *)frameName
                        asPos:(CGPoint)pos
                   onMapLayer:(CCLayer *)layer;

// Makes this character to turn to face a point
- (void)rotateToTarget:(CGPoint)target;

// Makes this character to turn in that direction
- (void)rotateToDirection:(Direction)direction;

// Makes the character jump
- (void)jump;

// This animates a ballon on the character's head
- (void)showBallon:(BallonType)ballon;

// Walk this character to the specified target
- (void)walkToTarget:(CGPoint)target;

// Called every screen update interval
- (void)update:(ccTime)dt;

@end
