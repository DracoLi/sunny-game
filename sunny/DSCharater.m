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

@interface DSCharater ()
@property (nonatomic) ccTime moveTimer;
@property (nonatomic) CGPoint moveTarget;

- (void)setCharacterPosition:(CGPoint)position;
@end

@implementation DSCharater

+ (id)characterWithSpriteFrameName:(NSString *)frameName
                             atPos:(CGPoint)pos
                        onMapLayer:(DSLayer *)layer
{
  return [[self alloc] initWithSpriteFrameName:frameName
                                         asPos:pos
                                    onMapLayer:layer];
}

- (id)initWithSpriteFrameName:(NSString *)frameName
                        asPos:(CGPoint)pos
                   onMapLayer:(DSLayer *)layer
{
  self = [super init];
  if (self) {
    // Create character sprite and position it 
    _sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    _sprite.position = pos;
    
    // Add character sprite to map
    _mapLayer = layer;
    [_mapLayer addChild:_sprite z:kDefaultCharacterIndex];
  }
  return self;
}

- (void)goToTarget:(CGPoint)target inSeconds:(ccTime)seconds
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
  
  // Animate character moving
}

- (void)playWalkAnimationToTarget:(CGPoint)target
{
  Direction direction = [DSCocosHelpers directionFromPosition:self.sprite.position
                                                   toPosition:target];
}

- (void)rotateToTarget:(CGPoint)target
{
  CGPoint diff = ccpSub(target, self.sprite.position);
  float angelRadians = atanf((float)diff.y / (float)diff.x);
  float angelDegrees = CC_RADIANS_TO_DEGREES(angelRadians);
  float cocosAngel = -angelDegrees;
  if (diff.x < 0) {
    cocosAngel += 180;
  }
  self.sprite.rotation = cocosAngel;
}

- (void)rotateToDirection:(Direction)direction
{
  CGPoint targetPoint = self.position;
  float ptOffset = 10.0;
  switch (direction) {
    case kDirectionNorth:
      targetPoint.y += ptOffset;
      break;
    case kDirectionEast:
      targetPoint.x += ptOffset;
      break;
    case kDirectionSouth:
      targetPoint.y -= ptOffset;
      break;
    case kDirectionWest:
      targetPoint.x -= ptOffset;
      break;
    default:
      [NSException raise:@"Invalid Direction"
                  format:@"%d is an invalid direction", direction];
  }
  
  [self rotateToTarget:targetPoint];
}

- (void)jump
{
  
}

- (void)showBallon:(BallonType)ballon
{
  
}

- (void)walkToTarget:(CGPoint)target
{
  
}

- (void)update:(ccTime)dt
{
  
}

@end
