//
//  DSCharater.m
//  sunny
//
//  Created by Draco on 2013-08-20.
//  Copyright 2013 Draco. All rights reserved.
//

#import "DSCharater.h"
#import "DSLayer.h"
#import "DSCocosHelpers.h"
#import "CCAnimate+SequenceLoader.h"
#import "DSChatBox.h"

@interface DSCharater ()

@property (nonatomic, strong) CCSprite *balloon;

// State related properties
@property (nonatomic) BOOL isJumping;

// General character properties
@property (nonatomic, copy) NSString *initialFrameName;
@property (nonatomic, readonly) CGRect feetRect;
@property (nonatomic, readonly) CGRect feetRectInParent;
- (CGRect)feetRectForPosition:(CGPoint)position;

- (void)playWalkAnimationToTarget:(CGPoint)target;
- (void)playWalkAnimationToDirection:(Direction)direction
                             inSteps:(NSInteger)step;
- (NSString *)baseFrameName;


/**
 * This method requires some explanation.
 *
 * In terms of walk on a tileset we want to make sure that the character
 * can walk to the closest position to the target. This means that if there
 * are obsticles in the way then the adjusted final position will not be the target
 * since the character will not be able to reach the target due to the obsticle.
 *
 * Thus this method will take those collisions into consideration and return
 * the closest position the character can walk to without collision with any of
 * our objectects. Futhermore since we only use the character's feed at the collision
 * area for this character the bounding of the character can be in a colliable
 * tile as long as its feet's bounding box is within a valid tile.
 *
 * If the returned CGPoint is the same as the character's position then this means
 * the character can not move anymore.
 */
- (CGPoint)adjustedWalkablePositionToTarget:(CGPoint)target;

/**
 * A helper method that returns the closest position that the character can walk
 * to for a target blocked tile coordnate in a certain direction.
 * This uses the character's feet bounding box to determine the closest character
 * position to the blocked tile;
 */
- (CGPoint)bestWalkablePositionForBlockedRect:(CGRect)blockedRect
                                  inDirection:(Direction)direction;

/**
 * Pass in a blocked tile and this will return a cgrect if a part of the tile
 * is disabled for collision explicitly by us. The rect will be zero if nothing
 * is disabled and the same rect as the tile if everything is disabled.
 */
- (CGRect)disabledCollisionRectForBlockedTiledCoord:(CGPoint)tileCoord;
- (CGRect)blockedRectForBlockedTileCoord:(CGPoint)blockedTileCoord;
- (BOOL)isTileCoordBlockedForCurrentCharacter:(CGPoint)tileCoord
                           inWalkingDirection:(Direction)direction;

@end

@implementation DSCharater

+ (id)characterWithSpriteFrameName:(NSString *)frameName
                             atPos:(CGPoint)pos
                        onMapLayer:(DSLayer *)layer
{
  return [[self alloc] initWithSpriteFrameName:frameName
                                         atPos:pos
                                    onMapLayer:layer];
}

- (id)initWithSpriteFrameName:(NSString *)frameName
                        atPos:(CGPoint)pos
                   onMapLayer:(DSLayer *)layer
{
  self = [super init];
  if (self) {
    // Create character sprite and position it
    _initialFrameName = frameName;
    _sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    _sprite.position = pos;
    _sprite.scale = 1;
    _direction = kDirectionSouth;
    
    /**
     * The character position is determined by where its feet is at,
     * Thus when setting the anchor point we set it at the top of the
     * character's feet section. This way the character's feet can be at
     * a valid tile while its body is in over a collidable object
     */
    _sprite.anchorPoint = ccp(0.5, 0.2);
    
    // Load in user balloons
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"balloon.plist"];
    
    // Add character sprite to this character's tile map
    _mapLayer = layer;
  }
  return self;
}


#pragma mark - Character travelling related

- (void)goToTarget:(CGPoint)target {
  [self goToTarget:target withSpeedMultiplier:1];
}

// Currently goToTarget does not handle going to a target that is not
// in direct direction with the target and when there's something blocking the way
- (void)goToTarget:(CGPoint)target withSpeedMultiplier:(CGFloat)multiplier
{
  CGPoint source = self.sprite.position;
  
  // Make sure target is in a direct direction from current position
  [DSCocosHelpers validateTargetIsInDirectDirection:target fromSource:source];
  
  // Get target direction
  Direction direction = [DSCocosHelpers directionToPosition:target
                                               fromPosition:source];
  
  // Perform walk
  CGFloat distance = ccpDistance(self.sprite.position, target);
  [self walk:distance inDirection:direction withSpeedMultiplier:multiplier];
}

- (void)takeSteps:(NSInteger)steps towardsDirection:(Direction)direction
{
  CGFloat distance = steps * kCharacterDistancePerStep;
  [self walk:distance inDirection:direction];
}

- (void)walk:(CGFloat)distance inDirection:(Direction)direction {
  [self walk:distance inDirection:direction withSpeedMultiplier:1];
}

- (void)walk:(CGFloat)distance inDirection:(Direction)direction withSpeedMultiplier:(CGFloat)multiplier
{
  NSLog(@"character is now gonna walk %.1fpx towards direction %i", distance, direction);
  
  // Whether or not we can walk, we turn first
  self.direction = direction;
  
  // Figure out final direction
  CGPoint startPos = self.sprite.position;
  CGPoint diffPos = ccpMult([DSCocosHelpers positionDiffForDirection:direction], distance);
  CGPoint finalPos = ccpAdd(startPos, diffPos);
  
  // Collision detection
  CGPoint adjustedPos = [self bestWalkablePositionFromPos:self.sprite.position
                                                    toPos:finalPos];
  if (CGPointEqualToPoint(self.sprite.position, adjustedPos)) {
    // This character cannot move anymore
    // TODO: optionally play walk animation as long as we are trying to walk.
    //       of course the implementaion of this wont be specially in here.
    if (kShouldPlayWalkAnimationWhenBlocked) {
      [self playWalkAnimationToDirection:direction inSteps:1];
    }
    return;
  }
  
  [self stopAllAnimations];
  
  // Start character walk animation
  // This method will determine how many steps to take to animate walk to that pos
  [self playWalkAnimationToTarget:adjustedPos];
  
  // Perform walk to the final destination with adjusted speed multiplier
  CGFloat adjustedDistance = ccpDistance(startPos, adjustedPos);
  CGFloat adjustedDistancePerStep = kCharacterDistancePerStep * multiplier;
  ccTime duration = (adjustedDistance / adjustedDistancePerStep) * kCharacterSpeedPerStep;
  id moveAction = [CCMoveTo actionWithDuration:duration position:adjustedPos];
  [self.sprite runAction:[CCSequence actions:moveAction, nil]];
}

# pragma mark - Chracter animation related

- (void)rotateToTarget:(CGPoint)target
{
  // Figure out the direction of the target
  Direction targetDirection = [DSCocosHelpers directionToPosition:target
                                                     fromPosition:self.sprite.position];
  self.direction = targetDirection;
}

- (void)animateWalkInSamePosition
{
  [self playWalkAnimationToDirection:self.direction inSteps:NSIntegerMax];
}

- (void)setDirection:(Direction)direction
{
  _direction = direction;
  
  // Update character sprite to reflect the direction change
  NSString *directionFrame = [NSString stringWithFormat:@"%@_%@_00.png",
                              self.baseFrameName,
                              [DSCocosHelpers stringFromDirection:direction]];
  CCSpriteFrame *newSprite = [[CCSpriteFrameCache sharedSpriteFrameCache]
                              spriteFrameByName:directionFrame];
  [self.sprite setDisplayFrame:newSprite];
}

- (void)jump
{
  if (self.isJumping) {
    return;
  }
  
  // A basic implementation of the jump effect. Can be improved I think...
  id moveDown = [CCMoveTo actionWithDuration:kCharacterJumpSpeed/2
                                    position:self.sprite.position];
  id moveUp = [CCMoveBy actionWithDuration:kCharacterJumpSpeed/2
                                  position:CGPointMake(0, kCharacterJumpHeight)];
  __block DSCharater *weakSelf = self;
  CCCallBlock *final = [CCCallBlock actionWithBlock:^(){
    weakSelf.isJumping = NO;
  }];
  
  [self.sprite runAction:[CCSequence actions:moveUp, moveDown, final, nil]];
  self.isJumping = YES;
  
  // TODO: Play jump sound
}

- (void)showBalloon:(BalloonType)balloonType
        forDuration:(ccTime)duration
           animated:(BOOL)animated
    speedMultiplier:(CGFloat)multiplier
{
  // Make sure we clean up any existing balloons
  if (self.balloon) {
    [self.balloon removeFromParentAndCleanup:YES];
  }
  
  // Get all balloon image names
  int balloonCount = 8;
  NSString *balloonAnimation = [NSString stringWithFormat:@"balloon_%i_%%02d.png", balloonType];
  
  // Add balloon to character's head
  CGPoint charPos = self.sprite.position;
  NSString *lastBallonName = [NSString stringWithFormat:balloonAnimation, balloonCount - 1];
  self.balloon = [CCSprite spriteWithSpriteFrameName:lastBallonName];
  self.balloon.anchorPoint = ccp(0.5, 0);
  self.balloon.position = CGPointMake(charPos.x + 8,
                                      charPos.y + 28);
  [self.mapLayer addChild:self.balloon z:kCharacterZIndex + 1];
  
  // Animate in and out the balloon
  id moveBalloon = [CCMoveBy actionWithDuration:0.07
                                       position:CGPointMake(0, 5)];
  id balloonWait = [CCDelayTime actionWithDuration:duration];
  __block CCSprite *myBalloon = self.balloon;
  id cleanUp = [CCCallBlock actionWithBlock:^() {
    [myBalloon removeFromParentAndCleanup:YES];
    myBalloon = nil;
  }];
  [self.balloon runAction:[CCSequence actions:moveBalloon, balloonWait, cleanUp, nil]];
  
  // Animate the balloon
  if (animated) {
    CCActionInterval *action = [CCAnimate
                                actionWithSpriteSequence:balloonAnimation
                                numFrames:balloonCount
                                delay:0.1
                                restoreOriginalFrame:NO];
    [self.balloon runAction:action];
  }
}

- (void)stopAllAnimations
{
  [self.sprite stopAllActions];
}


#pragma mark - Talking related methods

- (void)sayWords:(NSString *)words
{
  // Remove any existing chatboxes
  [self.mapLayer cleanupChatBox];
  
  // Create and show new chatbox
  self.mapLayer.chatbox = [[DSChatBox alloc] initWithCharacter:self
                                                          text:words
                                                         layer:self.mapLayer];
  [self.mapLayer showChatBox];
}


#pragma mark - Others

- (void)update:(ccTime)dt
{
  [super update:dt];
  
  // Set character zOrder to above foreground unless its enabled by objects layer
  int correctZOrder = 0;
  if ([self.mapLayer isForegroundEnabledForRect:self.feetRectInParent]) {
    correctZOrder = self.mapLayer.foregroundLayer.zOrder - 1;
  }else {
    correctZOrder = self.mapLayer.foregroundLayer.zOrder + 1;
  }
  if (self.sprite.zOrder != correctZOrder) {
    self.sprite.zOrder = correctZOrder;
  }
}


#pragma Private methods

- (void)playWalkAnimationToTarget:(CGPoint)target
{
  // Figure out the animation direction
  Direction direction = [DSCocosHelpers directionToPosition:target
                                               fromPosition:self.sprite.position];
  
  // Figure out how many steps we need to take
  CGFloat distance = ccpDistance(self.sprite.position, target);
  NSUInteger steps = ceilf(distance / kCharacterDistancePerStep);
  NSLog(@"character is now gonna animate %i steps", steps);
  
  [self playWalkAnimationToDirection:direction inSteps:steps];
}

- (void)playWalkAnimationToDirection:(Direction)direction
                             inSteps:(NSInteger)step
{
  // Construct the single step animation sequence
  NSString *dirString = [DSCocosHelpers stringFromDirection:direction];
  NSString *walkCycle = [NSString stringWithFormat:@"%@_%@_%%02d.png",
                         self.baseFrameName, dirString];
  CCActionInterval *action = [CCAnimate
                              actionWithSpriteSequence:walkCycle
                              numFrames:kCharacterWalkAnimationFrames
                              delay:kCharacterSpeedPerStep/kCharacterWalkAnimationFrames
                              restoreOriginalFrame:YES];
  
  // Play walk animation for all steps
  id walkAction = 0;
  if (step == NSIntegerMax) {
    walkAction = [CCRepeatForever actionWithAction:action];
  }else {
    walkAction = [CCRepeat actionWithAction:action times:step];
  }
  
  //  CCAction *doneAction = [CCCallFuncN actionWithTarget:self selector:@selector(heroIsDoneWalking)];
  [self.sprite runAction:[CCSequence actions:walkAction, nil]];
}

- (NSString *)baseFrameName
{
  NSRange rangeOfName = [self.initialFrameName rangeOfString:@"_"];
  return [self.initialFrameName substringToIndex:rangeOfName.location];
}

- (CGRect)feetRect
{
  CGRect box = self.sprite.boundingBox;
  return CGRectMake(0, 0, box.size.width,
                    box.size.height * self.sprite.anchorPoint.y);
}

- (CGRect)feetRectForPosition:(CGPoint)pos
{
  CGRect selfBox = self.feetRect;
  return CGRectMake(pos.x - selfBox.size.width * self.sprite.anchorPoint.x,
                    pos.y - selfBox.size.height,
                    selfBox.size.width, selfBox.size.height);
}

- (CGRect)feetRectInParent
{
  return [self feetRectForPosition:self.sprite.position];
}

- (CGPoint)bestWalkablePositionForBlockedRect:(CGRect)blockedRect
                                  inDirection:(Direction)direction
{
  CGPoint sourcePos = self.sprite.position;
  if (direction == kDirectionNorth)
  {
    return CGPointMake(sourcePos.x, blockedRect.origin.y);
  }
  else if (direction == kDirectionSouth)
  {
    CGFloat newY = blockedRect.origin.y + \
    blockedRect.size.height + \
    self.feetRect.size.height;
    return CGPointMake(sourcePos.x, newY);
  }
  else if (direction == kDirectionEast)
  {
    CGFloat newX = blockedRect.origin.x - self.feetRect.size.width * 0.5;
    return CGPointMake(newX, sourcePos.y);
  }
  else if (direction == kDirectionWest)
  {
    CGFloat newX = blockedRect.origin.x + \
    blockedRect.size.width + \
    self.feetRect.size.width * 0.5;
    return CGPointMake(newX, sourcePos.y);
  }
  
  [NSException raise:@"Invalid Argument Provided"
              format:@"We should never get here"];
  return CGPointZero;
}

- (CGRect)disabledCollisionRectForBlockedTiledCoord:(CGPoint)tileCoord
{
  CGRect result = CGRectZero;
  
  // Get any collision objects in that tile
  NSDictionary *disabledObject = [self.mapLayer disabledCollisionObjectForTileCoord:tileCoord];
  if (disabledObject) {
    CGRect disabledRect = [DSCocosHelpers rectFromObjectDictionary:disabledObject];
    CGRect tileRect = [DSCocosHelpers rectForTileCoord:tileCoord
                                             onTileMap:self.mapLayer.tileMap];
    result = CGRectIntersection(disabledRect, tileRect);
  }
  
  return result;
}

- (CGRect)blockedRectForBlockedTileCoord:(CGPoint)blockedTileCoord
{
  CGRect blockedTileRect = [DSCocosHelpers rectForTileCoord:blockedTileCoord
                                                  onTileMap:self.mapLayer.tileMap];
  CGRect disabledCollisionRect = [self disabledCollisionRectForBlockedTiledCoord:blockedTileCoord];
  
  // Return empty blocked rect if all is disabled
  if (CGRectEqualToRect(disabledCollisionRect, blockedTileRect)) {
    return CGRectZero;
  }
  
  // Return all of blocked rect if disabled rect is empty
  if (CGRectIsEmpty(disabledCollisionRect)) {
    return blockedTileRect;
  }
  
  // Handle when disabledRect is a slice of the blockedTileRect
  CGFloat x1 = blockedTileRect.origin.x, y1 = blockedTileRect.origin.y, \
  w1 = blockedTileRect.size.width, h1 = blockedTileRect.size.height;
  CGFloat x2 = disabledCollisionRect.origin.x, y2 = disabledCollisionRect.origin.y, \
  w2 = disabledCollisionRect.size.width, h2 = disabledCollisionRect.size.height;
  
  CGFloat newY, newX, newWidth, newHeight;
  if (x1 == x2 && y1 == y2 && w1 == w2 && h1 != h2)
  {
    newX = x1;
    newY = y1 + h2;
    newWidth = w1;
    newHeight = h1 - h2;
  }
  else if (x1 == x2 && y1 != y2 && w1 == w2 && h1 != h2)
  {
    newX = x1;
    newY = y1;
    newWidth = w1;
    newHeight = h1 - h2;
  }
  else if (x1 == x1 && y1 == y2 && w1 != w2 && h1 == h2)
  {
    newX = x1 + w2;
    newY = y1;
    newWidth = w1 - w2;
    newHeight = h1;
  }
  else if (x1 != x2 && y1 == y2 && w1 != w2 && h1 == h2)
  {
    newX = x1;
    newY = y1;
    newWidth = w1 - w2;
    newHeight = h1;
  }
  else
  {
    [NSException raise:@"Invalid Disabled Rectable!" format:@"The disabled rectable should only slice the tile rect!"];
  }
  
  // Return the part of the blocked tile rect that is not the disabledCollsionRect
  return CGRectMake(newX, newY, newWidth, newHeight);
}

- (BOOL)isTileCoordBlockedForCurrentCharacter:(CGPoint)tileCoord
                           inWalkingDirection:(Direction)direction
{
  /**
   * A tile coordinate is blocked if the following things are true:
   *
   * 1. The tile coordinate is marked as blocked by the meta layer
   * 2. For the blocked section of the blocked tile (section after considering
   *    the collision disabling effect), the character will not be able to
   *    walk through it if continuing in that direction.
   */
  
  
  // Check #1
  if (![self.mapLayer isTileCoordBlocked:tileCoord]) {
    return NO;
  }
  
  // Check #2
  CGRect blockedRect = [self blockedRectForBlockedTileCoord:tileCoord];
  
  // Any empty blocked rect will never block the character
  if (CGRectIsEmpty(blockedRect)) {
    return NO;
  }
  
  // Check if the character's feet would intersect the blockedRect
  // if the character keeps walking that that direction. If it does intersect
  // then this tile will block the character
  CGRect characterRect = self.feetRectInParent;
  if (direction == kDirectionNorth || direction == kDirectionSouth)
  {
    if ((blockedRect.origin.x + blockedRect.size.width) > characterRect.origin.x &&
        blockedRect.origin.x < (characterRect.origin.x + characterRect.size.width)) {
      return YES;
    }
  }
  else if (direction == kDirectionEast || direction == kDirectionWest)
  {
    if ((blockedRect.origin.y + blockedRect.size.height) > characterRect.origin.y &&
        blockedRect.origin.y < (characterRect.origin.y + characterRect.size.height)) {
      return YES;
    }
  }
  
  return NO;
}

- (CGPoint)bestWalkablePositionFromPos:(CGPoint)fromPos toPos:(CGPoint)toPos
{
  /**
   * A character can walk from a to b only if these things are met:
   * 1. There are no blocked tiles in between (including the character's current tile
   * 2. There are no collision objects in between that will intersect with our
   *    character's feet.
   *
   * If these two conditions are not met, we find the best walkable position
   * from the closect blocked rect (could be a blocked tile or from a collision 
   * object.
   */
  BOOL toPosAdjusted = NO;
  CGPoint bestPos = CGPointZero;
  Direction direction = [DSCocosHelpers directionToPosition:toPos
                                               fromPosition:fromPos];
  
  
  // Check for blocked tiles from a to b. If there are any, take the closect one.
  CGRect blockedRect = [self getClosestBlockedRectPassedFromPos:fromPos
                                                          toPos:toPos
                                                    inDirection:direction];
  if (!CGRectIsEmpty(blockedRect)) {
    toPosAdjusted = YES;
    bestPos = [self bestWalkablePositionForBlockedRect:blockedRect
                                           inDirection:direction];
  }
  
  // Check for collision objects from a to b. If there is one, get best pos
  CGRect start = [self feetRectForPosition:fromPos];
  CGRect end = [self feetRectForPosition:toPos];
  CGRect travelRect = CGRectUnion(start, end);
  CGRect collisionRect = [self.mapLayer closestCollisionObjectRectInRect:travelRect
                                                               direction:direction];
  if (!CGRectIsEmpty(collisionRect)) {
    CGPoint collisionObjectBest = [self bestWalkablePositionForBlockedRect:collisionRect
                                                               inDirection:direction];
    
    // Since we might have an adjusted position from blocked tile, we need to take
    // that into consideration when setting our best position. Best position
    // can only be the closest one.
    if (toPosAdjusted) {
      CGPoint combinedBest = [DSCocosHelpers closestPostionForDirection:direction
                                                                     p1:collisionObjectBest
                                                                     p2:bestPos];
      bestPos = combinedBest;
    }else {
      bestPos = collisionObjectBest;
    }
    toPosAdjusted = YES;
  }
  
  // Return the best pos
  if (!toPosAdjusted) {
    return toPos;
  }
  return bestPos;
}

- (CGRect)getClosestBlockedRectPassedFromPos:(CGPoint)fromPos
                                       toPos:(CGPoint)toPos
                                 inDirection:(Direction)direction
{
  NSArray *tileCoords = [self getAllTileCoordinatesPassedFromPos:fromPos
                                                           toPos:toPos];
  
  // Process all tiles for closest blocked tile
  CGRect blockedRect = CGRectZero;
  int best = -1;
  for (int i = 0; i < [tileCoords count]; i++)
  {
    CGPoint tileCoord = [[tileCoords objectAtIndex:i] CGPointValue];
    
    // Only process blocked tiles
    if (![self.mapLayer isTileCoordBlocked:tileCoord]) {
      continue;
    }
    
    // Best is not initalized yet, make this blocked tile the best
    if (best == -1) {
      best = i;
      continue;
    }
    
    // Multiple blocked tiles, find the closest one
    CGPoint bestCoord = [[tileCoords objectAtIndex:best] CGPointValue];
    switch (direction) {
      case kDirectionNorth:
        if (tileCoord.y > bestCoord.y) {
          best = i;
        }
        break;
      case kDirectionEast:
        if (tileCoord.x < bestCoord.x) {
          best = i;
        }
        break;
      case kDirectionSouth:
        if (tileCoord.y < bestCoord.y) {
          best = i;
        }
        break;
      case kDirectionWest:
        if (tileCoord.x > bestCoord.x) {
          best = i;
        }
        break;
      default:
        [NSException raise:@"Invalid Direction" format:@"bad direction"];
    }
  }
  
  // Get the rect for the closest blocked tile
  if (best >= 0) {
    CGPoint bestTileCoord = [[tileCoords objectAtIndex:best] CGPointValue];
    blockedRect = [DSCocosHelpers rectForTileCoord:bestTileCoord
                                         onTileMap:self.mapLayer.tileMap];
  }
  
  return blockedRect;
}

- (NSArray *)getAllTileCoordinatesPassedFromPos:(CGPoint)fromPos toPos:(CGPoint)toPos
{
  int maxTiles = ceilf(self.mapLayer.tileSize.width * self.mapLayer.tileSize.height);
  NSMutableArray *results = [NSMutableArray arrayWithCapacity:maxTiles];
  
  Direction direction = [DSCocosHelpers directionToPosition:toPos
                                               fromPosition:fromPos];
  
  // Get from to coord
  CCTMXTiledMap *tileMap = self.mapLayer.tileMap;
  CGPoint fromCoord = [DSCocosHelpers tileCoordForPosition:fromPos
                                                   tileMap:tileMap];
  CGPoint toCoord = [DSCocosHelpers tileCoordForPosition:toPos
                                                 tileMap:tileMap];
  
  // Handle stepping on an adjacent tile
  BOOL intersetsAdjacentTile = NO;
  CGPoint adjacentTileAdjustment = CGPointZero;
  CGRect initialBoundingBox = [self feetRectForPosition:fromPos];
  if (direction == kDirectionNorth || direction == kDirectionSouth)
  {
    // Get adjustment points for left and right
    CGPoint leftPoint = [DSCocosHelpers tileCoordDiffForDirection:kDirectionWest];
    CGPoint rightPoint = [DSCocosHelpers tileCoordDiffForDirection:kDirectionEast];
    
    // Consider the left and right adjacent tiles
    CGPoint leftTile = ccpAdd(fromCoord, leftPoint);
    CGPoint rightTile = ccpAdd(fromCoord, rightPoint);
    if ([DSCocosHelpers rectIntersectsWithTileCoord:leftTile
                                               rect:initialBoundingBox
                                          onTileMap:tileMap])
    {
      intersetsAdjacentTile = YES;
      adjacentTileAdjustment = leftPoint;
    }
    else if ([DSCocosHelpers rectIntersectsWithTileCoord:rightTile
                                                    rect:initialBoundingBox
                                               onTileMap:tileMap])
    {
      intersetsAdjacentTile = YES;
      adjacentTileAdjustment = rightPoint;
    }
  }
  else
  {
    // Get adjustment points for top and bot
    CGPoint topPoint = [DSCocosHelpers tileCoordDiffForDirection:kDirectionNorth];
    CGPoint botPoint = [DSCocosHelpers tileCoordDiffForDirection:kDirectionSouth];
    
    // Consider the top and bototm adjacent tiles
    CGPoint topTile = ccpAdd(fromCoord, topPoint);
    CGPoint botTile = ccpAdd(fromCoord, botPoint);
    if ([DSCocosHelpers rectIntersectsWithTileCoord:topTile
                                               rect:initialBoundingBox
                                          onTileMap:tileMap])
    {
      intersetsAdjacentTile = YES;
      adjacentTileAdjustment = topPoint;
    }
    else if ([DSCocosHelpers rectIntersectsWithTileCoord:botTile
                                                    rect:initialBoundingBox
                                               onTileMap:tileMap])
    {
      intersetsAdjacentTile = YES;
      adjacentTileAdjustment = botPoint;
    }
  }
  
  // Handle toPos's feet box also intersects with next tile
  CGPoint tileIncrement = [DSCocosHelpers tileCoordDiffForDirection:direction];
  CGRect targetBoundingBox = [self feetRectForPosition:toPos];
  CGPoint nextTileCoord = ccpAdd(toCoord, tileIncrement);
  BOOL charIntersetsNext = [DSCocosHelpers rectIntersectsWithTileCoord:nextTileCoord
                                                                  rect:targetBoundingBox
                                                             onTileMap:tileMap];
  
  
  // Get all of the tiles we pass through
  CGPoint diff = ccpSub(toCoord, fromCoord);
  int tilesToCheck = abs(diff.y + diff.x);
  tilesToCheck += charIntersetsNext ? 1 : 0;
  CGPoint prevTileCoord = fromCoord;
  for (int i = 0; i < tilesToCheck + 1; i++) { // Add 1 to always check current tile
    // Get target tile coord
    CGPoint tileCoord = prevTileCoord;
    if (i != 0) {
      tileCoord = ccpAdd(prevTileCoord, tileIncrement);
    }
    
    // Add current tile coord
    [results addObject:[NSValue valueWithCGPoint:tileCoord]];
    
    // Handle adjacent tile
    if (intersetsAdjacentTile) {
      CGPoint adjacentTileCoord = ccpAdd(tileCoord, adjacentTileAdjustment);
      [results addObject:[NSValue valueWithCGPoint:adjacentTileCoord]];
    }
  }
  
  return results;
}

@end
