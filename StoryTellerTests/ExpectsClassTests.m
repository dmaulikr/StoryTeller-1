//
//  STLogExpressionParserDelegateTests.m
//  StoryTeller
//
//  Created by Derek Clarkson on 25/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import StoryTeller;
@import StoryTeller.Private;
@import OCMock;

#import "MainClass.h"
#import "SubClass.h"
#import "AProtocol.h"

@interface ExpectsClassTests : XCTestCase
@end

@implementation ExpectsClassTests {
    STLogExpressionParserDelegate *_factory;
    id _mockStoryTeller;
}

-(void) setUp {
    _factory = [[STLogExpressionParserDelegate alloc] init];
    _mockStoryTeller = OCMClassMock([STStoryTeller class]);
}

#pragma mark - Class objects

-(void) testClassMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[MainClass].classProperty is [SubClass]"];
    MainClass *mainClass = [[MainClass alloc] init];
    mainClass.classProperty = [SubClass class];
    XCTAssertTrue([matcher storyTeller:_mockStoryTeller matches:mainClass]);
}

-(void) testClassfailsMatch {
    id<STMatcher> matcher = [_factory parseExpression:@"[MainClass].classProperty is [SubClass]"];
    MainClass *mainClass = [[MainClass alloc] init];
    mainClass.classProperty = [NSNumber class];
    XCTAssertFalse([matcher storyTeller:_mockStoryTeller matches:mainClass]);
}

#pragma mark - Type checking

-(void) testWhenAStringProperty {
    id<STMatcher> matcher = [_factory parseExpression:@"[MainClass].stringProperty is [SubClass]"];
    MainClass *mainClass = [[MainClass alloc] init];
    mainClass.stringProperty = @"abc";
    XCTAssertFalse([matcher storyTeller:_mockStoryTeller matches:mainClass]);
}

-(void) testWhenAProtocolProperty {
    id<STMatcher> matcher = [_factory parseExpression:@"[MainClass].protocolProperty is [SubClass]"];
    MainClass *mainClass = [[MainClass alloc] init];
    mainClass.protocolProperty = @protocol(NSCopying);
    XCTAssertFalse([matcher storyTeller:_mockStoryTeller matches:mainClass]);
}

-(void) testWhenAIntProperty {
    id<STMatcher> matcher = [_factory parseExpression:@"[MainClass].intProperty is [SubClass]"];
    MainClass *mainClass = [[MainClass alloc] init];
    mainClass.intProperty = 5;
    XCTAssertFalse([matcher storyTeller:_mockStoryTeller matches:mainClass]);
}

#pragma mark - Op tests

-(void) testWhenAIntPropertyEquals {
    id<STMatcher> matcher = [_factory parseExpression:@"[MainClass].intProperty == [SubClass]"];
    MainClass *mainClass = [[MainClass alloc] init];
    mainClass.intProperty = 5;
    XCTAssertFalse([matcher storyTeller:_mockStoryTeller matches:mainClass]);
}


#pragma mark - Path tests

-(void) testMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[MainClass].subClassProperty == [SubClass]"];
    MainClass *mainClass = [[MainClass alloc] init];
    SubClass *subClass = [[SubClass alloc] init];
    mainClass.subClassProperty = subClass;
    XCTAssertTrue([matcher storyTeller:_mockStoryTeller matches:mainClass]);
}

@end
