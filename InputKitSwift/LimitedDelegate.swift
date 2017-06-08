//
//  LimitedDynamicDelegate.swift
//  InputKitDemo_Swift
//
//  Created by tingxins on 08/06/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

import UIKit

class LimitedDynamicDelegate: NSProxy {
    
    var key: String = ""
    
    public func `init`(key: String) {
        self.key = key
    }
    
    override func forwardInvocation(_ invocation: NSInvocation) {
        <#code#>
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        return super.responds(to: aSelector)
    }
    
}
