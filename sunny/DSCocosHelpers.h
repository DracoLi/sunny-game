//
//  DSCocosHelpers.h
//  sunny
//
//  Created by Draco on 2013-08-22.
//  Copyright (c) 2013 Draco. All rights reserved.
//

#import "cocos2d.h"

@interface DSCocosHelpers : NSObject

// Tilemap related
+ (CGPoint)tileCoordForPosition:(CGPoint)position
                        tileMap:(CCTMXTiledMap *)tileMap;

+ (CGRect)rectForTileCoord:(CGPoint)tileCoord onTileMap:(CCTMXTiledMap *)tileMap;

+ (BOOL)rectIntersectsWithTileCoord:(CGPoint)tileCoord
                               rect:(CGRect)rect
                          onTileMap:(CCTMXTiledMap *)tileMap;

+ (CGRect)rectFromObjectDictionary:(NSDictionary *)dictionary;


// Direction related
+ (Direction)directionToPosition:(CGPoint)fromPos fromPosition:(CGPoint)toPos;
+ (NSString *)stringFromDirection:(Direction)direction;
+ (CGPoint)tileCoordDiffForDirection:(Direction)direction;
+ (CGPoint)positionDiffForDirection:(Direction)direction;
+ (CGPoint)closestPostionForDirection:(Direction)direction
                                   p1:(CGPoint)p1
                                   p2:(CGPoint)p2;


/**
 * Check if target potion is in a direct direction from the source position
 */
+ (void)validateTargetIsInDirectDirection:(CGPoint)target
                               fromSource:(CGPoint)source;
+ (BOOL)isTargetInDirectDirection:(CGPoint)target
                       fromSource:(CGPoint)source;

@end
