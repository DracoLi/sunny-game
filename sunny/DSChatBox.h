//
//  DSChatBox.h
//  sunny
//
//  Created by Draco on 2013-09-01.
//  Copyright 2013 Draco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCAutoTypeLabelBM.h"
#import "DSChoiceDialog.h"

@class DSChatBox;

@protocol DSChatBoxDelegate <NSObject>
@optional

- (void)wordsFinished:(DSChatBox *)chatbox;
- (void)chatboxFinished:(DSChatBox *)chatbox
         withChoiceText:(NSString *)choice
            choiceIndex:(NSUInteger)index;
@end

@class DSCharater;

@interface DSChatBox : CCNode
<CCAutoTypeLabelBMDelegate, DSChoiceDialogDelegate, CCTouchOneByOneDelegate>

@property (nonatomic, weak) id<DSChatBoxDelegate> delegate;
@property (nonatomic, weak) DSCharater *character;
@property (nonatomic, copy) NSArray *choices;

- (id)initWithCharacter:(DSCharater *)character
                  words:(NSArray *)words;
- (id)initWithCharacter:(DSCharater *)character
                  words:(NSArray *)words
                choices:(NSArray *)choices
             dialogSize:(CGSize)size;

- (void)advanceTextOrFinish;
- (void)removeChatBox;

@end
