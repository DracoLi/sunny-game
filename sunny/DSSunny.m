//
//  DSSunny.m
//  sunny
//
//  Created by Draco on 2013-08-20.
//  Copyright 2013 Draco. All rights reserved.
//

#import "DSSunny.h"


@implementation DSSunny

+ (id)characterAtPos:(CGPoint)pos
          onMapLayer:(DSLayer *)layer
{
  return [[self alloc] initAtPos:pos onMapLayer:layer];
}

- (id)initAtPos:(CGPoint)pos
     onMapLayer:(DSLayer *)layer
{
  self = [super initWithSpriteFrameName:@"sunny_s_00.png"
                                  atPos:pos
                             onMapLayer:layer];
  if (self) {
    // Other sunny initializations
  }
  return self;
}

@end
