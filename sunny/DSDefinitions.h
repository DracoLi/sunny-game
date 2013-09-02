//
//  DSDefinitions.h
//  sunny
//
//  Created by Draco on 2013-08-20.
//  Copyright (c) 2013 Draco. All rights reserved.
//


// Configurations
#define kShouldPlayWalkAnimationWhenBlocked YES


#define kGameScale 1

#define kChatBoxZIndex 10


////// Character Contants //////
#define kCharacterZIndex 2

#define kCharacterJumpHeight  15 // In points
#define kCharacterJumpSpeed   0.23

// A character's default travel distance per step
#define kCharacterDistancePerStep 18

// A character's default speed per step in seconds
#define kCharacterSpeedPerStep  0.25

// A character's default frames for walk animations
#define kCharacterWalkAnimationFrames  3

typedef enum {
  kBallonTypeExclaimation = 0,
  kBallonTypeQuestion,
  kBallonTypeMusic,
  kBallonTypeHeart,
  kBallonTypeAnnoyed,
  kBallonTypeWaterDrip,
  kBallonTypeConfused,
  kBallonTypeDotDot,
  kBallonTypeLightBulb,
  kBallonTypeSleeping,
  kBallonTypeMAX
} BalloonType;

typedef enum {
  kDirectionNorth = 0,
  kDirectionEast,
  kDirectionSouth,
  kDirectionWest
} Direction;