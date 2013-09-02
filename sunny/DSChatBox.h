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

@class DSChatBox;
@protocol DSChatBoxDelegate
@optional

- (void)wordsFinished:(DSChatBox *)chatbox;

@end

@class DSCharater;

@interface DSChatBox : CCNode <CCAutoTypeLabelBMDelegate>

@property (nonatomic, weak) id<DSChatBoxDelegate> delegate;
@property (nonatomic, weak) DSCharater *character;

- (id)initWithCharacter:(DSCharater *)character
                   text:(NSString *)text
                  layer:(CCLayer *)layer;
- (void)advanceTextOrFinish;

@end
