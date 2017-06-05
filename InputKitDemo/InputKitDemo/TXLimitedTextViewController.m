//
//  TXLimitedTextViewController.m
//  InputKitDemo
//
//  Created by tingxins on 04/06/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

#import "TXLimitedTextViewController.h"
#import "TXLimitedTextView.h"

@interface TXLimitedTextViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet TXLimitedTextView *limitedTextView;

@end

@implementation TXLimitedTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.limitedTextView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
