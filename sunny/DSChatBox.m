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
@property (nonatomic, strong) DSChoiceDialog *dialog;
@property (nonatomic) CGSize dialogSize;

- (void)showChoiceDialog;
@end

@implementation DSChatBox

- (id)initWithCharacter:(DSCharater *)character
                  words:(NSArray *)words
{
  if (self = [self initWithCharacter:character
                               words:words
                             choices:nil
                          dialogSize:CGSizeZero]) {
  }
  return self;
}

- (id)initWithCharacter:(DSCharater *)character
                  words:(NSArray *)words
                choices:(NSArray *)choices
             dialogSize:(CGSize)size
{
  if (self = [super init])
  {
    _character = character;
    _textArray = [words mutableCopy];
    _choices = choices;
    _dialogSize = size;
    
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
    
    // Responds to touch
    [[[CCDirector sharedDirector] touchDispatcher]
     addTargetedDelegate:self priority:kSelectableLabelTouchPriority + 1 swallowsTouches:YES];
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
    [self removeChatBox];
    return;
  }
  
  // Remove the text to be displayed from our text array
  NSString *text = self.textArray[0];
  [self.textArray removeObjectAtIndex:0];
  
  // Display the text
  NSString *message = [NSString stringWithFormat:@"%@: %@", self.character.name, text];
  [self.label typeText:message withDelay:0.02f];
  [self setVisible:YES];
  
  // Check if we need to display any choice dialogs
  if (self.textArray.count == 0 && self.choices && self.choices.count > 0) {
    [self showChoiceDialog];
  }
}

- (void)showChoiceDialog
{
  self.dialog = [[DSChoiceDialog alloc] initWithChoices:self.choices
                                                   size:self.dialogSize];
  self.dialog.anchorPoint = ccp(0, 0);
  self.dialog.position = ccp(5, 100);
  self.dialog.delegate = self;
  [self addChild:self.dialog z:2];
}

- (void)removeChatBox
{
  self.visible = NO;
  [self.parent removeChild:self cleanup:YES];
  
  // Remove any delegate references
  if (self.dialog) {
    self.dialog.delegate = nil;
  }
}


#pragma mark - Delegate for auto type label

- (void)typingFinished:(CCAutoTypeLabelBM *)sender
{
  // If we have more text to display, show the arrow cursor
  if (self.textArray.count == 0) {
    return;
  }
  
  // Animate arrow cursor blinking
  // Since there a delay when using use ccblink, we animate the first blink
  // separately using a delay and then start our inifinite blinking in a callblock
  // See issue #2
  id blink = [CCBlink actionWithDuration:5.0 blinks:5.0 / kChatBoxCursorBlinkFrequency];
  __block CCSprite *weakCursor = self.arrowCursor;
  id blinkCallBlock = [CCCallBlock actionWithBlock:^() {
    [weakCursor runAction:[CCRepeatForever actionWithAction:blink]];
  }];
  self.arrowCursor.visible = YES; // this results in starting the blink visible
  [self.arrowCursor runAction:[CCSequence actions:
                               [CCDelayTime actionWithDuration:kChatBoxCursorBlinkFrequency / 2],
                               blinkCallBlock, nil]];
}


#pragma mark - DSChoiceDialog Delegate

- (void)choiceDialogLabelSelected:(DSChoiceDialog *)sender
                        labelText:(NSString *)text
                      choiceIndex:(NSUInteger)index
{
  CCLOG(@"choice dialog selected with text: %@ - index: %i", text, index);
  
  [self removeChatBox];
  
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(chatboxFinished:withChoiceText:choiceIndex:)])
  {
    [self.delegate chatboxFinished:self withChoiceText:text choiceIndex:index];
  }
}


#pragma mark - CCTouchOneByOneDelegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
  if (self.visible && !self.dialog) {
    [self advanceTextOrFinish];
  }
  return YES;
}

@end
