//
//  SceneOneLayer.m
//  sunny
//
//  Created by Draco on 2013-08-19.
//  Copyright 2013 Draco. All rights reserved.
//

#import "SceneOneLayer.h"
#import "DSSunny.h"

@interface SceneOneLayer ()
@property (nonatomic, strong) DSSunny *sunny;
@end

@implementation SceneOneLayer

+(CCScene *) scene
{
  CCScene *scene = [CCScene node];
  CCLayer *layer = [SceneOneLayer node];
  [scene addChild:layer];
  return scene;
}

- (id)init
{
  self = [super initWithTileMapName:@"sunny-room"];
  if (self) {
    // Load in sunny and add it to map
    _sunny = [DSSunny characterAtPos:CGPointMake(340, 80) onMapLayer:self];
    _sunny.walkingDisabled = NO;
    [self.tileMap addChild:_sunny.sprite z:kCharacterZIndex];
  }
  return self;
}


#pragma mark - Touch Delegate

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super ccTouchesBegan:touches withEvent:event];
//  [self.sunny jump];
  int randBallon = arc4random_uniform(kBallonTypeMAX);
//  [self.sunny showBalloon:randBallon
//              forDuration:2.0 animated:YES speedMultiplier:1.0];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super ccTouchesEnded:touches withEvent:event];
  
  // Testing stuff
  
  // Test direction change
  //  self.sunny.direction = (self.sunny.direction + 1) % 4;
  
  // Test walking
//  [self.sunny animateWalkInSamePosition];
}

- (void)update:(ccTime)delta
{
  [super update:delta];
  
  // Update sunny's walk animation
  [self.sunny update:delta];
}

@end
