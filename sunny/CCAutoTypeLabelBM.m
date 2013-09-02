//
//  CCLabelBMAutoType.m
//  CCInvaders
//
//  Created by Stephen Ceresia on 12-07-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCAutoTypeLabelBM.h"

@implementation CCAutoTypeLabelBM

- (void) typeText:(NSString*) txt withDelay:(float) d
{    
  _arrayOfCharacters = [[NSMutableArray alloc]init];
  _autoTypeString = [[NSString alloc]initWithString:txt];
  
  for (int j=1; j < [txt length]+1; ++j)
  {
    NSString *substring = [txt substringToIndex:j];
    [_arrayOfCharacters addObject:substring];
  }
  
  float delay = d;
  for (int i=0; i < [txt length]; ++i)
  {
    NSString *string = [_arrayOfCharacters objectAtIndex:i];
    CCSequence *seq = [CCSequence actions:
                       [CCDelayTime actionWithDuration:i*delay],
                       [CCCallFuncND actionWithTarget:self
                                             selector:@selector(type:data:)
                                                 data:(__bridge void *)((NSString*)string)],
                       nil];
    [self runAction:seq];
  }
  [self schedule:@selector(finishCheck:) interval:0.2];
}

- (void) type:(id) sender data:(NSString*) s
{
  [self setString:s];
}

- (void) finishCheck:(ccTime)dt
{
  if ([self numberOfRunningActions] == 0)
  {
    [self unschedule:@selector(finishCheck:)];
    [self done:self];
  }
}

- (void) done:(id) sender
{
  if ([_delegate respondsToSelector:@selector(typingFinished:)])
  {
    [_delegate typingFinished:self];
  }
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

- (void) dealloc
{
  self.delegate = nil;
}


@end
