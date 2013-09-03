//
//  DSChoiceDialog.h
//  sunny
//
//  Created by Draco on 2013-09-02.
//  Copyright 2013 Draco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSSelectableLabel.h"
#import "cocos2d.h"

@class DSChoiceDialog;
@protocol DSChoiceDialogDelegate <NSObject>
- (void)choiceDialogLabelSelected:(DSChoiceDialog *)sender
                        labelText:(NSString *)text
                      choiceIndex:(NSUInteger)index;
@end

@interface DSChoiceDialog : CCNode <DSSelectableLabelDelegate>

@property (nonatomic, weak) id<DSChoiceDialogDelegate> delegate;

+ (id)dialogWithChoices:(NSArray *)choices
                   size:(CGSize)size;
- (id)initWithChoices:(NSArray *)choices
                 size:(CGSize)size;

@end
