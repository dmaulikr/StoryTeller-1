//
//  STLogExpressionParserDelegateTests.m
//  StoryTeller
//
//  Created by Derek Clarkson on 25/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "STLogExpressionParserDelegate.h"
#import "STMatcher.h"
#import "MainClass.h"
#import "SubClass.h"
#import "AProtocol.h"

@interface ExpectsProtocolTests : XCTestCase
@end

@implementation ExpectsProtocolTests {
    STLogExpressionParserDelegate *_factory;
}

-(void) setUp {
    _factory = [[STLogExpressionParserDelegate alloc] init];
}

-(void) testProtocolMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[MainClass].protocolProperty is <AProtocol>" error:NULL];
    MainClass *mainClass = [[MainClass alloc] init];
    mainClass.protocolProperty = @protocol(AProtocol);
    XCTAssertTrue([matcher matches:mainClass]);
}

-(void) testWhenAStringProperty {
    id<STMatcher> matcher = [_factory parseExpression:@"[MainClass].stringProperty is <AProtocol>" error:NULL];
    MainClass *mainClass = [[MainClass alloc] init];
    mainClass.stringProperty = @"abc";
    XCTAssertFalse([matcher matches:mainClass]);
}

-(void) testWhenAClassProperty {
    id<STMatcher> matcher = [_factory parseExpression:@"[MainClass].classProperty is <AProtocol>" error:NULL];
    MainClass *mainClass = [[MainClass alloc] init];
    mainClass.classProperty = [NSString class];
    XCTAssertFalse([matcher matches:mainClass]);
}

-(void) testMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[MainClass].subClassProperty == <AProtocol>" error:NULL];
    MainClass *mainClass = [[MainClass alloc] init];
    SubClass *subClass = [[SubClass alloc] init];
    mainClass.subClassProperty = subClass;
    XCTAssertTrue([matcher matches:mainClass]);
}

-(void) testFailsMatch {
    id<STMatcher> matcher = [_factory parseExpression:@"[MainClass].subClassProperty == <NSCopying>" error:NULL];
    MainClass *mainClass = [[MainClass alloc] init];
    SubClass *subClass = [[SubClass alloc] init];
    mainClass.subClassProperty = subClass;
    XCTAssertFalse([matcher matches:mainClass]);
}

@end
