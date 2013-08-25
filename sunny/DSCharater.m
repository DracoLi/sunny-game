//
//  DSCharater.m
//  sunny
//
//  Created by Draco on 2013-08-20.
//  Copyright 2013 Draco. All rights reserved.
//

#import "DSCharater.h"
#import "DSLayer.h"
#import "DSCocosHelpers.h"
#import "CCAnimate+SequenceLoader.h"

@interface DSCharater ()
@property (nonatomic) ccTime moveTimer;
@property (nonatomic) CGPoint moveTarget;
@property (nonatomic, copy) NSString *initialFrameName;

- (void)playWalkAnimationToTarget:(CGPoint)target;
- (void)playWalkAnimationToDirection:(Direction)direction
                            forTimes:(NSInteger)times;
- (NSString *)baseFrameName;
@end

@implementation DSCharater

+ (id)characterWithSpriteFrameName:(NSString *)frameName
                             atPos:(CGPoint)pos
                        onMapLayer:(DSLayer *)layer
{
  return [[self alloc] initWithSpriteFrameName:frameName
                                         atPos:pos
                                    onMapLayer:layer];
}

- (id)initWithSpriteFrameName:(NSString *)frameName
                        atPos:(CGPoint)pos
                   onMapLayer:(DSLayer *)layer
{
  self = [super init];
  if (self) {
    // Create character sprite and position it
    _initialFrameName = frameName;
    _sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    _sprite.position = pos;
    _sprite.scale = 1;
    _sprite.anchorPoint = ccp(0.5, 0.5);
    _direction = kDirectionSouth;
    
    // Add character sprite to map
    _mapLayer = layer;
    [_mapLayer.characterLayer addChild:_sprite z:kDefaultCharacterIndex];
  }
  return self;
}

- (void)goToTarget:(CGPoint)target {
  [self goToTarget:target speedMultiplier:1];
}

- (void)goToTarget:(CGPoint)target speedMultiplier:(CGFloat)multiplier
{
  // Rotate the person before moving
  [self rotateToTarget:target];
  
  // Check if there are any obsticals to the target
  // In the current case, we should no move the character through an invalid path
  // If that is the case then we don't handle it right now except raising an error
  if (![self.mapLayer canCharacter:self walkToPosition:target]) {
    [NSException raise:@"Invalid move destination"
                format:@"We should not move a character through blocked content!"];
  }
  
  // Animate character walking
  [self playWalkAnimationToTarget:target];
  
  // Animate character moving
  CGFloat distance = ccpDistance(self.sprite.position, target);
  ccTime duration = (distance / kCharacterDistancePerStep) * kCharacterSpeedPerStep;
  id moveAction = [CCMoveTo actionWithDuration:duration position:target];
  [self.sprite runAction:[CCSequence actions:moveAction, nil]];
  //  self.sprite.position = target;
}

- (void)rotateToTarget:(CGPoint)target
{
  // TODO: Figure out the direction of the target
  Direction targetDirection = kDirectionSouth;
  
  self.direction = targetDirection;
}

- (void)animateWalkInSamePosition
{
  [self playWalkAnimationToDirection:self.direction forTimes:NSIntegerMax];
}

- (void)setDirection:(Direction)direction
{
  _direction = direction;
  
  // Update character sprite to reflect the direction change
  NSString *directionFrame = [NSString stringWithFormat:@"%@_%@_00.png",
                              self.baseFrameName,
                              [DSCocosHelpers stringFromDirection:direction]];
  CCSpriteFrame *newSprite = [[CCSpriteFrameCache sharedSpriteFrameCache]
                              spriteFrameByName:directionFrame];
  [self.sprite setDisplayFrame:newSprite];
}

- (void)jump
{
  
}

- (void)showBallon:(BallonType)ballon
{
  
}

- (void)stopAllAnimations
{
  [self.sprite stopAllActions];
}

- (void)update:(ccTime)dt
{
  
}


#pragma Private methods

- (void)playWalkAnimationToTarget:(CGPoint)target
{
  // Figure out the animation direction
  Direction direction = [DSCocosHelpers directionFromPosition:self.sprite.position
                                                   toPosition:target];
  
  // Figure out how many steps we need to take
  CGFloat distance = ccpDistance(self.sprite.position, target);
  NSLog(@"character distance to walk: %f", distance);
  NSUInteger steps = ceilf(distance / kCharacterDistancePerStep);
  NSLog(@"character is now gonna take %i steps", steps);
  
  [self playWalkAnimationToDirection:direction forTimes:steps];
}

- (void)playWalkAnimationToDirection:(Direction)direction
                            forTimes:(NSInteger)times
{
  // Construct the single step animation sequence
  NSString *dirString = [DSCocosHelpers stringFromDirection:direction];
  NSString *walkCycle = [NSString stringWithFormat:@"%@_%@_%%02d.png",
                         self.baseFrameName, dirString];
  CCActionInterval *action = [CCAnimate
                              actionWithSpriteSequence:walkCycle
                              numFrames:3
                              delay:kCharacterSpeedPerStep/kCharacterWalkAnimationFrames
                              restoreOriginalFrame:YES];
  
  // Play walk animation for all steps
  id walkAction = 0;
  if (times == NSIntegerMax) {
    walkAction = [CCRepeatForever actionWithAction:action];
  }else {
    walkAction = [CCRepeat actionWithAction:action times:times];
  }
  
  //  CCAction *doneAction = [CCCallFuncN actionWithTarget:self selector:@selector(heroIsDoneWalking)];
  [self.sprite runAction:[CCSequence actions:walkAction, nil]];
}

- (NSString *)baseFrameName
{
  NSRange rng = [self.initialFrameName rangeOfString:@"_"];
  return [self.initialFrameName substringToIndex:rng.location];
}

@end
