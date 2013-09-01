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

@interface DSLayer ()
@property (nonatomic, strong) CCTMXLayer *metaLayer;
@property (nonatomic, strong) CCTMXObjectGroup *collisionObjects;
@property (nonatomic, strong) CCTMXObjectGroup *enableForegroundObject;

@end

@implementation DSLayer

- (id)initWithTileMapName:(NSString *)mapName
{
  if (self = [super init]) {
    
    // Load in map
    _tileMap = [CCTMXTiledMap tiledMapWithTMXFile:
                    [NSString stringWithFormat:@"%@.tmx", mapName]];
    _tileMap.anchorPoint = ccp(0,0);
    [_tileMap setScale:kGameScale];
    [self addChild:self.tileMap z:-1];
    
    // Load in info object layers and meta layer
    _collisionObjects = [self.tileMap objectGroupNamed:@"additionalCollisions"];
    _enableForegroundObject = [self.tileMap objectGroupNamed:@"enableForeground"];
    _metaLayer = [self.tileMap layerNamed:@"meta"];
    _metaLayer.visible = NO;
    
    _tileSize = self.tileMap.tileSize;
    
    // We should have our main characters in every scene, so we load them by default
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"main-chars.plist"];
    
    // By default our character is below foreground unless otherwise told so
    _foregroundLayer = [self.tileMap layerNamed:@"foreground"];
    
    self.touchEnabled = YES;
    [self scheduleUpdate];
  }
  return self;
}

- (BOOL)isForegroundEnabledForRect:(CGRect)rect
{
  for (NSMutableDictionary *foregroundObject in self.enableForegroundObject.objects) {
    CGRect enableForegroundRect = [DSCocosHelpers rectFromObjectDictionary:foregroundObject];
    if (CGRectIntersectsRect(enableForegroundRect, rect)) {
      return YES;
    }
  }
  return NO;
}

- (CGRect)closestCollisionObjectRectInRect:(CGRect)rect direction:(Direction)direction
{
  NSMutableArray *collisionRects = [NSMutableArray array];
  for (NSMutableDictionary *collisionObject in self.collisionObjects.objects) {
    CGRect collisionRect = [DSCocosHelpers rectFromObjectDictionary:collisionObject];
    if (CGRectIntersectsRect(collisionRect, rect)) {
      CGRect intersectRect = CGRectIntersection(rect, collisionRect);
      [collisionRects addObject:[NSValue valueWithCGRect:intersectRect]];
    }
  }
  
  // Return empty rect if no collision objects
  if ([collisionRects count] == 0) {
    return CGRectZero;
  }
  
  // If just one collision object, return that.
  if ([collisionRects count] == 1) {
    return [[collisionRects objectAtIndex:0] CGRectValue];
  }
  
  // If more than one collision rects, return the closect one in direction
  int best = 0;
  for (int i = 1; i < [collisionRects count]; i++) {
    CGRect collisionRect = [[collisionRects objectAtIndex:i] CGRectValue];
    CGRect bestRect = [[collisionRects objectAtIndex:best] CGRectValue];
    
    switch (direction) {
      case kDirectionNorth:
        if (collisionRect.origin.y < bestRect.origin.y) {
          best = i;
        }
        break;
      case kDirectionEast:
        if (collisionRect.origin.x < bestRect.origin.x) {
          best = i;
        }
        break;
      case kDirectionSouth:
        if (collisionRect.origin.y > bestRect.origin.y) {
          best = i;
        }
        break;
      case kDirectionWest:
        if (collisionRect.origin.x > bestRect.origin.x) {
          best = i;
        }
        break;
      default:
        [NSException raise:@"valid direction" format:@"yep"];
    }
  }
  return [[collisionRects objectAtIndex:best] CGRectValue];
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

- (void)update:(ccTime)delta
{
  [super update:delta];
}

#pragma mark ccTouch Delegate


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  // Update current touch location
  UITouch *touch = [touches anyObject];
  CGPoint touchLocation = [[CCDirector sharedDirector] convertTouchToGL:touch];
  touchLocation = [self convertToNodeSpace:touchLocation];
  self.currentTouchLocation = touchLocation;
  self.isTouching = YES;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  self.currentTouchLocation = CGPointZero;
  self.isTouching = NO;
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
