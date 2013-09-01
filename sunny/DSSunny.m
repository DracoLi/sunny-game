//
//  DSSunny.m
//  sunny
//
//  Created by Draco on 2013-08-20.
//  Copyright 2013 Draco. All rights reserved.
//

#import "DSSunny.h"
#import "DSLayer.h"
#import "DSCocosHelpers.h"

@interface DSSunny ()
@property (nonatomic) ccTime currentStepTimer;
@end

@implementation DSSunny

+ (id)characterAtPos:(CGPoint)pos
          onMapLayer:(DSLayer *)layer
{
  return [[self alloc] initAtPos:pos onMapLayer:layer];
}

- (id)initAtPos:(CGPoint)pos
     onMapLayer:(DSLayer *)layer
{
  self = [super initWithSpriteFrameName:@"sunny_s_00.png"
                                  atPos:pos
                             onMapLayer:layer];
  if (self) {
    // Other sunny initializations
    self.controllable = YES;
    self.walkingDisabled = NO;
  }
  return self;
}

- (void)update:(ccTime)dt
{
  [super update:dt];
  
  // Handle sunny walking via touch
  if (self.mapLayer.isTouching && self.controllable && !self.walkingDisabled) {
    CGPoint touchLocation = self.mapLayer.currentTouchLocation;
    
    // Determine the touch direction
    Direction direction = [DSCocosHelpers directionToPosition:touchLocation
                                                 fromPosition:self.sprite.position];
    // Take one step to that direction whenever
    if (self.currentStepTimer < 0) {
      // Take one step to that direciton
      [self takeSteps:1 towardsDirection:direction];
      self.currentStepTimer = kCharacterSpeedPerStep;
    }else {
      // Add timer towards our first step
      self.currentStepTimer -= dt;
    }
  }else {
    self.currentStepTimer = 0;
  }
}

@end
