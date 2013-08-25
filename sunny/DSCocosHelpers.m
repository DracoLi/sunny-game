//
//  DSCocosHelpers.m
//  sunny
//
//  Created by Draco on 2013-08-22.
//  Copyright (c) 2013 Draco. All rights reserved.
//

#import "DSCocosHelpers.h"

@implementation DSCocosHelpers

+ (CGPoint)tileCoordForPosition:(CGPoint)position
                        tileMap:(CCTMXTiledMap *)tileMap
{
  CGSize tileSize = tileMap.tileSize;
  int x = position.x / (tileSize.width);
  int y = ((tileMap.mapSize.height * tileSize.height) - position.y) / (tileSize.height);
  return ccp(x, y);
}

+ (CGPoint)positionForTileCoord:(CGPoint)tileCoord
                        tileMap:(CCTMXTiledMap *)tileMap
{
  CGSize tileSize = tileMap.tileSize;
  int x = (tileCoord.x * tileSize.width) + tileSize.width;
  int y = (tileMap.mapSize.height * tileSize.height) - (tileCoord.y * tileSize.height) - tileSize.height;
  return ccp(x, y);
}

+ (Direction)directionFromPosition:(CGPoint)fromPos toPosition:(CGPoint)toPos
{
  if (fromPos.x == toPos.x) {
    if (toPos.x > fromPos.x) {
      return kDirectionEast;
    }else {
      return kDirectionWest;
    }
  }else if (fromPos.y == toPos.y) {
    if (toPos.y > fromPos.y) {
      return kDirectionNorth;
    }else {
      return kDirectionSouth;
    }
  }else {
    [NSException raise:@"Invalid Input"
                format:@"Must provide a toPosition that is in a single direction"];
  }
  
  return kDirectionNorth;
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

@end
