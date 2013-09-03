//
//  SceneOneLayer.m
//  sunny
//
//  Created by Draco on 2013-08-19.
//  Copyright 2013 Draco. All rights reserved.
//

#import "SceneOneLayer.h"
#import "DSSunny.h"
#import "DSChatBox.h"
#import "DSChoiceDialog.h"

@interface SceneOneLayer ()
@property (nonatomic, strong) DSSunny *sunny;
@property (nonatomic) BOOL hasDialog;
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
  self = [super initWithTileMapName:@"sunny-room"];
  if (self) {
    // Load in sunny and add it to map
    _sunny = [DSSunny characterAtPos:CGPointMake(340, 80) onMapLayer:self];
    _sunny.walkingDisabled = YES;
    [self.tileMap addChild:_sunny.sprite z:kCharacterZIndex];
  }
  return self;
}


#pragma mark - Touch Delegate

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super ccTouchesBegan:touches withEvent:event];
//  [self.sunny jump];
  int randBallon = arc4random_uniform(kBallonTypeMAX);
//  [self.sunny showBalloon:randBallon
//              forDuration:2.0 animated:YES speedMultiplier:1.0];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super ccTouchesEnded:touches withEvent:event];
  
  // Testing stuff
  
  // Test direction change
  //  self.sunny.direction = (self.sunny.direction + 1) % 4;
  
  // Test walking
//  [self.sunny animateWalkInSamePosition];
//  if (!self.chatbox.visible) {
//    [self.sunny sayWords:@"I like chicken and I cannot lie!\nDo you like chicken?\nOkay I should stop now lol"];
//  }
  
  // Test dialog
//  if (!self.hasDialog) {
//    NSArray *choices = @[@"Eat it", @"Smoke it", @"Smell it"];
//    DSChoiceDialog *dialog = [DSChoiceDialog dialogWithChoices:choices
//                                                          size:CGSizeMake(130, 120)];
//    dialog.anchorPoint = ccp(0, 0);
//    dialog.position = ccp(5, 100);
//    [self addChild:dialog z:kChatBoxZIndex + 1];
//    self.hasDialog = YES;
//  }
  
  // Test dialog in chatbox
  NSArray *words = @[@"Hey do you like chicken?",
                     @"If you tell me what chicken you like",
                     @"I'll give you a present!",
                     @"What chicken do you like?"];
  NSArray *choices = @[@"Spicy Chicken", @"Rotten Chicken", @"KFC", @"Grilled Chicken"];
  DSChatBox *dialog = [[DSChatBox alloc] initWithCharacter:self.sunny
                                                     words:words
                                                   choices:choices
                                                dialogSize:CGSizeMake(160, 140)];
  self.chatbox = dialog;
  [self showChatBox];
  self.hasDialog = YES;
}

- (void)update:(ccTime)delta
{
  [super update:delta];
  
  // Update sunny's walk animation
  [self.sunny update:delta];
}

@end
