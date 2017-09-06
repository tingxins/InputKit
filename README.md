<p align="center">
<img src="http://image.tingxins.cn/InputKit/InputKit-logo2-dynamic.gif" width=888/>
</p>

<p align="center">
<a href="http://cocoadocs.org/docsets/InputKit"><img src="https://img.shields.io/badge/Pod-compatible-4BC51D.svg?style=flat"></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
<a href="https://github.com/tingxins/InputKit"><img src="https://img.shields.io/cocoapods/p/InputKit.svg?style=flat"></a>
<a href="https://github.com/tingxins/InputKit"><img src="https://img.shields.io/badge/support-iOS%208%2B-brightgreen.svg"></a>
<a href="https://www.apache.org/licenses/LICENSE-2.0.html"><img src="http://img.shields.io/cocoapods/l/InputKit.svg?style=flat"></a>

</p>

**InputKit** is an Elegant Kit to limits your input text, inspired by [BlocksKit](https://github.com/zwaldowski/BlocksKit), written in both Objective-C & Swift.

> [中文介绍](http://www.jianshu.com/p/c592c2dc9733)

# Language 

<p align="left">
    <a href="https://github.com/apple/swift"><img src="https://img.shields.io/badge/language-Objectivc--C-blue.svg"></a>
    <a href="http://cocoadocs.org/docsets/InputKit"><img src="https://img.shields.io/cocoapods/v/InputKit.svg?style=social"></a>
</p>

<p align="left">
    <a href="https://github.com/apple/swift"><img src="https://img.shields.io/badge/language-Swift%204.0%20beta-orange.svg"></a>
    <a href="http://cocoadocs.org/docsets/InputKitSwift"><img src="https://img.shields.io/cocoapods/v/InputKitSwift.svg?style=social"></a>
</p>

<p align="left">
    <a href="https://github.com/apple/swift"><img src="https://img.shields.io/badge/language-Swift 3.x-orange.svg"></a>
    <a href="http://cocoadocs.org/docsets/InputKitSwift"><img src="https://img.shields.io/badge/pod-v1.1.10-green.svg?style=social"></a>
</p>


# Installation

There are three ways to use InputKit in your project:

* Using CocoaPods

* Manual

* Using Carthage

## CocoaPods
    
CocoaPods is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects. 

**Podfile**

    platform :ios, '8.0'
    pod 'InputKit', 'xxx'

## Manual

Download repo's zip, and just drag **ALL** files in the InputKit folder to your projects.

## Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

    $ brew update
    $ brew install carthage
        
To integrate **InputKit** or **InputKitSwift** into your Xcode project using Carthage, specify it in your Cartfile:

    github "tingxins/InputKit"

Run carthage to build the frameworks and drag the appropriate framework (InputKit.framework or InputKitSwift.framework) into your Xcode project according to your need. Make sure to add only one framework and not both.
    
# Usage 

You can running **InputKitDemo** for more details.

## Using Code

First, import header file when you are using.
    
    #import "InputKit.h"
    
### For UITextField:

Using TXLimitedTextField class instead.

**TXLimitedTextFieldTypeDefault:**

The type of **TXLimitedTextFieldTypeDefault** is just limits the number of characters for TXLimitedTextField that you input, and you can input any characters if you wanted, such as Chinese, Alphabet or Special Characters, e.g. 

Example:

```

TXLimitedTextField *textField = [[TXLimitedTextField alloc] initWithFrame:CGRectMake(20, 200, 100, 30)];

// Of course, you can ignored this line of codes. TXLimitedTextFieldTypeDefault is default.
textField.limitedType = TXLimitedTextFieldTypeDefault;

// this means, you can only input ten characters. It limits the max number of characters that you input.
textField.limitedNumber = 10;

[self.view addSubview:textField];

```

![inputKit-demo-default](http://image.tingxins.cn/InputKit/inputKit-demo-default.gif)

**TXLimitedTextFieldTypePrice:**

The type of **TXLimitedTextFieldTypePrice** is not only limits the number of characters that you input, and can do more useful limited for your textfield. we usually used in TXLimitedTextField that only need to input int or decimal number. 

Example:

```

TXLimitedTextField *textField = [[TXLimitedTextField alloc] initWithFrame:CGRectMake(20, 200, 100, 30)];

// Type
textField.limitedType = TXLimitedTextFieldTypePrice;

// you can also set the property in this type. It limits the max number of characters that you input
textField.limitedNumber = 10;

// this means, that only five ints can be inputted
textField.limitedPrefix = 5;

// this means, that only five decimal can be inputted
textField.limitedSuffix = 2;

[self.view addSubview:textField];

```

![inputKit-demo-price](http://image.tingxins.cn/InputKit/inputKit-demo-price.gif)

**TXLimitedTextFieldTypeCustom:**

This type of **TXLimitedTextFieldTypeCustom** is interesting. you can custom your own TXLimitedTextField, just using your regular expression. but some notes must be noticed when you using. 

Example:

```

TXLimitedTextField *textField = [[TXLimitedTextField alloc] initWithFrame:CGRectMake(20, 200, 100, 30)];

// Of course, you can custom your field
textField.limitedType = TXLimitedTextFieldTypeCustom;

// you can also set the property in this type. It limits the max number of characters that you input
textField.limitedNumber = 10;

// limitedRegExs is a type of array argument that you can via it, and pass your regular expression to TXLimitedTextField. kTXLimitedTextFieldChineseOnlyRegex is a constant that define in TXMatchConst.h file. it's represent that only Chinese characters can be inputted.
textField.limitedRegExs = @[kTXLimitedTextFieldChineseOnlyRegex];

[self.view addSubview:textField];

```

![inputKit-demo-custom](http://image.tingxins.cn/InputKit/inputKit-demo-custom.gif)

## Using Nib

InputKit accessible from the **Attributes Inspector**. These attributes have been available:

![inputKit-demo-inspector-en](http://image.tingxins.cn/InputKit/InputKit-demo-inspector-en.png)

## About Callback

If you want to get a callback when you are input limited text, you should have to do this:

1. Set the delegate of your TXLimitedTextField: 

    ```
    
    self.limitedTextField.delegate = self;
    
    ```
    
2. Implement -inputKitDidLimitedIllegalInputText: method:

    ```
    #pragma mark - InputKit 
    
    - (void)inputKitDidLimitedIllegalInputText:(id)obj {
        NSLog(@"If you are input text that limited. this method will be callback. you may do some here!");
    }
    
    ```
    
    
## Other
    
#### Compatible with ReactiveCocoa

If you are using `ReactiveCocoa` in your Projects, please do make sure to set  instance property of `compatibleWithRAC` = YES.(**default is NO**). Thanks for @**devcxm** open this issue in GitHub.

Sample Code:

```

TXLimitedTextView *limitedTextView = [[TXLimitedTextView alloc] initWithFrame:CGRectMake(20.f, 100.f, 120.f, 30.f)];
// If you are using `ReactiveCocoa` somewhere in your Projects, please make sure this property = YES
limitedTextView.compatibleWithRAC = YES;
limitedTextView.delegate = self;
limitedTextView.limitedNumber = 5;
[self.view addSubview:limitedTextView];

[limitedTextView.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
  NSLog(@"come here ... %@", x);
}];

//....Enjoy it!👀

```


    
# Communication

Absolutely，you can contribute to this project all the time if you want to.

- If you **need help or ask general question**, just [**@tingxins**](http://weibo.com/tingxins) in [Weibo](http://weibo.com/tingxins) or [Twitter](https://twitter.com/tingxins), ofcourse, you can access to my [**blog**](https://tingxins.com).

- If you **found a bug**, just open an issue.

- If you **have a feature request**, just open an issue.

- If you **want to contribute**, fork this repository, and then submit a pull request.

# License

`InputKit` is available under the MIT license. See the LICENSE file for more info.

## Ad

Welcome to my Official Account of WeChat.

![wechat-qrcode](http://image.tingxins.cn/adv/wechat-qrcode.jpg)


