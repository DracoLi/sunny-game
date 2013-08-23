//
//  DSDefinitions.h
//  sunny
//
//  Created by Draco on 2013-08-20.
//  Copyright (c) 2013 Draco. All rights reserved.
//


#define kDefaultCharacterIndex 2
#define kGameScale 1
#define kCharacterStepDistance 10


typedef enum {
  kBallonTypeExclaimation,
  kBallonTypeQuestion,
  kBallonTypeMusic,
  kBallonTypeHeart,
  kBallonTypeAnnoyed,
  kBallonTypeWaterDrip,
  kBallonTypeConfused,
  kBallonTypeDotDot,
  kBallonTypeLightBulb,
  kBallonTypeSleeping
} BallonType;

typedef enum {
  kDirectionNorth,
  kDirectionEast,
  kDirectionSouth,
  kDirectionWest
} Direction;