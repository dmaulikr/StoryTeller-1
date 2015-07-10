//
//  STTestCase.m
//  StoryTeller
//
//  Created by Derek Clarkson on 18/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "STTestCase.h"
#import <StoryTeller/STStoryTeller.h>
#import "InMemoryLogger.h"

@import ObjectiveC;

@implementation STTestCase

-(void) setUp {
    [[STStoryTeller storyTeller] reset];
    [STStoryTeller storyTeller].logger = [[InMemoryLogger alloc] init];
}

-(InMemoryLogger *) inMemoryLogger {
    return (InMemoryLogger *) [STStoryTeller storyTeller].logger;
}

-(void) testProtocol {
    Protocol *copying = @protocol(NSCopying);
    [copying isKindOfClass:[NSString class]];
}

@end
