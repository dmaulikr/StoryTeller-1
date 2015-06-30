//
//  STExpressionMatcherFactory.m
//  StoryTeller
//
//  Created by Derek Clarkson on 25/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
#import <PEGKit/PEGKit.h>

#import <StoryTeller/STStoryTeller.h>
#import "STExpressionMatcherFactory.h"

#import "STLogExpressionParser.h"
#import "STCompareMatcher.h"
#import "STFilterMatcher.h"

typedef NS_ENUM(NSUInteger, ExpressionValueType) {
    ExpressionValueTypeNone,
    ExpressionValueTypeBoolean,
    ExpressionValueTypeString,
    ExpressionValueTypeNumber,
    ExpressionValueTypeNil
};

@implementation STExpressionMatcherFactory {
    id<STMatcher> _matcher;
    id<STMatcher> _valueMatcher;
    BOOL _runtimeQuery;
    BOOL _optionSet;
    ExpressionValueType _exprValueType;
    BOOL _exprBoolValue;
    NSString *_exprStringValue;
    NSNumber *_exprNumberValue;
}

static Class __protocolClass;

+(void) initialize {
    __protocolClass = objc_getClass("Protocol");
}

-(void) reset {
    _matcher = nil;
    _valueMatcher = nil;
    _optionSet = NO;
    _exprValueType = ExpressionValueTypeNone;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

-(nullable id<STMatcher>) parseExpression:(NSString __nonnull *) expression
                                    error:(NSError *__autoreleasing  __nullable * __nullable) error {

    STLogExpressionParser *parser = [[STLogExpressionParser alloc] initWithDelegate:self];

    // Finish matching.
    id<STMatcher> initialMatcher = nil;
    if ([parser parseString:expression error:error] == nil) {
        // Didn't parse
        [self reset];
        return nil;
    }

    // If log options have been set, return a nil
    if (_optionSet) {
        [self reset];
        return nil;
    }

    // Add the matcher.
    if (_matcher == nil) {
        // Must be a single value
        initialMatcher = _valueMatcher;
    } else {
        // More complex expression. Here we should have a class and keypath.
        initialMatcher = _matcher;
        initialMatcher.nextMatcher.nextMatcher = _valueMatcher;
    }

    [self reset];
    return initialMatcher;
}

#pragma mark - Delegate methods

-(void) parser:(PKParser * __nonnull)parser didMatchLogAll:(PKAssembly * __nonnull)assembly {
    [parser popToken];
    [[STStoryTeller storyTeller] logAll];
    _optionSet = YES;
}

-(void) parser:(PKParser * __nonnull)parser didMatchLogRoot:(PKAssembly * __nonnull)assembly {
    [parser popToken];
    [[STStoryTeller storyTeller] logRoots];
    _optionSet = YES;
}

-(void) parser:(PKParser __nonnull *) parser didMatchIs:(PKAssembly __nonnull *) assembly {
    [parser popToken];
    _runtimeQuery = YES;
}

-(void) parser:(PKParser __nonnull *) parser didMatchRuntimeType:(PKAssembly __nonnull *) assembly {
}

-(void) parser:(PKParser * __nonnull)parser didMatchLogicalExpr:(PKAssembly * __nonnull)assembly {

    // Get the op.
    BOOL isEqual = [parser popToken].tokenKind == STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ;

    switch (_exprValueType) {
        case ExpressionValueTypeBoolean: {
            BOOL expected = _exprBoolValue;
            _valueMatcher = [[STCompareMatcher alloc] initWithCompare:^BOOL(id  __nonnull key) {
                BOOL value = ((NSNumber *) key).boolValue;
                return (expected == value) == isEqual;
            }];
            break;
        }

        case ExpressionValueTypeNil:
            _valueMatcher = [[STCompareMatcher alloc] initWithCompare:^BOOL(id  __nonnull key) {
                return (key == nil) == isEqual;
            }];
            break;

        default: {
            NSString *expected = _exprStringValue;
            _valueMatcher = [[STCompareMatcher alloc] initWithCompare:^BOOL(id  __nonnull key) {
                return [expected isEqualToString:key] == isEqual;
            }];
        }
    }

}

-(void) parser:(PKParser * __nonnull)parser didMatchMathExpr:(PKAssembly * __nonnull)assembly {

    NSNumber *expected = _exprNumberValue;
    NSInteger op = [parser popToken].tokenKind;
    _valueMatcher =  [[STCompareMatcher alloc] initWithCompare:^BOOL(id  __nonnull key) {
        NSNumber *actual = (NSNumber *) key;
        switch (op) {
            case STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ:
                return [actual compare:expected] == NSOrderedSame;

            case STLOGEXPRESSIONPARSER_TOKEN_KIND_GT_SYM:
                return [actual compare:expected] > NSOrderedSame;

            case STLOGEXPRESSIONPARSER_TOKEN_KIND_GE:
                return [actual compare:expected] >= NSOrderedSame;

            case STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM:
                return [actual compare:expected] < NSOrderedSame;

            case STLOGEXPRESSIONPARSER_TOKEN_KIND_LE:
                return [actual compare:expected] <= NSOrderedSame;

            default:
                // NE
                return [actual compare:expected] != NSOrderedSame;
        }
    }];
}

-(void) parser:(PKParser * __nonnull)parser didMatchRuntimeExpr:(PKAssembly * __nonnull)assembly {
    id runtimeObject = [self runtimeObjectFromParser:parser];
    id<STMatcher> matcher = [self matcherForRuntimeObject:runtimeObject isExpectingRuntimeObject:_runtimeQuery];
    if (_matcher == nil) {
        _matcher = matcher;
    } else {
        _valueMatcher = matcher;
    }
}

-(void) parser:(PKParser __nonnull *) parser didMatchSingleKey:(PKAssembly * __nonnull)assembly {
    if (_exprNumberValue) {
        NSNumber *expected = _exprNumberValue;
        _valueMatcher = [[STCompareMatcher alloc] initWithCompare:^BOOL(id  __nonnull key) {
            return [expected compare:key] == NSOrderedSame;
        }];
    } else {
        NSString *expected = _exprStringValue;
        _valueMatcher = [[STCompareMatcher alloc] initWithCompare:^BOOL(id  __nonnull key) {
            return [expected isEqualToString:key];
        }];
    }
}

-(void) parser:(PKParser __nonnull *) parser didMatchBoolean:(PKAssembly __nonnull *) assembly {
    _exprValueType = ExpressionValueTypeBoolean;
    NSInteger tokenKind = [parser popToken].tokenKind;
    _exprBoolValue = tokenKind == STLOGEXPRESSIONPARSER_TOKEN_KIND_TRUE || tokenKind == STLOGEXPRESSIONPARSER_TOKEN_KIND_YES_UPPER;
}

-(void) parser:(PKParser __nonnull *) parser didMatchString:(PKAssembly __nonnull *) assembly {
    _exprValueType = ExpressionValueTypeString;
    PKToken *token = [parser popToken];
    _exprStringValue = token.tokenKind == TOKEN_KIND_BUILTIN_QUOTEDSTRING ? token.quotedStringValue : token.value;
}

-(void) parser:(PKParser __nonnull *) parser didMatchNumber:(PKAssembly __nonnull *) assembly {
    _exprValueType = ExpressionValueTypeNumber;
    _exprNumberValue = [parser popToken].value;
}

-(void) parser:(PKParser __nonnull *) parser didMatchNil:(PKAssembly __nonnull *) assembly {
    _exprValueType = ExpressionValueTypeNil;
    [parser popToken];
}

-(void) parser:(PKParser __nonnull *) parser didMatchKeyPath:(PKAssembly __nonnull *) assembly {

    NSMutableArray *paths = [@[] mutableCopy];
    while (! [assembly isStackEmpty]) {
        [paths insertObject:[parser popString] atIndex:0];
    }

    NSString *keyPath = [paths componentsJoinedByString:@"."];

    // Assume that there is alreadly a class or protocol matcher.
    _matcher.nextMatcher = [[STFilterMatcher alloc] initWithFilter:^id(id  __nonnull key) {
        return [key valueForKeyPath:keyPath];
    }];
}

#pragma mark - Internal

-(id) runtimeObjectFromParser:(PKParser __nonnull *) parser {

    const char *rtObjName = [parser popString].UTF8String;

    // First look for a class as this is more likely.
    id rtObj = objc_lookUpClass(rtObjName);
    if (rtObj == NULL) {
        // Now try for a protocol.
        rtObj = objc_getProtocol(rtObjName);

        // Must be a typo.
        if (rtObj == NULL) {
            [parser raise:[NSString stringWithFormat:@"Unable to find any runtime object called %s", rtObjName]];
            return nil;
        }
    }
    return rtObj;
}

-(id<STMatcher>) matcherForRuntimeObject:(id) rtObj isExpectingRuntimeObject:(BOOL) isExpectingRuntimeObject {
    BOOL useEquals = isExpectingRuntimeObject;
    if ([rtObj class] == __protocolClass) {
        Protocol *protocol = rtObj;
        return [[STCompareMatcher alloc] initWithCompare:^BOOL(id  __nonnull key) {
            return useEquals ? key == protocol : [key conformsToProtocol:protocol];
        }];
    } else {
        Class class = rtObj;
        return [[STCompareMatcher alloc] initWithCompare:^BOOL(id  __nonnull key) {
            return useEquals ? key == class : [key isKindOfClass:class];
        }];
    }
}

@end
