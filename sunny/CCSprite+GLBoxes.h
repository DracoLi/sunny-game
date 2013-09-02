//
//  CCSprite+GLBoxes.h
//  sunny
//
//  Created by Draco on 2013-09-01.
//  Copyright (c) 2013 Draco. All rights reserved.
//

#import "CCSprite.h"

@interface CCSprite (GLBoxes)


+ (CCSprite *)rectangleOfSize:(CGSize)size
                      withRed:(uint8_t)red
                        green:(uint8_t)green
                        blue:(uint8_t)blue
                    andAlpha:(float_t)alpha;

@end
