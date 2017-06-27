//
//  LimitedTextView.swift
//  InputKitDemo_Swift
//
//  Created by tingxins on 06/06/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

import UIKit

open class LimitedTextView: UITextView {
    
    //MARK: - Property defines
    fileprivate var selectionRange: NSRange = NSMakeRange(0, 0)
    
    fileprivate var historyText: String?
    
    open var limitedType: LimitedType = .normal
    @IBInspectable var _limitedType: Int {
        get {
            return limitedType.rawValue
        }
        set {
            limitedType = LimitedType(rawValue: newValue) ?? .normal
        }
    }
    
    @IBInspectable open var limitedNumber: Int = Int(MAX_INPUT)
    
    @objc @IBInspectable open var limitedPrefix: Int = Int(MAX_INPUT)
    
    @objc @IBInspectable open var limitedSuffix: Int = Int(MAX_INPUT)
    
    @IBInspectable open var isTextSelecting: Bool = false
    
    @IBInspectable open var limitedRegEx: String? {
        didSet {
            if let regEx = limitedRegEx, regEx.count > 0 {
                limitedRegExs = [regEx]
            }
        }
    }
    
    open var limitedRegExs: [String]? {
        didSet {
            var realRegEx: String = ""
            var realRegExs: [String] = []
            limitedRegExs?.forEach({ (regEx) in
                realRegEx = regEx.replacingOccurrences(of: "\\\\", with: "\\")
                if realRegEx.count != 0 {
                    realRegExs.append(realRegEx)
                }
            })
            limitedRegExs = realRegExs
            clearCache()
        }
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        addNotifications()
        addConfigs()
        if self.delegate == nil { addDelegate() }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        addNotifications()
        addConfigs()
        if self.delegate == nil { addDelegate() }
    }
    
    fileprivate var limitedDelegate: LimitedTextViewDelegate?
    override open var delegate: UITextViewDelegate? {
        get {
            return limitedDelegate
        }
        set {
            limitedDelegate = LimitedTextViewDelegate(realDelegate: newValue)
            super.delegate = self.limitedDelegate
        }
    }
    
    //MARK: - Deinitialized
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension LimitedTextView {
    //MARK: - Config Methods
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(textViewTextDidChange(notification:)), name: Notification.Name.UITextViewTextDidChange, object: nil)
    }
    
    private func addDelegate() {
        delegate = nil;
    }
    
    private func addConfigs() {
        autocorrectionType = .no;
    }
    
    private func clearCache() {
        historyText = nil;
    }
}

//MARK: - @objc Methods
extension LimitedTextView {
    
    //MARK: - Notifications
    @objc private func textViewTextDidChange(notification: Notification) {
        let textView = notification.object as? UITextView
        if self != textView { return }
        
        let currentText = textView?.text
        let maxLength = self.limitedNumber
        
        var position: UITextPosition?
        if let markedTextRange = textView?.markedTextRange {
            position = textView?.position(from: markedTextRange.start, offset: 0)
        }
        
        var isMatch = true
        switch self.limitedType {
        case .normal: break
        case .price:
            isMatch = MatchManager.matchLimitedTextTypePrice(component: textView!, value: currentText!)
        case .custom:
            isMatch = MatchManager.matchLimitedTextTypeCustom(regExs: self.limitedRegExs, component: textView!, value: currentText!)
        }
        
        if isMatch {
            self.historyText = textView?.text
        }
        
        if position == nil {
            var flag = false
            if let count = currentText?.count, count > maxLength {
                textView?.text = String(currentText!.dropLast(count - maxLength))
                flag = true
            }
            
            if self.isTextSelecting && !isMatch {
                flag = true
                if let hisText = self.historyText,
                    let curText = textView?.text,
                    hisText.count <= curText.count {
                    textView?.text = hisText
                }else {
                    textView?.text = ""
                }
            }
            let text: NSString = currentText! as NSString
            if ((self.selectionRange.length > 0) && !isMatch && (self.selectionRange.length + self.selectionRange.location <= text.length)) {
                let limitedText = text.substring(with: self.selectionRange)
                textView?.text = (textView?.text as NSString!).replacingOccurrences(of: limitedText, with: "")
                self.selectionRange = NSMakeRange(0, 0)
            }
            
            if flag {
                // Send limits msg
                sendIllegalMsgToObject();
            }
        }else {
            guard let markedTextRange = textView?.markedTextRange else { return }
            self.selectionRange = range(from: markedTextRange)
        }
    }
}

extension LimitedTextView {
    
    fileprivate func range(from textRange: UITextRange) -> NSRange {
        let location = offset(from: beginningOfDocument, to: textRange.start)
        let length = offset(from: textRange.start, to: textRange.end)
        return NSMakeRange(location, length)
    }
    
    fileprivate func sendIllegalMsgToObject() {
        guard let delegate = self.limitedDelegate
            , let realDelegate = delegate.realDelegate else {
                return
        }
        delegate.sendMsgTo(obj: realDelegate, with: self, sel: InputKitMessage.Name.inputKitDidLimitedIllegalInputText)
    }
}

fileprivate class LimitedTextViewDelegate: LimitedDelegate, UITextViewDelegate  {
    
    @available(iOS 2.0, *)
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool  {
        var flag = true
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textViewShouldBeginEditing(_:))) {
            flag = realDelegate.textViewShouldBeginEditing(textView)
        }
        return flag
    }
    
    @available(iOS 2.0, *)
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        var flag = true
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textViewShouldEndEditing(_:))) {
            flag = realDelegate.textViewShouldEndEditing(textView)
        }
        return flag
    }
    
    @available(iOS 2.0, *)
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textViewDidBeginEditing(_:))) {
            realDelegate.textViewDidBeginEditing(textView)
        }
    }
    
    @available(iOS 2.0, *)
    func textViewDidEndEditing(_ textView: UITextView) {
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textViewDidEndEditing(_:))) {
            realDelegate.textViewDidEndEditing(textView)
        }
    }
    
    @available(iOS 2.0, *)
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print(self, #function)
        var flag = true
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textView(_:shouldChangeTextIn:replacementText:))) {
            flag = realDelegate.textView(textView, shouldChangeTextIn: range, replacementText: text)
        }
        
        var matchResult = true
        if textView.isKind(of: LimitedTextView.self) {
            let limitedTextView = textView as! LimitedTextView
            var matchStr = textView.text
            let index = matchStr?.index((matchStr?.startIndex)!, offsetBy: range.location)
            matchStr?.insert(contentsOf: text, at: index!)
            
            let isDeleteOperation = (range.length > 0 && text.characters.count == 0) ? true : false;
            
            switch limitedTextView.limitedType {
            case .normal: break
            case .price: matchResult = MatchManager.matchLimitedTextTypePrice(component: textView, value: matchStr!)
            case .custom:
                if limitedTextView.isTextSelecting {
                    matchResult = true
                }else {
                    matchResult = MatchManager.matchLimitedTextTypeCustom(regExs: limitedTextView.limitedRegExs, component: textView, value: matchStr!)
                }
            }
            let result = flag && (matchResult || isDeleteOperation);
            if !result {
                limitedTextView.sendIllegalMsgToObject();
            }
            return result
        }
        return matchResult && flag
    }
    
    @available(iOS 2.0, *)
    func textViewDidChange(_ textView: UITextView) {
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textViewDidChange(_:))) {
            realDelegate.textViewDidChange(textView)
        }
    }
    
    @available(iOS 2.0, *)
    func textViewDidChangeSelection(_ textView: UITextView) {
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textViewDidChangeSelection(_:))) {
            realDelegate.textViewDidChangeSelection(textView)
        }
    }
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        var flag = true
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textView(_:shouldInteractWith:in:interaction:) as ((UITextView, URL, NSRange, UITextItemInteraction) -> Bool))) {
            flag = realDelegate.textView(textView, shouldInteractWith: URL, in: characterRange, interaction: interaction)
        }
        return flag
    }
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        var flag = true
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textView(_:shouldInteractWith:in:interaction:) as ((UITextView, NSTextAttachment, NSRange, UITextItemInteraction) -> Bool))) {
            flag = realDelegate.textView(textView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction)
        }
        return flag
    }
    
    @available(iOS, introduced: 7.0, deprecated: 10.0, message: "Use textView:shouldInteractWithURL:inRange:forInteractionType: instead")
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        var flag = true
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textView(_:shouldInteractWith:in:) as ((UITextView, URL, NSRange) -> Bool))) {
            flag = realDelegate.textView(textView, shouldInteractWith: URL, in: characterRange)
        }
        return flag
    }
    
    @available(iOS, introduced: 7.0, deprecated: 10.0, message: "Use textView:shouldInteractWithTextAttachment:inRange:forInteractionType: instead")
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        var flag = true
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textView(_:shouldInteractWith:in:) as ((UITextView, NSTextAttachment, NSRange) -> Bool))) {
            flag = realDelegate.textView(textView, shouldInteractWith: textAttachment, in: characterRange)
        }
        return flag
    }
    
}
