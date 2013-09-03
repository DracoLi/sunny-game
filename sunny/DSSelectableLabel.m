//
//  DSSelectableLabel.m
//  sunny
//
//  Created by Draco on 2013-09-02.
//  Copyright 2013 Draco. All rights reserved.
//

#import "DSSelectableLabel.h"
#import "CCSprite+GLBoxes.h"

@interface DSSelectableLabel ()
@property (nonatomic, strong) CCSprite *selectedbg;
@end

@implementation DSSelectableLabel

+ (id)labelWithText:(NSString *)text
            fntFile:(NSString *)fntFile
               size:(CGSize)size
         textOffset:(CGPoint)offset
{
  return [[self alloc] initWithText:text
                            fntFile:fntFile
                               size:size
                         textOffset:offset];
}

- (id)initWithText:(NSString *)text
           fntFile:(NSString *)fntFile
              size:(CGSize)size
        textOffset:(CGPoint)offset
{
  if (self = [super init]) {
    _preselected = NO;
    _selected = NO;
    
    // Add background
    _selectedbg = [CCSprite rectangleOfSize:size
                            withRed:200
                              green:0
                               blue:0
                           andAlpha:0.7];
    _selectedbg.anchorPoint = ccp(0, 0);
    _selectedbg.position = ccp(0, 0);
    _selectedbg.visible = NO;
    [self addChild:_selectedbg z:0];
    
    // Add text
    _text = [CCLabelBMFont labelWithString:text fntFile:fntFile];
    _text.anchorPoint = ccp(0, 0);
    _text.position = offset;
    [self addChild:_text z:1];
    
    // Add as touch responder
    [[[CCDirector sharedDirector] touchDispatcher]
     addTargetedDelegate:self priority:kSelectableLabelTouchPriority swallowsTouches:NO];
  }
  return self;
}

- (void)select
{
  if (self.preselected && !self.selected) {
    self.selected = YES;
  }else if (!self.preselected && !self.selected) {
    self.preselected = YES;
  }
}

- (void)deselect
{
  self.preselected = NO;
  self.selected = NO;
}


- (void)setPreselected:(BOOL)preselected
{
  _preselected = preselected;
  
  // Show selected bg if preselected
  _selectedbg.visible = preselected;
  
  if (preselected) {
    _selected = NO;
    
    // TODO: Play sound fx
    
    // Update delegate
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(selectableLabelPreselected:)]) {
      [self.delegate selectableLabelPreselected:self];
    }
  }else {
    
  }
}

- (void)setSelected:(BOOL)selected
{
  _selected = selected;
  
  if (selected) {
    // Update UI
    
    // Play sound fx
    
    // Update delegate
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(selectableLabelSelected:)]) {
      [self.delegate selectableLabelSelected:self];
    }
  }
}

#pragma mark - Touch delegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
  CGPoint touchPoint = [self convertTouchToNodeSpaceAR:touch];
  CGRect relativeRect = CGRectMake(0, 0,
                                   self.selectedbg.boundingBox.size.width,
                                   self.selectedbg.boundingBox.size.height);
  CCLOG(@"touch point: (%.2f, %.2f)", touchPoint.x, touchPoint.y);
  CCLOG(@"label box: ((%.2f, %.2f) (%.2f, %.2f)",
        self.position.x,
        self.position.y,
        self.selectedbg.boundingBox.size.width,
        self.selectedbg.boundingBox.size.height);
  BOOL touchValid = CGRectContainsPoint(relativeRect, touchPoint);
  
  // Handle touch
  if (touchValid) {
    CCLOG(@"Touch valid for label with text: %@", self.text.string);
    [self select];
  }
  
  return touchValid;
}

@end
