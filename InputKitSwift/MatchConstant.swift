//
//  MatchConstant.swift
//  InputKitDemo_Swift
//
//  Created by tingxins on 08/06/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

import Foundation

public struct MatchHeader {
    struct Name {
        static let kRegExHeader = "SELF MATCHES %@"
    }
}

public struct MatchConstant {
    struct Name {
        static let kLimitedTextZeroRegEx = "^[0][0-9]+$"// 匹 0 开头
        static let kLimitedTextNumberOnlyRegex = "^[0-9]*$";
        static let kLimitedTextZeroOrNonRegex = "^(0|[1-9][0-9]*)$";
        static let kLimitedTextChineseOnlyRegex = "^[\\u4e00-\\u9fa5]{0,}$";
        static let kLimitedTextEnglishOnlyRegex = "^[A-Za-z]+$";
    }
}

