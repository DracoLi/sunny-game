//
//  DSSunny.h
//  sunny
//
//  Created by Draco on 2013-08-20.
//  Copyright 2013 Draco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DSCharater.h"

@interface DSSunny : DSCharater

// Can sunny be controlled right now?
@property (nonatomic) BOOL controllable;


+ (id)characterAtPos:(CGPoint)pos
          onMapLayer:(DSLayer *)layer;
- (id)initAtPos:(CGPoint)pos
     onMapLayer:(DSLayer *)layer;

@end
