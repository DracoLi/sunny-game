//
//  DSChoiceDialog.m
//  sunny
//
//  Created by Draco on 2013-09-02.
//  Copyright 2013 Draco. All rights reserved.
//

#import "DSChoiceDialog.h"
#import "CCSprite+GLBoxes.h"

@interface DSChoiceDialog ()
@property (nonatomic, strong) CCSprite *bg;
@property (nonatomic, strong) NSArray *labels;
@end

@implementation DSChoiceDialog

+ (id)dialogWithChoices:(NSArray *)choices
                   size:(CGSize)size
{
  return [[self alloc] initWithChoices:choices size:size];
}

- (id)initWithChoices:(NSArray *)choices
                 size:(CGSize)size
{
  if (self = [super init]) {
    // Create choices labels
    float labelHeight = size.height / choices.count;
    int i = 0;
    NSMutableArray *tempLabels = [NSMutableArray arrayWithCapacity:choices.count];
    for (NSString *choice in choices) {
      DSSelectableLabel *label = [DSSelectableLabel
                                  labelWithText:choice
                                  fntFile:@"8bit-20.fnt"
                                  size:CGSizeMake(size.width, labelHeight)
                                  textOffset:ccp(10, 10)];
      label.tag = i;
      label.anchorPoint = ccp(0, 0);
      
      // This positions the lables in top to bottom order
      label.position = ccp(0, (choices.count - i - 1) * labelHeight);
      
      label.delegate = self;
      [self addChild:label z:1];
      [tempLabels addObject:label];
      i++;
    }
    self.labels = [tempLabels copy];
    
    // Create choice dialog background
    _bg = [CCSprite rectangleOfSize:size
                            withRed:0 green:0 blue:0 andAlpha:0.8];
    _bg.anchorPoint = ccp(0, 0);
    _bg.position = ccp(0, 0);
    [self addChild:_bg z:0];
  }
  return self;
}


#pragma mark - DSSelectableLabel Delegate

- (void)selectableLabelPreselected:(DSSelectableLabel *)sender
{
  // When a label is preselected in a dialog, we deselect all other labels
  for (DSSelectableLabel *label in self.labels) {
    if (![label isEqual:sender]) {
      [label deselect];
    }
  }
}

- (void)selectableLabelSelected:(DSSelectableLabel *)sender
{
  CCLOG(@"dialog confirmed with value: %@, index: %i",
        sender.text.string, sender.tag);
  if (self.delegate) {
    [self.delegate choiceDialogLabelSelected:self
                                   labelText:sender.text.string
                                 choiceIndex:sender.tag];
  }
}

@end
