//
//  DSSelectableLabel.h
//  sunny
//
//  Created by Draco on 2013-09-02.
//  Copyright 2013 Draco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define kSelectableLabelTouchPriority 10

@class DSSelectableLabel;
@protocol DSSelectableLabelDelegate <NSObject>
@optional
- (void)selectableLabelPreselected:(DSSelectableLabel *)sender;
- (void)selectableLabelSelected:(DSSelectableLabel *)sender;
@end

@interface DSSelectableLabel : CCNode <CCTouchOneByOneDelegate>

@property (nonatomic) BOOL preselected;
@property (nonatomic) BOOL selected;
@property (nonatomic, strong) CCLabelBMFont *text;
@property (nonatomic, weak) id<DSSelectableLabelDelegate> delegate;


+ (id)labelWithText:(NSString *)text
            fntFile:(NSString *)fntFile
               size:(CGSize)size
         textOffset:(CGPoint)offset;
- (id)initWithText:(NSString *)text
           fntFile:(NSString *)fntFile
              size:(CGSize)size
        textOffset:(CGPoint)offset;

- (void)select;
- (void)deselect;

@end
