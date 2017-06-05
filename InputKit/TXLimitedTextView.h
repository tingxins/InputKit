//
//  TXLimitedTextView.h
//  InputKit
//
//  Created by tingxins on 04/05/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, TXLimitedTextViewType) {
    TXLimitedTextViewTypeDefault,
    TXLimitedTextViewTypePrice,
    TXLimitedTextViewTypeCustom
};

@interface TXLimitedTextView : UITextView

#if TARGET_INTERFACE_BUILDER
@property (nonatomic, assign) IBInspectable NSInteger limitedType;
#else
/** 限制类型 */
@property (nonatomic, assign) TXLimitedTextViewType limitedType;
#endif

#pragma mark - PriceType
/** 整数位数 */
@property (nonatomic, assign) IBInspectable NSInteger limitedPrefix;
/** 小数点位数 */
@property (nonatomic, assign) IBInspectable NSInteger limitedSuffix;
/** 输入框最大输入字符 */
@property (assign, nonatomic) IBInspectable NSInteger limitedNumber;

#pragma mark - CustomType

@property (copy, nonatomic) IBInspectable NSString *limitedRegEx;

/** 自定义正则匹配，设置此属性后，其优先级低的属性将失效，如：limitedType等
 *  优先级说明：limitedRegEx > limitedType > (limitedPrefix = limitedSuffix = limitedNumber)
 */
@property (strong, nonatomic) NSArray *limitedRegExs;

/**
 针对部分输入法含高亮选择文本，如：中文输入法
 */
@property (assign, nonatomic) BOOL isTextSelecting;

@end
