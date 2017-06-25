//
//  TXLimitedTextFieldController.m
//  InputKitDemo
//
//  Created by tingxins on 04/06/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

#import "TXLimitedTextFieldController.h"
#import "InputKit.h"

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

@property (weak, nonatomic) IBOutlet UILabel *textSeletingLabel;
@property (weak, nonatomic) IBOutlet UISwitch *textSelectingSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textSelectingConstraint;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@end

@implementation TXLimitedTextFieldController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDelegate];
    
    [self setupNotification];
    
    [self segmentValueTypeDidChange:self.segmentComponent];
}

- (void)setupDelegate {
    // 实现 -inputKitDidLimitedIllegalInputText: 方法，当文本输入非法时，回调。
    self.limitedTextField.delegate = self;
}

- (void)setupNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInputLimitedValue:) name:UITextFieldTextDidChangeNotification object:nil];
}

#pragma mark - Target Methods

- (IBAction)segmentValueTypeDidChange:(UISegmentedControl *)sender {
    [self.limitedTextField clearCache];
    self.tipLabel.text = @"";
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
    self.textSeletingLabel.hidden = hidden;
    self.textSelectingSwitch.hidden = hidden;
    self.limitedTextField.isTextSelecting = !hidden;
    if (hidden) {
        self.textSelectingConstraint.constant = 90;
        self.limitedNumberTopConstraint.constant = 20;
    }else {
        self.textSelectingConstraint.constant = 10;
        self.limitedNumberTopConstraint.constant = 60;
    }
}

- (IBAction)textSelectSwitchValueChange:(UISwitch *)sender {
    self.limitedTextField.isTextSelecting = sender.isOn;
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

#pragma mark - InputKit 输入被限制时回调该方法

- (void)inputKitDidLimitedIllegalInputText:(id)obj {
    self.tipLabel.text = @"已限制输入文本";
    self.tipLabel.textColor = [UIColor redColor];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.tipLabel.text = @"正常输入文本";
    self.tipLabel.textColor = [UIColor greenColor];
    return YES;
}

#pragma mark - Touch Event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
