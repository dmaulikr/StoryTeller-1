//
//  STGenericMatcher.h
//  StoryTeller
//
//  Created by Derek Clarkson on 26/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "STMatcher.h"

@interface STCompareMatcher : NSObject<STMatcher>

-(nonnull instancetype) initWithCompare:(BOOL (^ _Nonnull)(_Nonnull id key)) compareBlock;

@end
