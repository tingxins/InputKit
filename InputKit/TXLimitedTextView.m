//
//  TXLimitedTextView.m
//  InputKit
//
//  Created by tingxins on 04/05/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

#import "TXLimitedTextView.h"
#import "TXDynamicDelegate.h"
#import "TXMatchManager.h"

@interface TXLimitedTextView (){
    NSRange _selectionRange;
}

@property (copy, nonatomic) NSString *historyText;

@end

@implementation TXLimitedTextView

@synthesize limitedNumber = _limitedNumber;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)load {
    @autoreleasepool {
        [self tx_registerDynamicDelegate];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addNotifications];
        [self addConfigs];
        if (!self.delegate) { [self addDelegate]; }
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addNotifications];
    [self addConfigs];
    if (!self.delegate) { [self addDelegate]; }
}

#pragma mark - Configs Methods

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChangeNotification:) name:UITextViewTextDidChangeNotification object:self];
}

- (void)addDelegate {
    self.delegate = nil;
}

- (void)addConfigs {
    self.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)clearCache {
    self.text = @"";
    _historyText = nil;
}

#pragma mark - Setter + Getter Methods

- (void)setLimitedNumber:(NSInteger)limitedNumber {
    _limitedNumber = limitedNumber;
}

- (NSInteger)limitedNumber {
    if (_limitedNumber) return _limitedNumber;
    return _limitedNumber = MAX_INPUT;
}

- (void)setLimitedRegEx:(NSString *)limitedRegEx {
    self.limitedRegExs = @[limitedRegEx];
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
    
    [self clearCache];
}

#pragma mark - NSNotification

- (void)textViewTextDidChangeNotification:(NSNotification *)notification {
    if (self != notification.object) return;
    
    UITextView *textView = notification.object;
    
    NSString *currentText = textView.text;
    NSInteger maxLength = self.limitedNumber;
    
    //获取高亮部分
    UITextRange *markedTextRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:markedTextRange.start offset:0];
    
    BOOL isMatch = YES;
    switch (self.limitedType) {
        case TXLimitedTextViewTypeDefault:
            break;
        case TXLimitedTextViewTypePrice:
            isMatch = [TXMatchManager matchLimitedTextTypePriceWithComponent:textView value:currentText];
            break;
        case TXLimitedTextViewTypeCustom:
            isMatch = [TXMatchManager matchLimitedTextTypeCustomWithRegExs:self.limitedRegExs component:textView value:currentText];
            break;
        default:break;
    }
    
    if (isMatch) {
        self.historyText = textView.text;
    }
    // 没有高亮选择的字，则对已输入的字符进行数量统计和限制
    if (!position) {
        BOOL flag = NO;
        if (currentText.length > maxLength) {
            textView.text = [currentText substringToIndex:maxLength];
            flag = YES;
        }
        
        if (self.isTextSelecting && !isMatch) {
            flag = YES;
            NSString *historyText = self.historyText;
            if (!historyText.length) {
                textView.text = @"";
            }else {
                if (self.historyText.length <= textView.text.length) {
                    textView.text = self.historyText;
                }
            }
        }
        if (_selectionRange.length && !isMatch && (_selectionRange.length + _selectionRange.location <= currentText.length)) {
            NSString *limitedText = [currentText substringWithRange:_selectionRange];
            textView.text = [textView.text stringByReplacingOccurrencesOfString:limitedText withString:@""];
            _selectionRange = NSMakeRange(0, 0);
        }
        if (flag)
            [self sendIllegalMsgToObject];
    }else {
        _selectionRange = [self rangeFromTextRange:textView.markedTextRange];
    }
}

- (NSRange)rangeFromTextRange:(UITextRange *)textRange {
    NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:textRange.start];
    NSInteger length = [self offsetFromPosition:textRange.start toPosition:textRange.end];
    return NSMakeRange(location, length);
}

- (void)sendIllegalMsgToObject {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"// get rid of undeclared selector warning!
    SEL sel = @selector(inputKitDidLimitedIllegalInputText:);
#pragma clang diagnostic pop
    if (self.delegate && [self.delegate.class isSubclassOfClass:[TXDynamicDelegate class]]) {
        TXDynamicDelegate *dynamicDelegate = (TXDynamicDelegate *)self.delegate;
        [dynamicDelegate sendMsgToObject:dynamicDelegate.realDelegate with:self SEL:sel];
    }
}

@end

@interface TXDynamicTXLimitedTextViewDelegate: TXDynamicDelegate

@end

@implementation TXDynamicTXLimitedTextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    BOOL flag = YES;
    int matchResult = YES;
    
    if ([textView isKindOfClass:[TXLimitedTextView class]]) {
        TXLimitedTextView *limitedTextView = (TXLimitedTextView *)textView;
        
        id realDelegate = self.realDelegate;
        if (realDelegate &&
            [realDelegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)] &&
            !limitedTextView.isCompatibleWithRAC)
            flag = [realDelegate textView:textView shouldChangeTextInRange:range replacementText:text];
        
        NSString *matchStr = [TXMatchManager getMatchContentWithOriginalText:textView.text replaceText:text range:range];
        
        BOOL isDeleteOperation = (range.length > 0 && text.length == 0) ? YES : NO;
        switch (limitedTextView.limitedType) {
            case TXLimitedTextViewTypeDefault:
                break;
                
            case TXLimitedTextViewTypePrice: {
                matchResult = [TXMatchManager matchLimitedTextTypePriceWithComponent:limitedTextView value:matchStr];
            }
                break;
                
            case TXLimitedTextViewTypeCustom:{
                if (limitedTextView.isTextSelecting) {// 高亮选中文本判断
                    matchResult = YES;
                }else {
                    matchResult = [TXMatchManager matchLimitedTextTypeCustomWithRegExs:limitedTextView.limitedRegExs component:limitedTextView value:matchStr];
                }
            }
                break;
                
                
            default:
                break;
        }
        
        BOOL result = flag && (matchResult || isDeleteOperation);
        // Send limited msg.
        if (!result) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"// get rid of undeclared selector warning!
            SEL sel = @selector(inputKitDidLimitedIllegalInputText:);
#pragma clang diagnostic pop
            [self sendMsgToObject:self.realDelegate with:textView SEL:sel];
        }
        return result;
    }
    
    return flag && matchResult;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    BOOL flag = YES;
    id realDelegate = self.realDelegate;
    TXLimitedTextView *limitedTextView = (TXLimitedTextView *)textView;
    if (realDelegate &&
        [realDelegate respondsToSelector:@selector(textViewShouldBeginEditing:)] &&
        !limitedTextView.isCompatibleWithRAC)
        flag = [realDelegate textViewShouldBeginEditing:textView];
    return flag;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    BOOL flag = YES;
    id realDelegate = self.realDelegate;
    TXLimitedTextView *limitedTextView = (TXLimitedTextView *)textView;
    if (realDelegate &&
        [realDelegate respondsToSelector:@selector(textViewShouldEndEditing:)] &&
        !limitedTextView.isCompatibleWithRAC)
        flag = [realDelegate textViewShouldEndEditing:textView];
    return flag;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    id realDelegate = self.realDelegate;
    TXLimitedTextView *limitedTextView = (TXLimitedTextView *)textView;
    if (realDelegate &&
        [realDelegate respondsToSelector:@selector(textViewDidBeginEditing:)] &&
        !limitedTextView.isCompatibleWithRAC)
        [realDelegate textViewDidBeginEditing:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    id realDelegate = self.realDelegate;
    TXLimitedTextView *limitedTextView = (TXLimitedTextView *)textView;
    if (realDelegate &&
        [realDelegate respondsToSelector:@selector(textViewDidEndEditing:)] &&
        !limitedTextView.isCompatibleWithRAC)
        [realDelegate textViewDidEndEditing:textView];
}

/** none of -textViewDidEndEditing: business in RAC */
- (void)textViewDidChange:(UITextView *)textView {
    id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(textViewDidChange:)])
        [realDelegate textViewDidChange:textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    id realDelegate = self.realDelegate;
    TXLimitedTextView *limitedTextView = (TXLimitedTextView *)textView;
    if (realDelegate &&
        [realDelegate respondsToSelector:@selector(textViewDidChangeSelection:)] &&
        !limitedTextView.isCompatibleWithRAC)
        [realDelegate textViewDidChangeSelection:textView];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    BOOL flag = YES;
    id realDelegate = self.realDelegate;
    TXLimitedTextView *limitedTextView = (TXLimitedTextView *)textView;
    if (realDelegate &&
        [realDelegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:interaction:)]&&
        !limitedTextView.isCompatibleWithRAC)
        flag = [realDelegate textView:textView shouldInteractWithURL:URL inRange:characterRange interaction:interaction];
    return flag;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    BOOL flag = YES;
    id realDelegate = self.realDelegate;
    TXLimitedTextView *limitedTextView = (TXLimitedTextView *)textView;
    if (realDelegate &&
        [realDelegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:interaction:)]&&
        !limitedTextView.isCompatibleWithRAC)
        flag = [realDelegate textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange interaction:interaction];
    return flag;
}


#pragma mark - Custom Methods (Remains)

static bool (*tx_trigger2)(id, SEL, UITextView *);
- (BOOL)isResponseToSEL:(SEL)sel obj:(UITextView *)obj {
    if ([self.realDelegate respondsToSelector:sel]) {
        tx_trigger2 = (bool (*)(id, SEL, UITextView *))[(NSObject *)self.realDelegate methodForSelector:sel];
        if (tx_trigger2) {
            return tx_trigger2(self, sel, obj);
        }
    }
    return YES;
}

static void (*tx_trigger3)(id, SEL, UITextView *);
- (void)isResponseToSELWithoutResult:(SEL)sel obj:(UITextView *)obj {
    if ([self.realDelegate respondsToSelector:sel]) {
        tx_trigger3 = (void (*)(id, SEL, UITextView *))[(NSObject *)self.realDelegate methodForSelector:sel];
        if (tx_trigger3) {
            tx_trigger3(self, sel, obj);
        }
    }
}

@end


