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
@property (nonatomic) CGSize tileSize;
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
  self = [super init];
  if (self) {
    // Load in map and set in helper vars
    self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"sunny-room.tmx"];
    self.tileMap.anchorPoint = ccp(0,0);
    [self.tileMap setScale:kGameScale];
    [self addChild:self.tileMap z:-1];
    self.metaLayer = [self.tileMap layerNamed:@"meta"];
    self.metaLayer.visible = NO;
    self.tileSize = self.tileMap.tileSize;
    
    // Load in batch node
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"main-chars.plist"];
    self.characterLayer = [CCSpriteBatchNode batchNodeWithFile:@"main-chars.png"
                                                  capacity:50];
    [self addChild:self.characterLayer z:kDefaultCharacterIndex];
    
    // Load in sunny and sunny mom
    self.sunny = [DSSunny characterAtPos:CGPointMake(340, 80) onMapLayer:self];
  }
  return self;
}


#pragma mark - Touch Delegate

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
  
  [self.sunny update:delta];
}

@end
