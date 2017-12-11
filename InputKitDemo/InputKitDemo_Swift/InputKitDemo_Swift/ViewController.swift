//
//  ViewController.swift
//  InputKitDemo_Swift
//
//  Created by tingxins on 06/06/2017.
//  Copyright © 2017 tingxins. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    fileprivate func setupLimitedTextField() {
        setupLimitedTextFieldTypeDefault()
        setupLimitedTextFieldTypePrice()
        setupLimitedTextFieldTypeCustom()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavInfo(largeTitle: true)
        
        setupLimitedTextField()
    }
    
    fileprivate func setupLimitedTextFieldTypeDefault() {
        let textField = getLimitedTextField(yScale: 0.5)
        textField.limitedNumber = 10
        textField.limitedType = .normal
        textField.placeholder = "Default"
    }
    
    fileprivate func setupLimitedTextFieldTypePrice() {
        let textField = getLimitedTextField(yScale: 1)
        textField.limitedPrefix = 3
        textField.limitedSuffix = 2
        textField.limitedNumber = 10
        textField.limitedType = .price
        textField.placeholder = "Price"
    }
    
    fileprivate func setupLimitedTextFieldTypeCustom() {
        let textField = getLimitedTextField(yScale: 1.5)
        textField.limitedRegEx = MatchConstant.Name.kLimitedTextChineseOnlyRegex
        textField.limitedNumber = 10
        textField.limitedType = .custom
        textField.isTextSelecting = true;
        textField.placeholder = "Custom"
    }
    
    fileprivate func getLimitedTextField(yScale: Float) ->LimitedTextField {
        
        let textField = LimitedTextField(frame: CGRect(x: 20, y: Int(Float(200) * yScale), width: 250, height: 40))
        view.addSubview(textField)
        textField.backgroundColor = .red
        textField.delegate = self
        print(textField)
        return textField
    }
}

extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension ViewController {
    
    fileprivate func setupNavInfo(largeTitle: Bool) {
        self.title = "InputKit"
        // Do any additional setup after loading the view, typically from a nib.
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = largeTitle
            navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setupNavInfo(largeTitle: false)
    }
}

//MARK: - UITextFieldDelegate
extension ViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(self, #function)
        return true
    }
}


// MARK: - 处理输入非法字符时的回调（callback）
extension ViewController {
    
    @objc func inputKitDidLimitedIllegalInputText(_ component: AnyObject) {
        print("处理输入非法字符时的回调")
    }
    @objc func inputKitDidChangeInputText(_ component: UITextField) {
        print("inputKitDidChangeInputText:\(component.text ?? "null")")
    }
}

