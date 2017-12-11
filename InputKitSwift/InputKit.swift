//
//  InputKit.swift
//  InputKitDemo_Swift
//
//  Created by tingxins on 09/06/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

import Foundation

struct InputKitMessage {
    struct Name {
        static let inputKitDidLimitedIllegalInputText: Selector = Selector(("inputKitDidLimitedIllegalInputText:"))
        static let inputKitDidChangeInputText: Selector = Selector(("inputKitDidChangeInputText:"))
    }
}

public enum LimitedType: Int {
    case normal=0 //默认文本类型 limitedNumber
    case price //价格文本类型 prefixNumber suffixNumber limitedNumber
    case custom //自定义文本类型 regEx isTextSelecting limitedNumber
}


