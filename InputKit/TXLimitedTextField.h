//
//  TXLimitedTextField.h
//  InputKit
//
//  Created by tingxins on 04/05/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, TXLimitedTextFieldType) {
    TXLimitedTextFieldTypeDefault,
    TXLimitedTextFieldTypePrice,
    TXLimitedTextFieldTypeCustom
};

@interface TXLimitedTextField : UITextField

#if TARGET_INTERFACE_BUILDER
@property (nonatomic, assign) IBInspectable NSInteger limitedType;
#else
/** 限制类型 */
@property (nonatomic, assign) TXLimitedTextFieldType limitedType;
#endif

#pragma mark - PriceType
/** 整数位数 */
@property (nonatomic, assign) IBInspectable NSInteger limitedPrefix;
/** 小数点位数 */
@property (nonatomic, assign) IBInspectable NSInteger limitedSuffix;
/** 输入框最大输入字符 */
@property (assign, nonatomic) IBInspectable NSInteger limitedNumber;

#pragma mark - CustomType
/** 自定义正则匹配，设置此属性后，其优先级低的属性将失效，如：limitedType等
 *  优先级说明：limitedRegEx > limitedType > (limitedPrefix = limitedSuffix = limitedNumber)
 */
@property (strong, nonatomic) IBInspectable NSArray *limitedRegExs;

@end
