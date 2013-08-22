//
//  SceneOneLayer.m
//  sunny
//
//  Created by Draco on 2013-08-19.
//  Copyright 2013 Draco. All rights reserved.
//

#import "SceneOneLayer.h"

@interface SceneOneLayer ()
@property (nonatomic, strong) CCTMXTiledMap *tileMap;
@property (nonatomic, strong) CCTMXLayer *metaLayer;
@property (nonatomic) CGSize tileSize;
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
    
    // Load in sunny and sunny mom
    
    self.touchEnabled = YES;
    
    [self scheduleUpdate];
  }
  return self;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  NSLog(@"touch began");
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  NSLog(@"touch ended");
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  NSLog(@"touch moved");
}

@end
