//
//  DSCocosHelpers.h
//  sunny
//
//  Created by Draco on 2013-08-22.
//  Copyright (c) 2013 Draco. All rights reserved.
//

#import "cocos2d.h"

@interface DSCocosHelpers : NSObject

+ (CGPoint)tileCoordForPosition:(CGPoint)position
                        tileMap:(CCTMXTiledMap *)tileMap;
+ (CGPoint)positionForTileCoord:(CGPoint)tileCoord
                        tileMap:(CCTMXTiledMap *)tileMap;


+ (Direction)directionFromPosition:(CGPoint)fromPos toPosition:(CGPoint)toPos;

@end
