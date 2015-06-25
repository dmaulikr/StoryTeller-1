#import "STLogExpressionParser.h"
#import <PEGKit/PEGKit.h>
    
#pragma GCC diagnostic ignored "-Wundeclared-selector"
#import "STLogExpressionParser+Helper.h"


@interface STLogExpressionParser ()

@end

@implementation STLogExpressionParser { }

- (instancetype)initWithDelegate:(id)d {
    self = [super initWithDelegate:d];
    if (self) {
        
        self.startRuleName = @"expr";
        self.tokenKindTab[@">="] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_GE);
        self.tokenKindTab[@"false"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_FALSE);
        self.tokenKindTab[@"<"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM);
        self.tokenKindTab[@"<="] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_LE);
        self.tokenKindTab[@"true"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_TRUE);
        self.tokenKindTab[@"["] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_OPEN_BRACKET);
        self.tokenKindTab[@"="] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ);
        self.tokenKindTab[@"."] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_DOT);
        self.tokenKindTab[@">"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_GT_SYM);
        self.tokenKindTab[@"]"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_CLOSE_BRACKET);
        self.tokenKindTab[@"YES"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_YES);
        self.tokenKindTab[@"!="] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_NE);
        self.tokenKindTab[@"NO"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_NO);

        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_GE] = @">=";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_FALSE] = @"false";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM] = @"<";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_LE] = @"<=";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_TRUE] = @"true";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_OPEN_BRACKET] = @"[";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ] = @"=";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_DOT] = @".";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_GT_SYM] = @">";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_CLOSE_BRACKET] = @"]";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_YES] = @"YES";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_NE] = @"!=";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_NO] = @"NO";

    }
    return self;
}

- (void)start {
    [self execute:^{
    
	self.fenceToken = nil;

    }];

    [self expr_]; 
    [self matchEOF:YES]; 

}

- (void)expr_ {
    
    [self execute:^{
    
    PKTokenizer *t = self.tokenizer;
    [t.symbolState add:@"!="];
    [t.symbolState add:@"<="];
    [t.symbolState add:@">="];

    }];
    [self loggerExpr_]; 

    [self fireDelegateSelector:@selector(parser:didMatchExpr:)];
}

- (void)loggerExpr_ {
    
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM, STLOGEXPRESSIONPARSER_TOKEN_KIND_OPEN_BRACKET, 0]) {
        [self classExpr_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_FALSE, STLOGEXPRESSIONPARSER_TOKEN_KIND_NO, STLOGEXPRESSIONPARSER_TOKEN_KIND_TRUE, STLOGEXPRESSIONPARSER_TOKEN_KIND_YES, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self value_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'loggerExpr'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchLoggerExpr:)];
}

- (void)classExpr_ {
    
    [self classIdentifier_]; 
    if ([self speculate:^{ [self keyPath_]; [self op_]; [self value_]; }]) {
        [self keyPath_]; 
        [self op_]; 
        [self value_]; 
    }

    [self fireDelegateSelector:@selector(parser:didMatchClassExpr:)];
}

- (void)classIdentifier_ {
    
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_OPEN_BRACKET, 0]) {
        [self class_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM, 0]) {
        [self protocol_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'classIdentifier'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchClassIdentifier:)];
}

- (void)keyPath_ {
    
    do {
        [self propertyPath_]; 
    } while ([self speculate:^{ [self propertyPath_]; }]);
    [self execute:^{
    
	[self processKeyPathToken];

    }];

    [self fireDelegateSelector:@selector(parser:didMatchKeyPath:)];
}

- (void)propertyPath_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_DOT discard:YES]; 
    [self propertyName_]; 
    [self execute:^{
    
	[self processPropertyToken];

    }];

    [self fireDelegateSelector:@selector(parser:didMatchPropertyPath:)];
}

- (void)protocol_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM discard:YES]; 
    [self objCId_]; 
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_GT_SYM discard:YES]; 
    [self execute:^{
    
	[self processProtocolToken];

    }];

    [self fireDelegateSelector:@selector(parser:didMatchProtocol:)];
}

- (void)class_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_OPEN_BRACKET discard:YES]; 
    [self objCId_]; 
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_CLOSE_BRACKET discard:YES]; 
    [self execute:^{
    
	[self processClassToken];

    }];

    [self fireDelegateSelector:@selector(parser:didMatchClass:)];
}

- (void)objCId_ {
    
    [self testAndThrow:(id)^{ return isupper([LS(1) characterAtIndex:0]); }]; 
    [self matchWord:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchObjCId:)];
}

- (void)propertyName_ {
    
    [self testAndThrow:(id)^{ return islower([LS(1) characterAtIndex:0]); }]; 
    [self matchWord:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchPropertyName:)];
}

- (void)value_ {
    
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_FALSE, STLOGEXPRESSIONPARSER_TOKEN_KIND_NO, STLOGEXPRESSIONPARSER_TOKEN_KIND_TRUE, STLOGEXPRESSIONPARSER_TOKEN_KIND_YES, 0]) {
        [self bool_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self matchNumber:NO]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self matchWord:NO]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self matchQuotedString:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'value'."];
    }
    [self execute:^{
    
	[self processValueToken];

    }];

    [self fireDelegateSelector:@selector(parser:didMatchValue:)];
}

- (void)bool_ {
    
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_YES, 0]) {
        [self yes_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_NO, 0]) {
        [self no_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_TRUE, 0]) {
        [self true_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_FALSE, 0]) {
        [self false_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'bool'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchBool:)];
}

- (void)op_ {
    
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM, 0]) {
        [self lt_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_GT_SYM, 0]) {
        [self gt_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ, 0]) {
        [self eq_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_NE, 0]) {
        [self ne_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LE, 0]) {
        [self le_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_GE, 0]) {
        [self ge_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'op'."];
    }
    [self execute:^{
    
	[self processOpToken];

    }];

    [self fireDelegateSelector:@selector(parser:didMatchOp:)];
}

- (void)lt_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchLt:)];
}

- (void)gt_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_GT_SYM discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchGt:)];
}

- (void)eq_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchEq:)];
}

- (void)ne_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_NE discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchNe:)];
}

- (void)le_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_LE discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchLe:)];
}

- (void)ge_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_GE discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchGe:)];
}

- (void)yes_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_YES discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchYes:)];
}

- (void)no_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_NO discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchNo:)];
}

- (void)true_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_TRUE discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchTrue:)];
}

- (void)false_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_FALSE discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchFalse:)];
}

@end