//
//  DSLayer.h
//  sunny
//
//  Created by Draco on 2013-08-23.
//  Copyright 2013 Draco. All rights reserved.
//

#import "cocos2d.h"

@class DSCharater, DSChatBox;

@interface DSLayer : CCLayer
@property (nonatomic, strong) CCTMXTiledMap *tileMap;
@property (nonatomic, strong) CCTMXLayer *foregroundLayer;
@property (nonatomic) CGSize tileSize;
@property (nonatomic, strong) CCSpriteBatchNode *batchNode;
@property (nonatomic, strong) DSChatBox *chatbox;

// Touch related
@property (nonatomic) BOOL isTouching;
@property (nonatomic) CGPoint currentTouchLocation;

- (id)initWithTileMapName:(NSString *)mapName;

/**
 * Get the collision object that interests with a tile coordinate
 */
- (NSDictionary *)disabledCollisionObjectForTileCoord:(CGPoint)tileCoord;

/**
 * Returns true if the foreground is explicitly disabled for a rect
 */
- (BOOL)isForegroundEnabledForRect:(CGRect)rect;

- (CGRect)closestCollisionObjectRectInRect:(CGRect)rect
                                 direction:(Direction)direction;

/**
 * Returns true if a tile coordinate is blocked, not factoring if its disabled
 */
- (BOOL)isTileCoordBlocked:(CGPoint)tileCoord;

/**
 * Chat box related
 */
- (void)showChatBox;
- (void)dismissChatBox;

@end
