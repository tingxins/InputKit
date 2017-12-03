//
//  LimitedDelegate.swift
//  InputKitDemo_Swift
//
//  Created by tingxins on 08/06/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

import UIKit

internal class LimitedDelegate: NSObject {
    
    private(set) weak var realDelegate: AnyObject?
    
    init(realDelegate: AnyObject?) {
        self.realDelegate = realDelegate
    }
}

extension LimitedDelegate {
    @objc func sendMsgTo(obj: AnyObject, with component: AnyObject, sel: Selector) {
        guard obj.responds(to: sel) else { return }
        let _ = obj.perform(sel, with: component)
    }
}
