//
//  TXLimitedTextFieldController.m
//  InputKitDemo
//
//  Created by tingxins on 04/06/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

#import "TXLimitedTextFieldController.h"
#import "TXLimitedTextField.h"

@interface TXLimitedTextFieldController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentComponent;

@property (weak, nonatomic) IBOutlet TXLimitedTextField *limitedTextField;

@property (weak, nonatomic) IBOutlet TXLimitedTextField *limitedNumberField;
@property (weak, nonatomic) IBOutlet TXLimitedTextField *limitedPrefixField;
@property (weak, nonatomic) IBOutlet TXLimitedTextField *limitedSuffixField;

@property (weak, nonatomic) IBOutlet UITextField *customRegExField;
@property (weak, nonatomic) IBOutlet UILabel *customRegExLabel;

@property (weak, nonatomic) IBOutlet UILabel *interLabel;
@property (weak, nonatomic) IBOutlet UILabel *deciLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitedNumberTopConstraint;

@end

@implementation TXLimitedTextFieldController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDelegate];
    
    [self setupNotification];
    
    [self updateInputLimitedValue:nil];
}

- (void)setupDelegate {
    // 实现 -inputKitDidLimitedIllegalInputText: 方法，当文本输入非法时，回调。
    self.limitedTextField.delegate = self;
}

- (void)setupNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInputLimitedValue:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (IBAction)segmentValueTypeDidChange:(UISegmentedControl *)sender {
    [self updateInputLimitedValue:nil];
    switch (sender.selectedSegmentIndex) {
        case TXLimitedTextFieldTypePrice:
            [self hiddenPriceComponent:NO];
            [self hiddenCustomRegExComponent:YES];
            break;
            
        case TXLimitedTextFieldTypeCustom:
            [self hiddenPriceComponent:YES];
            [self hiddenCustomRegExComponent:NO];
            break;
            
        default:
            [self hiddenPriceComponent:YES];
            [self hiddenCustomRegExComponent:YES];
            break;
    }
}


- (void)hiddenPriceComponent:(BOOL)hidden {
    self.interLabel.hidden = hidden;
    self.deciLabel.hidden = hidden;
    self.limitedPrefixField.hidden = hidden;
    self.limitedSuffixField.hidden = hidden;
}

- (void)hiddenCustomRegExComponent:(BOOL)hidden {
    self.customRegExField.hidden = hidden;
    self.customRegExLabel.hidden = hidden;
    if (hidden) {
        self.limitedNumberTopConstraint.constant = 20;
    }else {
        self.limitedNumberTopConstraint.constant = 60;
    }
}

#pragma mark - UITextField Notification

- (void)updateInputLimitedValue:(NSNotification *)notification {
    TXLimitedTextField *textField = notification.object;
    if (textField == self.limitedTextField) return;
    
    self.limitedTextField.limitedType = self.segmentComponent.selectedSegmentIndex;
    self.limitedTextField.limitedNumber = [self.limitedNumberField.text integerValue];
    self.limitedTextField.limitedPrefix = [self.limitedPrefixField.text integerValue];
    self.limitedTextField.limitedSuffix = [self.limitedSuffixField.text integerValue];
    NSString *regEx = [NSString stringWithFormat:@"%@", self.customRegExField.text];
    if (!regEx.length) return;
    self.limitedTextField.limitedRegExs = @[regEx];
}

- (void)inputKitDidLimitedIllegalInputText:(id)obj {
    NSLog(@"%s", __func__);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
