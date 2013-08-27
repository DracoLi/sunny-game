//
//  DSCocosHelpers.m
//  sunny
//
//  Created by Draco on 2013-08-22.
//  Copyright (c) 2013 Draco. All rights reserved.
//

#import "DSCocosHelpers.h"

@implementation DSCocosHelpers

#pragma mark - Tile Coordinate helpers

+ (CGPoint)tileCoordForPosition:(CGPoint)position
                        tileMap:(CCTMXTiledMap *)tileMap
{
  CGSize tileSize = tileMap.tileSize;
  int x = position.x / tileSize.width;
  int y = ((tileMap.mapSize.height * tileSize.height) - position.y) / (tileSize.height);
  return ccp(x, y);
}

+ (CGRect)rectForTileCoord:(CGPoint)tileCoord onTileMap:(CCTMXTiledMap *)tileMap
{
  CGSize tileSize = tileMap.tileSize;
  int x = tileCoord.x * tileSize.width;
  int y = (tileMap.mapSize.height * tileSize.height) - (tileCoord.y * tileSize.height) - tileSize.height;
  return CGRectMake(x, y, tileSize.width, tileSize.height);
}

// Helper method to check if a rect intersets with a certain tile coordinate
+ (BOOL)rectIntersectsWithTileCoord:(CGPoint)tileCoord
                               rect:(CGRect)rect
                          onTileMap:(CCTMXTiledMap *)tileMap
{
  // Get the CGRect for the tileCoord
  CGRect tileCoordRect = [self rectForTileCoord:tileCoord onTileMap:tileMap];
  return CGRectIntersectsRect(rect, tileCoordRect);
}

#pragma mark - Direction Helpers

+ (Direction)directionToPosition:(CGPoint)toPos fromPosition:(CGPoint)fromPos
{
  CGPoint diff = ccpSub(toPos, fromPos);
  if (abs(diff.x) > abs(diff.y)) {
    return diff.x > 0 ? kDirectionEast : kDirectionWest;
  }else {
    return diff.y > 0 ? kDirectionNorth : kDirectionSouth;
  }
}

+ (NSString *)stringFromDirection:(Direction)direction
{
  NSString *dirString = @"n";
  switch (direction) {
    case kDirectionNorth:
      dirString = @"n";
      break;
    case kDirectionEast:
      dirString = @"e";
      break;
    case kDirectionSouth:
      dirString = @"s";
      break;
    case kDirectionWest:
      dirString = @"w";
      break;
    default:
      [NSException raise:@"Invalid Argument" format:@"Bad direction provided"];
  }
  return dirString;
}

+ (CGPoint)tileCoordDiffForDirection:(Direction)direction
{
  switch (direction) {
    case kDirectionNorth:
      return CGPointMake(0, -1);
    case kDirectionEast:
      return CGPointMake(1, 0);
    case kDirectionSouth:
      return CGPointMake(0, 1);
    case kDirectionWest:
      return CGPointMake(-1, 0);
    default:
      [NSException raise:@"Invalid Argument" format:@"Bad direction provided"];
  }
}

+ (CGPoint)positionDiffForDirection:(Direction)direction
{
  switch (direction) {
    case kDirectionNorth:
      return CGPointMake(0, 1);
    case kDirectionEast:
      return CGPointMake(1, 0);
    case kDirectionSouth:
      return CGPointMake(0, -1);
    case kDirectionWest:
      return CGPointMake(-1, 0);
    default:
      [NSException raise:@"Invalid Argument" format:@"Bad direction provided"];
  }
}

+ (void)validateTargetIsInDirectDirection:(CGPoint)target
                               fromSource:(CGPoint)source
{
  BOOL isDirect = [self isTargetInDirectDirection:target fromSource:source];
  if (!isDirect) {
    [NSException raise:@"Invalid Argument"
                format:@"Targer is not in the same position as the source position!"];
  }
}

+ (BOOL)isTargetInDirectDirection:(CGPoint)target
                       fromSource:(CGPoint)source
{
  if (CGPointEqualToPoint(target, source)) {
    return NO;
  }
  
  if (target.x != source.x && target.y != source.y) {
    return NO;
  }
  
  return YES;
}

@end
