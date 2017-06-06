//
//  Common.swift
//  InputKitDemo_Swift
//
//  Created by tingxins on 06/06/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

import Foundation

enum LimitedType {
    case normal(Int) //默认文本类型 limitedNumber
    case price(prefixNumber: Int, suffixNumber: Int, limitedNumber: Int) //价格文本类型 prefixNumber suffixNumber limitedNumber
    case custom(String, Bool, Int) //自定义文本类型 regEx isTextSelecting limitedNumber
}
