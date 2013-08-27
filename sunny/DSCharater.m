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

@interface DSCharater ()
@property (nonatomic) ccTime moveTimer;
@property (nonatomic) CGPoint moveTarget;
@property (nonatomic, copy) NSString *initialFrameName;
@property (nonatomic, readonly) CGRect feetRect;
@property (nonatomic, readonly) CGRect feetRectInParent;

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
- (CGPoint)bestWalkablePositionForBlockedTileCoord:(CGPoint)tileCoord
                                       inDirection:(Direction)direction;

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
    
    // Add character sprite to this character's tile map
    _mapLayer = layer;
    [_mapLayer.characterLayer addChild:_sprite z:kDefaultCharacterIndex];
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

- (void)walk:(CGFloat)distance inDirection:(Direction)direction
                       withSpeedMultiplier:(CGFloat)multiplier
{
  NSLog(@"character is now gonna walk %.1fpx towards direction %i", distance, direction);
  
  // Whether or not we can walk, we turn first
  self.direction = direction;
  
  // Figure out final direction
  CGPoint diffPos = ccpMult([DSCocosHelpers positionDiffForDirection:direction], distance);
  CGPoint finalPos = ccpAdd(self.sprite.position, diffPos);
  
  // Collision detection
  CGPoint adjustedPos = [self adjustedWalkablePositionToTarget:finalPos];
  if (CGPointEqualToPoint(self.sprite.position, adjustedPos)) {
    // This character cannot move anymore
    // TODO: optionally play walk animation as long as we are trying to walk.
    //       of course the implementaion of this wont be specially in here.
    [self playWalkAnimationToDirection:direction inSteps:1];
    return;
  }
  
  [self stopAllAnimations];
  
  // Start character walk animation
  // This method will determine how many steps to take to animate walk to that pos
  [self playWalkAnimationToTarget:adjustedPos];
  
  // Perform walk to the final destination with adjusted speed multiplier
  CGFloat adjustedDistancePerStep = kCharacterDistancePerStep * multiplier;
  ccTime duration = (distance / adjustedDistancePerStep) * kCharacterSpeedPerStep;
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
  
}

- (void)showBallon:(BallonType)ballon
{
  
}

- (void)stopAllAnimations
{
  [self.sprite stopAllActions];
}


#pragma mark - Others

- (void)update:(ccTime)dt
{
  
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

- (CGRect)feetRectInParent
{
  CGRect selfBox = self.feetRect;
  return CGRectMake(self.sprite.position.x - selfBox.size.width * self.sprite.anchorPoint.x,
                    self.sprite.position.y - selfBox.size.height,
                    selfBox.size.width, selfBox.size.height);
}

- (CGPoint)adjustedWalkablePositionToTarget:(CGPoint)target
{
  // Make sure the target position is in the same direction
  [DSCocosHelpers validateTargetIsInDirectDirection:target
                                         fromSource:self.sprite.position];
  
  // Get some values we will need
  CGPoint sourcePos = self.sprite.position;
  CCTMXTiledMap *tileMap = self.mapLayer.tileMap;
  CGPoint startCoord = [DSCocosHelpers tileCoordForPosition:sourcePos
                                                    tileMap:tileMap];
  CGPoint destinationCoord = [DSCocosHelpers tileCoordForPosition:target
                                                          tileMap:tileMap];
  Direction direction = [DSCocosHelpers directionToPosition:target
                                               fromPosition:self.sprite.position];
  
  // Check if our character's feet's bounding box is also intersecting with
  // another adjacent tile. If thats the case, then we need to always consider
  // an adjacent tile when we are walking.
  BOOL intersetsAdjacentTile = NO;
  CGPoint adjacentTileAdjustment = CGPointZero;
  CGRect initialBoundingBox = self.feetRectInParent;
  if (direction == kDirectionNorth || direction == kDirectionSouth)
  {
    // Get adjustment points for left and right
    CGPoint leftPoint = [DSCocosHelpers tileCoordDiffForDirection:kDirectionWest];
    CGPoint rightPoint = [DSCocosHelpers tileCoordDiffForDirection:kDirectionEast];
    
    // Consider the left and right adjacent tiles
    CGPoint leftTile = ccpAdd(startCoord, leftPoint);
    CGPoint rightTile = ccpAdd(startCoord, rightPoint);
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
    CGPoint topTile = ccpAdd(startCoord, topPoint);
    CGPoint botTile = ccpAdd(startCoord, botPoint);
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
  
  // Loop through all tiles from current pos to target pos
  // If startCoord is same at destinationCoord then we are doing nothing here.
  // Note that we here assume that the destination coord is in a direct direction.
  CGPoint diff = ccpSub(destinationCoord, startCoord);
  CGPoint tileIncrement = [DSCocosHelpers tileCoordDiffForDirection:direction];
  
  CGPoint prevTileCoord = startCoord;
  for (int i = 0; i < abs(diff.y + diff.x); i++) {
    CGPoint currentTileCoord = ccpAdd(prevTileCoord, tileIncrement);
    
    // If we find a blocked tile on the way to target, we return the closest
    // point that the character can travel to in the last tile (which is valid)
    BOOL isBlocked = [self.mapLayer isTileCoordBlocked:currentTileCoord];
    
    // If our character interests with another tile while walking, then we check
    // if that tile is blocked as well if next tile is not blocked
    if (!isBlocked && intersetsAdjacentTile) {
      CGPoint adjacentTile = ccpAdd(currentTileCoord, adjacentTileAdjustment);
      isBlocked = [self.mapLayer isTileCoordBlocked:adjacentTile];
    }
    
    // If next tile (or its adjacent one if we are walking on it) is block,
    // then we return the best walkable position
    if (isBlocked) {
      CGPoint best = [self bestWalkablePositionForBlockedTileCoord:currentTileCoord
                                                       inDirection:direction];
      if (best.x > 98 && best.x < 103 && best.y > 126.00 && 128.00 < 131) {
        NSLog(@"HALT!");
      }
      NSLog(@"adjsuted best walk target is (%.2f, %.2f) vs (%.2f, %.2f)", best.x, best.y, target.x, target.y);
      return best;
    }
    
    prevTileCoord = currentTileCoord;
  }
  
  // Lastly we need to check if the final position's bounding box intersets with the next tile
  CGRect feedBox = self.feetRect;
  CGRect targetBoundingBox = CGRectMake(target.x - feedBox.size.width * 0.5,
                                        target.y - feedBox.size.height,
                                        feedBox.size.width,
                                        feedBox.size.height);
  CGPoint nextTileCoord = ccpAdd(destinationCoord, tileIncrement);
  
  
  /**
   * If our target position's final bounding box intersects with the next tile coord
   * in the walking direction, and the next tile (or its adjacent tile if the
   * character started on stepping on an adjacent tile) is also blocked then we
   * adjust our final position to the closest position to the next tile.
   *
   * This happens when our target destination point is in a valid tile but
   * our character's feet bounding box interests with the next tileCoordinate which
   * just happens to be blocked.
   *
   * This assumes that of course our characters bounding box will never insets
   * with more than 2 tiles in one direction or else this implementation fails.
   * In our case since our character's width is 32px and a tile's width is also 
   * 32px there's no way we can interest 3 tiles in one direction.
   */
  
  BOOL charIntersetsNext = [DSCocosHelpers rectIntersectsWithTileCoord:nextTileCoord
                                                                  rect:targetBoundingBox
                                                             onTileMap:tileMap];
  
  if (charIntersetsNext) {
    BOOL requireAdjustment = NO;
    if ([self.mapLayer isTileCoordBlocked:nextTileCoord]) {
      requireAdjustment = YES;
    }else if (intersetsAdjacentTile) {
      CGPoint adjacentNextTileCoord = ccpAdd(nextTileCoord, adjacentTileAdjustment);
      requireAdjustment = [self.mapLayer isTileCoordBlocked:adjacentNextTileCoord];
    }
    
    if (requireAdjustment) {
      CGPoint best = [self bestWalkablePositionForBlockedTileCoord:nextTileCoord
                                                       inDirection:direction];
      NSLog(@"adjsuted best walk target is (%.2f, %.2f) vs (%.2f, %.2f)", best.x, best.y, target.x, target.y);
      
      return best;
    }
  }

  // If we get there then we have no blocked tiles to our target and our
  // bounding box at our target also does not interests with any blocked tiles.
  // In this case we safely return the target pos
  NSLog(@"final position of (%.2f, %.2f) not adjusted", target.x, target.y);
  return target;
}

- (CGPoint)bestWalkablePositionForBlockedTileCoord:(CGPoint)tileCoord
                                       inDirection:(Direction)direction
{
  CGPoint sourcePos = self.sprite.position;
  CGRect blockTileCoordRect = [DSCocosHelpers rectForTileCoord:tileCoord
                                                     onTileMap:self.mapLayer.tileMap];
  
  
  if (direction == kDirectionNorth)
  {
    return CGPointMake(sourcePos.x, blockTileCoordRect.origin.y);
  }
  else if (direction == kDirectionSouth)
  {
    CGFloat newY = blockTileCoordRect.origin.y + \
                   blockTileCoordRect.size.height + \
                   self.feetRect.size.height;
    return CGPointMake(sourcePos.x, newY);
  }
  else if (direction == kDirectionEast)
  {
    CGFloat newX = blockTileCoordRect.origin.x - self.feetRect.size.width * 0.5;
    return CGPointMake(newX, sourcePos.y);
  }
  else if (direction == kDirectionWest)
  {
    CGFloat newX = blockTileCoordRect.origin.x + \
                   blockTileCoordRect.size.width + \
                   self.feetRect.size.width * 0.5;
    return CGPointMake(newX, sourcePos.y);
  }

  [NSException raise:@"Invalid Argument Provided"
              format:@"We should never get here"];
  return CGPointZero;
}

@end
