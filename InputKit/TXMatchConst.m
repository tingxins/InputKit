//
//  TXMatchConst.m
//  InputKitDemo
//
//  Created by tingxins on 05/06/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

#import "TXMatchConst.h"

NSString * const kTXLimitedTextFieldNumberOnlyRegex = @"^[0-9]*$";
NSString * const kTXLimitedTextFieldZeroOrNonRegex = @"^(0|[1-9][0-9]*)$";
NSString * const kTXLimitedTextFieldChineseOnlyRegex = @"^[\u4e00-\u9fa5]{0,}$";
NSString * const kTXLimitedTextFieldEnglishOnlyRegex = @"^[A-Za-z]+$";
