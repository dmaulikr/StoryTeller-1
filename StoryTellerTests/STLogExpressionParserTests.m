//
//  STLogExpressionParserTests.m
//  StoryTeller
//
//  Created by Derek Clarkson on 24/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <PEGKit/PEGKit.h>

#import "STLogExpressionParser.h"
#import "STLogExpressionParserDelegate.h"

@interface STLogExpressionParserTests : XCTestCase<STLogExpressionParserDelegate>

@end

@implementation STLogExpressionParserTests {
    NSArray<PKToken *> *_matchedTokens;
    BOOL _matchedClass;
    BOOL _matchedProtocol;
    BOOL _matchedIsa;
    BOOL _matchedLogAll;
    BOOL _matchedLogRoot;
}

-(void) setUp {
    _matchedTokens = @[];
    _matchedClass = NO;
    _matchedProtocol = NO;
    _matchedIsa = NO;
}


#pragma mark - Delegate methods

-(void) parser:(PKParser __nonnull *) parser didMatchLogAll:(PKAssembly __nonnull *) assembly {
    PKToken *token = [parser popToken];
    NSLog(@"Token LogAll: %@", token.value);
    _matchedTokens = [_matchedTokens arrayByAddingObject:token];
    _matchedLogAll = YES;
}

-(void) parser:(PKParser __nonnull *) parser didMatchLogRoot:(PKAssembly __nonnull *) assembly {
    PKToken *token = [parser popToken];
    NSLog(@"Token LogRoot: %@", token.value);
    _matchedTokens = [_matchedTokens arrayByAddingObject:token];
    _matchedLogRoot = YES;
}

-(void) parser:(PKParser __nonnull *) parser didMatchIsa:(PKAssembly __nonnull *) assembly {
    [parser popToken];
    _matchedIsa = YES;
}

-(void) parser:(PKParser * __nonnull) parser didMatchClass:(PKAssembly * __nonnull) assembly {
    PKToken *token = [parser popToken];
    NSLog(@"Token class: %@", token.value);
    _matchedTokens = [_matchedTokens arrayByAddingObject:token];
    _matchedClass = YES;
}

-(void) parser:(PKParser * __nonnull) parser didMatchProtocol:(PKAssembly * __nonnull) assembly {
    PKToken *token = [parser popToken];
    NSLog(@"Token protocol: %@", token.value);
    _matchedTokens = [_matchedTokens arrayByAddingObject:token];
    _matchedProtocol = YES;
}

-(void) parser:(PKParser * __nonnull) parser didMatchString:(PKAssembly * __nonnull) assembly {
    PKToken *token = [parser popToken];
    NSLog(@"Token string: %@", token.value);
    _matchedTokens = [_matchedTokens arrayByAddingObject:token];
}

-(void) parser:(PKParser * __nonnull) parser didMatchNumber:(PKAssembly * __nonnull) assembly {
    PKToken *token = [parser popToken];
    NSLog(@"Token number: %@", token.value);
    _matchedTokens = [_matchedTokens arrayByAddingObject:token];
}

-(void) parser:(PKParser * __nonnull) parser didMatchBooleanTrue:(PKAssembly * __nonnull) assembly {
    PKToken *token = [parser popToken];
    NSLog(@"Token boolean true: %@", token.value);
    _matchedTokens = [_matchedTokens arrayByAddingObject:token];
}

-(void) parser:(PKParser * __nonnull) parser didMatchBooleanFalse:(PKAssembly * __nonnull) assembly {
    PKToken *token = [parser popToken];
    NSLog(@"Token boolean false: %@", token.value);
    _matchedTokens = [_matchedTokens arrayByAddingObject:token];
}

-(void) parser:(PKParser __nonnull *) parser didMatchKeyPath:(PKAssembly __nonnull *) assembly {
    NSLog(@"Token key path ...");
    while (! [assembly isStackEmpty]) {
        PKToken *token = [parser popToken];
        NSLog(@"Token key path: %@", token.value);
        _matchedTokens = [_matchedTokens arrayByAddingObject:token];
    }
}

-(void) parser:(PKParser * __nonnull) parser didMatchOp:(PKAssembly * __nonnull) assembly {
    PKToken *token = [parser popToken];
    NSLog(@"Token op: %@", token.value);
    _matchedTokens = [_matchedTokens arrayByAddingObject:token];
}

#pragma mark - Tests

-(void) testLogAll {
    [self parse:@"LogAll"];
    [self validateMatchedTokens:@[@(STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGALL)]];
    XCTAssertEqualObjects(@"LogAll", _matchedTokens[0].value);
}

-(void) testLogRoots {
    [self parse:@"LogRoots"];
    [self validateMatchedTokens:@[@(STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGROOT)]];
    XCTAssertEqualObjects(@"LogRoots", _matchedTokens[0].value);
}

-(void) testString {
    [self parse:@"\"abc\""];
    [self validateMatchedTokens:@[@(TOKEN_KIND_BUILTIN_QUOTEDSTRING)]];
    XCTAssertEqualObjects(@"abc", _matchedTokens[0].quotedStringValue);
}

-(void) testQuotedString {
    [self parse:@"abc"];
    [self validateMatchedTokens:@[@(TOKEN_KIND_BUILTIN_WORD)]];
    XCTAssertEqualObjects(@"abc", _matchedTokens[0].quotedStringValue);
}

-(void) testNumber {
    [self parse:@"1.23"];
    [self validateMatchedTokens:@[@(TOKEN_KIND_BUILTIN_NUMBER)]];
    XCTAssertEqualObjects(@(1.23), _matchedTokens[0].value);
}

-(void) testBooleanTrue {
    [self parse:@"true"];
    [self validateMatchedTokens:@[@(STLOGEXPRESSIONPARSER_TOKEN_KIND_TRUE)]];
}

-(void) testBooleanYes {
    [self parse:@"YES"];
    [self validateMatchedTokens:@[@(STLOGEXPRESSIONPARSER_TOKEN_KIND_YES_UPPER)]];
}

-(void) testBooleanFalse {
    [self parse:@"false"];
    [self validateMatchedTokens:@[@(STLOGEXPRESSIONPARSER_TOKEN_KIND_FALSE)]];
}

-(void) testBooleanNo {
    [self parse:@"NO"];
    [self validateMatchedTokens:@[@(STLOGEXPRESSIONPARSER_TOKEN_KIND_NO_UPPER)]];
}

-(void) testClass {
    [self parse:@"[Abc]"];
    [self validateMatchedTokens:@[@(TOKEN_KIND_BUILTIN_WORD)]];
    XCTAssertEqualObjects(@"Abc", _matchedTokens[0].value);
    XCTAssertTrue(_matchedClass);
}

-(void) testProtocol {
    [self parse:@"<Abc>"];
    [self validateMatchedTokens:@[@(TOKEN_KIND_BUILTIN_WORD)]];
    XCTAssertEqualObjects(@"Abc", _matchedTokens[0].value);
    XCTAssertTrue(_matchedProtocol);
}

-(void) testClassPropertyEqualsString {

    [self parse:@"[Abc].userId == \"Derekc\""];

    [self validateMatchedTokens:@[
                                  @(TOKEN_KIND_BUILTIN_WORD),
                                  @(TOKEN_KIND_BUILTIN_WORD),
                                  @(STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ),
                                  @(TOKEN_KIND_BUILTIN_QUOTEDSTRING)
                                  ]];
    XCTAssertEqualObjects(@"Abc", _matchedTokens[0].quotedStringValue);
    XCTAssertEqualObjects(@"userId", _matchedTokens[1].value);
    XCTAssertEqualObjects(@"==", _matchedTokens[2].value);
    XCTAssertEqualObjects(@"Derekc", _matchedTokens[3].quotedStringValue);
}

-(void) testClassKeyPathEqualsString {
    [self parse:@"[Abc].user.supervisor.name == \"Derekc\""];

    [self validateMatchedTokens:@[
                                  @(TOKEN_KIND_BUILTIN_WORD),
                                  @(TOKEN_KIND_BUILTIN_WORD),
                                  @(TOKEN_KIND_BUILTIN_WORD),
                                  @(TOKEN_KIND_BUILTIN_WORD),
                                  @(STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ),
                                  @(TOKEN_KIND_BUILTIN_QUOTEDSTRING)
                                  ]];
    XCTAssertEqualObjects(@"Abc", _matchedTokens[0].quotedStringValue);
    XCTAssertEqualObjects(@"name", _matchedTokens[1].value);
    XCTAssertEqualObjects(@"supervisor", _matchedTokens[2].value);
    XCTAssertEqualObjects(@"user", _matchedTokens[3].value);
    XCTAssertEqualObjects(@"==", _matchedTokens[4].value);
    XCTAssertEqualObjects(@"Derekc", _matchedTokens[5].quotedStringValue);
}

#pragma mark - Errors

-(void) testMissingValue {
    [self parse:@"[Abc].userId =" withCode:1 error:@"Failed to match next input token"];
}

-(void) testMissingClass {
    [self parse:@".userId = abc" withCode:1 error:@"Failed to match next input token"];
}

-(void) testMissingPath {
    [self parse:@"<Abc> = abc" withCode:1 error:@"Failed to match next input token"];
}

-(void) testMissingOp {
    [self parse:@"<Abc>.userId abc" withCode:1 error:@"Failed to match next input token"];
}

-(void) testInvalidOp1 {
    [self parse:@"<Abc>.userId >=< abc" withCode:1 error:@"Failed to match next input token"];
}

-(void) testInvalidOp2 {
    [self parse:@"[Abc].userId >=< abc" withCode:1 error:@"Failed to match next input token"];
}

-(void) testIllegalSyntaxOptionAndCriteria {
    [self parse:@"LogAll [Abc].userId == abc" withCode:1 error:@"Failed to match next input token"];
}

-(void) testIsaClass {
    [self parse:@"isa [Abc]"];
    [self validateMatchedTokens:@[
                                  @(TOKEN_KIND_BUILTIN_WORD)
                                  ]];
    XCTAssertEqualObjects(@"Abc", _matchedTokens[0].value);
    XCTAssertTrue(_matchedClass);
    XCTAssertTrue(_matchedIsa);
}

-(void) testIsaProtocol {
    [self parse:@"isa <Abc>"];
    [self validateMatchedTokens:@[
                                  @(TOKEN_KIND_BUILTIN_WORD)
                                  ]];
    XCTAssertEqualObjects(@"Abc", _matchedTokens[0].value);
    XCTAssertTrue(_matchedProtocol);
    XCTAssertTrue(_matchedIsa);
}

#pragma mark - Internal

-(void) validateMatchedTokens:(NSArray<NSNumber *> *) expected {

    XCTAssertEqual([expected count], [_matchedTokens count]);
    [expected enumerateObjectsUsingBlock:^(NSNumber *  __nonnull expectedTokenKind, NSUInteger idx, BOOL * __nonnull stop) {
        XCTAssertEqual([expectedTokenKind integerValue], self->_matchedTokens[idx].tokenKind);
    }];

}

-(void) parse:(NSString __nonnull *) string {

    STLogExpressionParser *parser = [[STLogExpressionParser alloc] initWithDelegate:self];
    //parser.enableVerboseErrorReporting = YES;
    NSError *localError = nil;
    PKAssembly __nonnull *result = [parser parseString:string error:&localError];

    XCTAssertNil(localError);
    XCTAssertNotNil(result.stack);
    NSArray __nonnull *results = result.stack;
    XCTAssertEqual(0u, [results count]);
}

-(void) parse:(NSString __nonnull *) string withCode:(NSInteger) code error:(NSString *) errorMessage {
    NSError *localError = nil;
    STLogExpressionParser *parser = [[STLogExpressionParser alloc] initWithDelegate:self];
    parser.enableVerboseErrorReporting = YES;
    PKAssembly __nonnull *result = [parser parseString:string error:&localError];
    XCTAssertNotNil(localError);
    XCTAssertNil(result);
    XCTAssertEqualObjects(errorMessage, localError.localizedDescription);
    XCTAssertEqual(code, localError.code);
}

@end
