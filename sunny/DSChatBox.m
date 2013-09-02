//
//  DSChatBox.m
//  sunny
//
//  Created by Draco on 2013-09-01.
//  Copyright 2013 Draco. All rights reserved.
//

#import "DSChatBox.h"
#import "DSCharater.h"
#import "CCSprite+GLBoxes.h"

@interface DSChatBox ()
@property (nonatomic, strong) NSMutableArray *textArray;
@property (nonatomic, strong) CCAutoTypeLabelBM *label;
@property (nonatomic, strong) CCSprite *arrowCursor;
@end

@implementation DSChatBox

- (id)initWithCharacter:(DSCharater *)character
                   text:(NSString *)text
                  layer:(CCLayer *)layer
{
  if (self = [super init])
  {
    _character = character;
    _textArray = [[text componentsSeparatedByString:@"\n"] mutableCopy];
    
    // Add background
    CCSprite *bg = [CCSprite rectangleOfSize:CGSizeMake(480, 40)
                                     withRed:0
                                       green:0
                                        blue:0
                                    andAlpha:0.75];
    bg.anchorPoint = ccp(0, 0);
    bg.position = ccp(0, 0);
    [self addChild:bg z:0];
    
    // Add text label
    _label = [CCAutoTypeLabelBM labelWithString:@"" fntFile:@"8bit-20.fnt"];
    [_label setDelegate:self];
    _label.anchorPoint = ccp(0, 0);
    _label.position = ccp(10,10);
    [self addChild:self.label z:1];
    
    if (_textArray.count > 0) {
      _arrowCursor = [CCSprite spriteWithSpriteFrameName:@"arrow-cursor.png"];
      _arrowCursor.anchorPoint = ccp(0, 0);
      _arrowCursor.position = ccp(bg.boundingBox.size.width - 20.0, 10);
      _arrowCursor.visible = NO;
      [self addChild:_arrowCursor z:2];
    }
    
    // Add chat box to map
    [layer addChild:self z:kChatBoxZIndex];
  }
  return self;
}

- (void)advanceTextOrFinish
{
  // Stop any existing blinking cursor
  if (self.arrowCursor) {
    [self.arrowCursor stopAllActions];
    self.arrowCursor.visible = NO;
  }
  
  // Close text box when no more text to display
  if(self.textArray.count == 0)
  {
    [self setVisible:NO];
    [self.parent removeChild:self cleanup:YES];
    return;
  }
  
  // Remove the text to be displayed from our text array
  NSString *text = self.textArray[0];
  [self.textArray removeObjectAtIndex:0];
  
  // Display the text
  NSString *message = [NSString stringWithFormat:@"%@: %@", self.character.name, text];
  [self.label typeText:message withDelay:0.02f];
  [self setVisible:YES];
}


#pragma mark - Delegate for auto type label

- (void)typingFinished:(CCAutoTypeLabelBM *)sender
{
  // If we have more text to display, show the arrow cursor
  if (self.textArray.count == 0) {
    return;
  }
  
  // Animate arrow cursor blinking
  id blink = [CCBlink actionWithDuration:5.0 blinks:5];
  [self.arrowCursor runAction:[CCRepeatForever actionWithAction:blink]];
//  self.arrowCursor.visible = YES; // this results in an quick blink in the beginning
}

@end
