//
//  CCSprite+GLBoxes.m
//  sunny
//
//  Created by Draco on 2013-09-01.
//  Copyright (c) 2013 Draco. All rights reserved.
//

#import "CCSprite+GLBoxes.h"

@implementation CCSprite (GLBoxes)

+ (CCSprite *) rectangleOfSize:(CGSize)size
                       withRed:(uint8_t)red
                         green:(uint8_t)green
                          blue:(uint8_t)blue
                      andAlpha:(float_t)alpha
{
  
  CCSprite *sprite = [CCSprite node];
  
  GLubyte *buffer = (GLubyte *) malloc(sizeof(GLubyte)*4);
  
  buffer[0] = red;
  buffer[1] = green;
  buffer[2] = blue;
  buffer[3] = (int)(alpha * 255);
  
  CCTexture2D *tex = [[CCTexture2D alloc] initWithData:buffer pixelFormat:kCCTexture2DPixelFormat_Default pixelsWide:1 pixelsHigh:1 contentSize:size];
  
  [sprite setTexture:tex];
  
  [sprite setTextureRect:CGRectMake(0, 0, size.width, size.height)];
  
  free(buffer);
  
  return sprite;
}

@end
