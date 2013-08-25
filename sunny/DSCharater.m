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
                             inSteps:(NSInteger)step;
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


#pragma mark - Character travelling related

- (void)goToTarget:(CGPoint)target {
  [self goToTarget:target speedMultiplier:1];
}

// Currently goToTarget does not handle going to a target that is not
// in direct direction with the target and when there's something blocking the way
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
  CGFloat adjustedDistancePerStep = kCharacterDistancePerStep * multiplier;
  ccTime duration = (distance / adjustedDistancePerStep) * kCharacterSpeedPerStep;
  id moveAction = [CCMoveTo actionWithDuration:duration position:target];
  [self.sprite runAction:[CCSequence actions:moveAction, nil]];
  //  self.sprite.position = target;
}

// Take x amount of step in direction. Does not take step if the road to target
// is blocked
- (void)takeSteps:(NSInteger)steps towardsDirection:(Direction)direction
{
  // Figure out walk duration and distance
  CGFloat distance = kCharacterDistancePerStep * steps;
  ccTime duration = steps * kCharacterSpeedPerStep;
  
  // Figure out final direction
  CGPoint diffPos = ccpMult([DSCocosHelpers pointFromDirection:direction], distance);
  CGPoint finalPos = ccpAdd(self.sprite.position, diffPos);
  
  // No matter if we can or not move to direction, the char should face it first
  self.direction = direction;
  
  // Collision detection
  if (![self.mapLayer canCharacter:self walkToPosition:finalPos]) {
    NSLog(@"cannot take %i step(s) to direction: %i", steps, direction);
    return;
  }
  
  // Move and animate
  id moveAction = [CCMoveTo actionWithDuration:duration position:finalPos];
  [self.sprite runAction:[CCSequence actions:moveAction, nil]];
  [self playWalkAnimationToDirection:direction inSteps:steps];
}

- (void)rotateToTarget:(CGPoint)target
{
  // Figure out the direction of the target
  Direction targetDirection = [DSCocosHelpers directionToPosition:target
                                                     fromPosition:self.sprite.position];
  self.direction = targetDirection;
}

- (void)animateWalkInSamePosition
{
  [self playWalkAnimationToDirection:self.direction inSteps:NSIntegerMax];
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
  Direction direction = [DSCocosHelpers directionToPosition:target
                                               fromPosition:self.sprite.position];
  
  // Figure out how many steps we need to take
  CGFloat distance = ccpDistance(self.sprite.position, target);
  NSLog(@"character distance to walk: %f", distance);
  NSUInteger steps = ceilf(distance / kCharacterDistancePerStep);
  NSLog(@"character is now gonna take %i steps", steps);
  
  [self playWalkAnimationToDirection:direction inSteps:steps];
}

- (void)playWalkAnimationToDirection:(Direction)direction
                             inSteps:(NSInteger)step
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
  if (step == NSIntegerMax) {
    walkAction = [CCRepeatForever actionWithAction:action];
  }else {
    walkAction = [CCRepeat actionWithAction:action times:step];
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
