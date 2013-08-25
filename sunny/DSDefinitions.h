//
//  DSDefinitions.h
//  sunny
//
//  Created by Draco on 2013-08-20.
//  Copyright (c) 2013 Draco. All rights reserved.
//


#define kDefaultCharacterIndex 2
#define kGameScale 1


////// Character Contants //////

// A character's default travel distance per step
#define kCharacterDistancePerStep 10

// A character's default speed per step in seconds
#define kCharacterSpeedPerStep  0.65

// A character's default frames for walk animations
#define kCharacterWalkAnimationFrames  3

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
  kDirectionNorth = 0,
  kDirectionEast,
  kDirectionSouth,
  kDirectionWest
} Direction;