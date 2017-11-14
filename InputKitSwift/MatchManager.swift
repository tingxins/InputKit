//
//  MatchManager.swift
//  InputKitDemo_Swift
//
//  Created by tingxins on 08/06/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

import Foundation

internal class MatchManager {
    
    class func matchLimitedTextTypePrice(component:AnyObject, value: String) -> Bool {
        
        guard let limitedPrefix = component.value(forKeyPath: "limitedPrefix") as? Int, let limitedSuffix = component.value(forKeyPath: "limitedSuffix") as? Int else {
            return true
        }
        
        let matchZero = NSPredicate(format: MatchHeader.Name.kRegExHeader, MatchConstant.Name.kLimitedTextZeroRegEx)
        let matchValue = NSPredicate(format: MatchHeader.Name.kRegExHeader, "^\\d{0,\(limitedPrefix)}$|^(\\d{0,\(limitedPrefix)}[.][0-9]{0,\(limitedSuffix)})$")
        let isZero = !matchZero.evaluate(with: value)
        let isCorrectValue = matchValue.evaluate(with: value)
        return isZero && isCorrectValue ? true : false
    }
    
    class func matchLimitedTextTypeCustom(regEx: String, component: AnyObject, value: String) -> Bool {
        let matchValue = NSPredicate(format: MatchHeader.Name.kRegExHeader, regEx)
        return matchValue.evaluate(with:value)
    }
    
    class func matchLimitedTextTypeCustom(regExs: [String]?, component: AnyObject, value: String) -> Bool {
        var results = true
        guard let exs = regExs else { return results }
        
        for regEx: String in exs {
            results = results && matchLimitedTextTypeCustom(regEx: regEx, component: component, value: value)
        }
        return results
    }
}

internal extension MatchManager {
    
    class func getMatchContentWithOriginalText(originalText: String, replaceText: String, range: NSRange) -> String {
        var matchContent = String()
        // 1.原始内容判空
        if originalText.count > 0 {
            matchContent = originalText
        }
        // 2.新增内容越界处理
        if replaceText.count > 0 {
            if range.location < matchContent.count {
                let index = matchContent.index(matchContent.startIndex, offsetBy: range.location)
                matchContent.insert(contentsOf: replaceText, at: index)
            }else {
                matchContent.append(replaceText)
            }
        }
        return matchContent
    }
}
