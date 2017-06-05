//
//  TXLimitedTextField.m
//  InputKit
//
//  Created by tingxins on 04/05/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

#import "TXLimitedTextField.h"
#import "TXDynamicDelegate.h"
#import "TXMatchManager.h"

@interface TXLimitedTextField ()

@end

@implementation TXLimitedTextField

@synthesize limitedNumber = _limitedNumber;

+ (void)load {
    @autoreleasepool {
        [self tx_registerDynamicDelegate];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addNotifications];
        
        [self addConfigs];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self addNotifications];
    
    if (!self.delegate) {
        [self addConfigs];
    }
}

#pragma mark - Configs Methods

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:self];
}

- (void)addConfigs {
    self.delegate = nil;
}

#pragma mark - Setter + Getter Methods

- (void)setLimitedNumber:(NSInteger)limitedNumber {
    _limitedNumber = limitedNumber;
}

- (NSInteger)limitedNumber {
    if (_limitedNumber) return _limitedNumber;
    return _limitedNumber = MAX_INPUT;
}

- (void)setLimitedRegExs:(NSArray *)limitedRegExs {
    NSString *realRegEx;
    NSMutableArray *realRegExs = [NSMutableArray array];
    for (NSString *regEx in limitedRegExs) {
        realRegEx = [regEx stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
        if (realRegEx.length) {
            [realRegExs addObject:realRegEx];
        }
    }
    _limitedRegExs = realRegExs;
}

#pragma mark - NSNotification

// 主要用于处理 高亮 文本
- (void)textFieldTextDidChangeNotification:(NSNotification *)notification {
    if (self != notification.object || ((self.limitedType == TXLimitedTextFieldTypeCustom) && self.limitedRegExs.count)) return;

    UITextField *textField = notification.object;
    
    NSString *currentText = textField.text;
    NSInteger maxLength = self.limitedNumber;
    //获取高亮部分
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的字符进行数量统计和限制
    if (!position) {
        if (currentText.length > maxLength) {
            textField.text = [currentText substringToIndex:maxLength];
        }
    }
}

@end

@interface TXDynamicTXLimitedTextFieldDelegate: TXDynamicDelegate

@end

@implementation TXDynamicTXLimitedTextFieldDelegate

// return NO to disallow editing.
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL flag = YES;
    id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)])
        flag = [realDelegate textFieldShouldBeginEditing:textField];
    return flag;
}

//// became first responder
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
        [realDelegate textFieldDidBeginEditing:textField];
}

// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    BOOL flag = YES;
    id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(textFieldShouldEndEditing:)])
        flag = [realDelegate textFieldShouldEndEditing:textField];
    return flag;
}

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField {
    id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(textFieldDidEndEditing:)])
        [realDelegate textFieldDidEndEditing:textField];
}

// if implemented, called in place of textFieldDidEndEditing:
- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason NS_AVAILABLE_IOS(10_0) {
    id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(textFieldDidEndEditing:reason:)])
        [realDelegate textFieldDidEndEditing:textField reason:reason];
}

// return NO to not change text
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL flag = YES;
    id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
        flag = [realDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    
    BOOL matchResult = YES;
    BOOL isDeleteOperation = (range.length > 0 && string.length == 0) ? YES : NO;
    BOOL isGreaterThanLimitedNumber = YES;
    
    if ([textField isKindOfClass:[TXLimitedTextField class]]) {
        TXLimitedTextField *limitedTextField = (TXLimitedTextField *)textField;
        NSString *matchStr = [NSString stringWithFormat:@"%@%@",textField.text,string];

        switch (limitedTextField.limitedType) {
            case TXLimitedTextFieldTypeDefault:
                isGreaterThanLimitedNumber = matchStr.length > limitedTextField.limitedNumber;
                break;
                
            case TXLimitedTextFieldTypePrice:
                matchResult = [TXMatchManager matchLimitedTextTypePriceWithComponent:limitedTextField value:matchStr];
                isGreaterThanLimitedNumber = matchStr.length > limitedTextField.limitedNumber;
                break;
                
            case TXLimitedTextFieldTypeCustom:
                matchResult = [TXMatchManager matchLimitedTextTypeCustomWithRegExs:limitedTextField.limitedRegExs component:limitedTextField value:matchStr];
                isGreaterThanLimitedNumber = NO;
                break;
                
            default:
                break;
        }
    }else {
        isGreaterThanLimitedNumber = NO;
    }
    
    BOOL result = flag && (matchResult || isDeleteOperation);
    if (!result || isGreaterThanLimitedNumber) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"// get rid of undeclared selector warning!
        SEL sel = @selector(inputKitDidLimitedIllegalInputText:);
#pragma clang diagnostic pop
        [self sendMsgWith:textField SEL:sel];
    }
    return result;
}

// called when clear button pressed. return NO to ignore (no notifications)
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    BOOL flag = YES;
    id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(textFieldShouldClear:)])
        flag = [realDelegate textFieldShouldClear:textField];
    return flag;
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL flag = YES;
    id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(textFieldShouldReturn:)])
        flag = [realDelegate textFieldShouldReturn:textField];
    return flag;
}

#pragma mark - Custom Methods (Remains) Unused

static bool (*tx_trigger0)(id, SEL, UITextField *);
- (BOOL)isResponseToSEL:(SEL)sel obj:(UITextField *)obj {
    if ([self.realDelegate respondsToSelector:sel]) {
        tx_trigger0 = (bool (*)(id, SEL, UITextField *))[(NSObject *)self.realDelegate methodForSelector:sel];
        if (tx_trigger0) {
            return tx_trigger0(self, sel, obj);
        }
    }
    return YES;
}

static void (*tx_trigger1)(id, SEL, UITextField *);
- (void)isResponseToSELWithoutResult:(SEL)sel obj:(UITextField *)obj {
    if ([self.realDelegate respondsToSelector:sel]) {
        tx_trigger1 = (void (*)(id, SEL, UITextField *))[(NSObject *)self.realDelegate methodForSelector:sel];
        if (tx_trigger1) {
            tx_trigger1(self, sel, obj);
        }
    }
}
@end
