//
//  DSLayer.h
//  sunny
//
//  Created by Draco on 2013-08-23.
//  Copyright 2013 Draco. All rights reserved.
//

#import "cocos2d.h"

@class DSCharater;

@interface DSLayer : CCLayer
@property (nonatomic, strong) CCTMXTiledMap *tileMap;
@property (nonatomic, strong) CCTMXLayer *metaLayer;
@property (nonatomic, strong) CCSpriteBatchNode *characterLayer;

@property (nonatomic) BOOL isTouching;
@property (nonatomic) CGPoint currentTouchLocation;

- (BOOL)isPositionBlocked:(CGPoint)position;
- (BOOL)isTileCoordBlocked:(CGPoint)tileCoord;
- (BOOL)canCharacter:(DSCharater *)character walkToPosition:(CGPoint)position;
@end
