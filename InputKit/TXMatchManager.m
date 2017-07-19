//
//  TXMatchManager.m
//  InputKit
//
//  Created by tingxins on 02/06/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//
#define TXRegExHeader @"SELF MATCHES %@"

#define TXLimitedTextFieldTypePriceRegExZero @"^[0][0-9]+$"
#define TXLimitedTextFieldTypePriceRegExContentFormat(limitedPrefix, limitedSuffix) [NSString stringWithFormat:@"^\\d{0,%ld}$|^(\\d{0,%ld}[.][0-9]{0,%ld})$", limitedPrefix, limitedPrefix, limitedSuffix]

#import "TXMatchManager.h"

@implementation TXMatchManager

+ (BOOL)matchLimitedTextTypePriceWithComponent:(id)component value:(NSString *)matchStr {
    NSInteger limitedPrefix = [[component valueForKeyPath:@"limitedPrefix"] integerValue];
    NSInteger limitedSuffix = [[component valueForKeyPath:@"limitedSuffix"] integerValue];
    // 1.匹配以0开头的数字
    NSPredicate *matchZero = [NSPredicate predicateWithFormat:TXRegExHeader, TXLimitedTextFieldTypePriceRegExZero];
    // 2.匹配两位小数、整数
    NSPredicate *matchValue = [NSPredicate predicateWithFormat:TXRegExHeader,TXLimitedTextFieldTypePriceRegExContentFormat((long)limitedPrefix, (long)limitedSuffix)];
    BOOL isZero = ![matchZero evaluateWithObject:matchStr];
    BOOL isCorrectValue = [matchValue evaluateWithObject:matchStr];
    return isZero && isCorrectValue ? YES : NO;
}

+ (BOOL)matchLimitedTextTypeCustomWithRegEx:(NSString *)regEx
                                  component:(id)component
                                      value:(NSString *)matchStr {
    NSPredicate *matchValue = [NSPredicate predicateWithFormat:TXRegExHeader, regEx];
    return [matchValue evaluateWithObject:matchStr];
}

+ (BOOL)matchLimitedTextTypeCustomWithRegExs:(NSArray *)regExs
                                   component:(id)component
                                       value:(NSString *)matchStr {
    BOOL results = YES;
    if (!regExs.count) return results;
    
    for (NSString *regEx in regExs) {
        results = results && [self matchLimitedTextTypeCustomWithRegEx:regEx component:component value:matchStr];
    }
    
    return results;
}

+ (NSString *)getMatchContentWithOriginalText:(NSString *)originalText
                                  replaceText:(NSString *)replaceText
                                        range:(NSRange)range {
    NSMutableString *matchContent = [NSMutableString string];
    // 原始内容判空
    if (originalText.length) {
        NSMutableString *tempStr = [NSMutableString stringWithString:originalText];
        matchContent = tempStr;
    }
    // 新增内容越界处理
    if (replaceText.length) {
        if (range.location < matchContent.length) {
            [matchContent insertString:replaceText atIndex:range.location];
        }else {
            [matchContent appendString:replaceText];
        }
    }
    return matchContent;
}

@end
