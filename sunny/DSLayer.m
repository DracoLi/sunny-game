//
//  DSLayer.m
//  sunny
//
//  Created by Draco on 2013-08-23.
//  Copyright 2013 Draco. All rights reserved.
//

#import "DSLayer.h"
#import "DSCharater.h"
#import "DSCocosHelpers.h"

@implementation DSLayer

- (id)init
{
  if (self = [super init]) {
    self.touchEnabled = YES;
    [self scheduleUpdate];
  }
  return self;
}

- (BOOL)isPositionBlocked:(CGPoint)position
{
  CGPoint tileCoord = [DSCocosHelpers tileCoordForPosition:position
                                                   tileMap:self.tileMap];
  return [self isTileCoordBlocked:tileCoord];
}

- (BOOL)isTileCoordBlocked:(CGPoint)tileCoord
{
  if (!self.metaLayer) {
    return NO;
  }
  int tileGid = [self.metaLayer tileGIDAt:tileCoord];
  if (tileGid) {
    NSDictionary *properties = [self.tileMap propertiesForGID:tileGid];
    if (properties) {
      NSString *collision = [properties valueForKey:@"collidable"];
      if (collision && [collision compare:@"true"] == NSOrderedSame) {
        return YES;
      }
    }
  }
  return NO;
}

// Only support walking to a place that is within one direction
- (BOOL)canCharacter:(DSCharater *)character walkToPosition:(CGPoint)position
{
  CGPoint startCoord = [DSCocosHelpers tileCoordForPosition:character.sprite.position
                                                    tileMap:self.tileMap];
  CGPoint destinationCoord = [DSCocosHelpers tileCoordForPosition:position
                                                          tileMap:self.tileMap];
  
  // Character can move to current position (not moving)
  if (CGPointEqualToPoint(startCoord, destinationCoord)) {
    return YES;
  }
  
  // Cannot check for anything but direct n/s/e/w
  CGPoint diff = CGPointMake(destinationCoord.x - startCoord.x, destinationCoord.y - startCoord.y);
  if (diff.x != 0 && diff.y != 0) {
    [NSException raise:@"Invalid Input"
                format:@"Cannot move character to (%f, %f). Can only move in a single direction.", destinationCoord.x, destinationCoord.y];
  }
  
  // Check all tiles from source to target to check if any is blocked
  for (int i = 0; i < abs(diff.x + diff.y); i++) {
    CGFloat targetX = startCoord.x;
    CGFloat targetY = startCoord.y;
    if (diff.x != 0) {
      targetX += diff.x > 0 ? 1 : -1;
    }else if (diff.y != 0) {
      targetY += diff.y > 0 ? 1 : -1;
    }else {
      [NSException raise:@"Invalid Input"
                  format:@"We should never get here! We should not need to check if char can move to same position"];
    }
    if ([self isTileCoordBlocked:CGPointMake(targetX, targetY)]) {
      return NO;
    }
  }
  
  return YES;
}



#pragma mark ccTouch Delegate


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  NSLog(@"touch began");
  
  // Update current touch location
  UITouch *touch = [touches anyObject];
  CGPoint touchLocation = [[CCDirector sharedDirector] convertTouchToGL:touch];
  touchLocation = [self convertToNodeSpace:touchLocation];
  self.currentTouchLocation = touchLocation;
  self.isTouching = YES;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  NSLog(@"touch ended");
  self.currentTouchLocation = CGPointZero;
  self.isTouching = NO;
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  NSLog(@"touch moved");
  
  // We do not update touch location on touch move
}

@end
