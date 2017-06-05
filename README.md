<p align="center">
<img src="http://image.tingxins.cn/InputKit/InputKit-logo.png" width=888/>
</p>

**InputKit** is an Elegant Kit to limits your input text in Objective-C, inspired by [BlocksKit](https://github.com/zwaldowski/BlocksKit).

# Installation

There are three ways to use InputKit in your project:

* Using CocoaPods

* Manual

* Using Carthage (not support now)

## CocoaPods
    
CocoaPods is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects. 

**Podfile**

    platform :ios, '7.0'
    pod 'InputKit'

## Manual

Download repo's zip, and just drag **ALL** files in the InputKit folder to your projects.
    
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

// Of course, you can ignored this line of codes. TXLimitedTextFieldTypeDefault is default.
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

// Of course, you can ignored this line of codes. TXLimitedTextFieldTypeDefault is default.
textField.limitedType = TXLimitedTextFieldTypePrice;

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

# Communication

Absolutely，you can contribute to this project all the time if you want to.

- If you **need help or ask general question**, just [**@tingxins**](http://weibo.com/tingxins) in `Weibo` or `Twitter`, ofcourse, you can access to my [**Blog**](https://tingxins.com).

- If you **found a bug**, just open an issue.

- If you **have a feature request**, just open an issue.

- If you **want to contribute**, fork this repository, and then submit a pull request.

# License

`InputKit` is available under the MIT license. See the LICENSE file for more info.

