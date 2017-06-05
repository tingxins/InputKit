//
//  TXMatchManager.h
//  InputKit
//
//  Created by tingxins on 02/06/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TXMatchManager : NSObject

/**
 Just regular.

 @param component Regular component.
 @param matchStr Regular value.
 @return Result.
 */
+ (BOOL)matchLimitedTextTypePriceWithComponent:(id)component
                                         value:(NSString *)matchStr;


/**
 @param regEx Custom regEx.
 */
+ (BOOL)matchLimitedTextTypeCustomWithRegEx:(NSString *)regEx
                                  component:(id)component
                                      value:(NSString *)matchStr;
/**
 @param regExs 按 && 正则匹配数组中所有正则.
 */
+ (BOOL)matchLimitedTextTypeCustomWithRegExs:(NSArray *)regExs
                                   component:(id)component
                                       value:(NSString *)matchStr;
@end
