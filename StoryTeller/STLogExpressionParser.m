#import "STLogExpressionParser.h"
#import <PEGKit/PEGKit.h>
    
@import Foundation;
#pragma GCC diagnostic ignored "-Wundeclared-selector"


@interface STLogExpressionParser ()

@end

@implementation STLogExpressionParser { }

- (instancetype)initWithDelegate:(id)d {
    self = [super initWithDelegate:d];
    if (self) {
        
        self.startRuleName = @"expr";
        self.tokenKindTab[@"!="] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_NE);
        self.tokenKindTab[@"false"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_FALSE);
        self.tokenKindTab[@">="] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_GE);
        self.tokenKindTab[@"LogRoots"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGROOT);
        self.tokenKindTab[@"is"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_IS);
        self.tokenKindTab[@"=="] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ);
        self.tokenKindTab[@"<"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM);
        self.tokenKindTab[@"["] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_OPEN_BRACKET);
        self.tokenKindTab[@"true"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_TRUE);
        self.tokenKindTab[@"nil"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_NIL);
        self.tokenKindTab[@"LogAll"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGALL);
        self.tokenKindTab[@"."] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_DOT);
        self.tokenKindTab[@">"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_GT_SYM);
        self.tokenKindTab[@"]"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_CLOSE_BRACKET);
        self.tokenKindTab[@"<="] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_LE);
        self.tokenKindTab[@"YES"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_YES_UPPER);
        self.tokenKindTab[@"_"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_UNDERSCORE);
        self.tokenKindTab[@"NO"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_NO_UPPER);

        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_NE] = @"!=";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_FALSE] = @"false";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_GE] = @">=";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGROOT] = @"LogRoots";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_IS] = @"is";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ] = @"==";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM] = @"<";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_OPEN_BRACKET] = @"[";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_TRUE] = @"true";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_NIL] = @"nil";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGALL] = @"LogAll";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_DOT] = @".";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_GT_SYM] = @">";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_CLOSE_BRACKET] = @"]";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_LE] = @"<=";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_YES_UPPER] = @"YES";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_UNDERSCORE] = @"_";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_NO_UPPER] = @"NO";

    }
    return self;
}

- (void)start {

    [self expr_]; 
    [self matchEOF:YES]; 

}

- (void)expr_ {
    
    [self execute:^{
    
    PKTokenizer *t = self.tokenizer;
    [t.symbolState add:@"is"];
    [t.symbolState add:@"=="];
    [t.symbolState add:@"!="];
    [t.symbolState add:@"<="];
    [t.symbolState add:@">="];

    }];
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGALL, STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGROOT, 0]) {
        [self logControlExpr_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_IS, 0]) {
        [self runtimeCmp_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM, STLOGEXPRESSIONPARSER_TOKEN_KIND_OPEN_BRACKET, 0]) {
        [self objectExpr_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self singleKeyExpr_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'expr'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchExpr:)];
}

- (void)singleKeyExpr_ {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self number_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self string_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'singleKeyExpr'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchSingleKeyExpr:)];
}

- (void)objectExpr_ {
    
    [self objectType_]; 
    if ([self speculate:^{ [self keyPath_]; if ([self speculate:^{ [self numericCmp_]; }]) {[self numericCmp_]; } else if ([self speculate:^{ [self runtimeCmp_]; }]) {[self runtimeCmp_]; } else if ([self speculate:^{ [self objectCmp_]; }]) {[self objectCmp_]; } else {[self raise:@"No viable alternative found in rule 'objectExpr'."];}}]) {
        [self keyPath_]; 
        if ([self speculate:^{ [self numericCmp_]; }]) {
            [self numericCmp_]; 
        } else if ([self speculate:^{ [self runtimeCmp_]; }]) {
            [self runtimeCmp_]; 
        } else if ([self speculate:^{ [self objectCmp_]; }]) {
            [self objectCmp_]; 
        } else {
            [self raise:@"No viable alternative found in rule 'objectExpr'."];
        }
    }

    [self fireDelegateSelector:@selector(parser:didMatchObjectExpr:)];
}

- (void)logControlExpr_ {
    
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGALL, 0]) {
        [self logAll_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGROOT, 0]) {
        [self logRoot_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'logControlExpr'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchLogControlExpr:)];
}

- (void)objectType_ {
    
    [self runtimeObject_]; 

    [self fireDelegateSelector:@selector(parser:didMatchObjectType:)];
}

- (void)objectCmp_ {
    
    [self logicalOp_]; 
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_NIL, 0]) {
        [self nil_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_FALSE, STLOGEXPRESSIONPARSER_TOKEN_KIND_NO_UPPER, STLOGEXPRESSIONPARSER_TOKEN_KIND_TRUE, STLOGEXPRESSIONPARSER_TOKEN_KIND_YES_UPPER, 0]) {
        [self boolean_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self string_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM, STLOGEXPRESSIONPARSER_TOKEN_KIND_OPEN_BRACKET, 0]) {
        [self runtimeObject_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'objectCmp'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchObjectCmp:)];
}

- (void)numericCmp_ {
    
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ, STLOGEXPRESSIONPARSER_TOKEN_KIND_NE, 0]) {
        [self logicalOp_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_GE, STLOGEXPRESSIONPARSER_TOKEN_KIND_GT_SYM, STLOGEXPRESSIONPARSER_TOKEN_KIND_LE, STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM, 0]) {
        [self mathOp_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'numericCmp'."];
    }
    [self number_]; 

    [self fireDelegateSelector:@selector(parser:didMatchNumericCmp:)];
}

- (void)runtimeCmp_ {
    
    [self runtimeOp_]; 
    [self class_]; 

    [self fireDelegateSelector:@selector(parser:didMatchRuntimeCmp:)];
}

- (void)logAll_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGALL discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchLogAll:)];
}

- (void)logRoot_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGROOT discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchLogRoot:)];
}

- (void)keyPath_ {
    
    [self keyPathComponent_]; 
    while ([self speculate:^{ [self keyPathComponent_]; }]) {
        [self keyPathComponent_]; 
    }

    [self fireDelegateSelector:@selector(parser:didMatchKeyPath:)];
}

- (void)keyPathComponent_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_DOT discard:YES]; 
    [self propertyName_]; 

    [self fireDelegateSelector:@selector(parser:didMatchKeyPathComponent:)];
}

- (void)propertyName_ {
    
    [self testAndThrow:(id)^{ return islower([LS(1) characterAtIndex:0]); }]; 
    [self matchWord:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchPropertyName:)];
}

- (void)runtimeObject_ {
    
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_OPEN_BRACKET, 0]) {
        [self class_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM, 0]) {
        [self protocol_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'runtimeObject'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchRuntimeObject:)];
}

- (void)protocol_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM discard:YES]; 
    [self objectName_]; 
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_GT_SYM discard:YES]; 

    [self fireDelegateSelector:@selector(parser:didMatchProtocol:)];
}

- (void)class_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_OPEN_BRACKET discard:YES]; 
    [self objectName_]; 
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_CLOSE_BRACKET discard:YES]; 

    [self fireDelegateSelector:@selector(parser:didMatchClass:)];
}

- (void)objectName_ {
    
    [self objCId_]; 
    while ([self speculate:^{ if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_DOT, 0]) {[self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_DOT discard:YES]; [self objCId_]; } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_UNDERSCORE, 0]) {[self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_UNDERSCORE discard:YES]; [self objCId_]; } else {[self raise:@"No viable alternative found in rule 'objectName'."];}}]) {
        if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_DOT, 0]) {
            [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_DOT discard:YES]; 
            [self objCId_]; 
        } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_UNDERSCORE, 0]) {
            [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_UNDERSCORE discard:YES]; 
            [self objCId_]; 
        } else {
            [self raise:@"No viable alternative found in rule 'objectName'."];
        }
    }

    [self fireDelegateSelector:@selector(parser:didMatchObjectName:)];
}

- (void)objCId_ {
    
    [self testAndThrow:(id)^{ return isupper([LS(1) characterAtIndex:0]); }]; 
    [self matchWord:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchObjCId:)];
}

- (void)string_ {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self matchWord:NO]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self matchQuotedString:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'string'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchString:)];
}

- (void)number_ {
    
    [self matchNumber:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchNumber:)];
}

- (void)boolean_ {
    
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_YES_UPPER, 0]) {
        [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_YES_UPPER discard:NO]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_TRUE, 0]) {
        [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_TRUE discard:NO]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_NO_UPPER, 0]) {
        [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_NO_UPPER discard:NO]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_FALSE, 0]) {
        [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_FALSE discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'boolean'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchBoolean:)];
}

- (void)nil_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_NIL discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchNil:)];
}

- (void)mathOp_ {
    
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM, 0]) {
        [self lt_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_GT_SYM, 0]) {
        [self gt_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LE, 0]) {
        [self le_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_GE, 0]) {
        [self ge_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'mathOp'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchMathOp:)];
}

- (void)logicalOp_ {
    
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ, 0]) {
        [self eq_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_NE, 0]) {
        [self ne_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'logicalOp'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchLogicalOp:)];
}

- (void)runtimeOp_ {
    
    [self is_]; 

    [self fireDelegateSelector:@selector(parser:didMatchRuntimeOp:)];
}

- (void)is_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_IS discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchIs:)];
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

@end