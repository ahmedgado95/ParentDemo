//
//  SetPadding.swift
//  ParentDemo
//
//  Created by ahmed gado on 10/5/20.
//  Copyright © 2020 ahmed gado. All rights reserved.
//

import UIKit

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}


class CustomButton: UIButton {
    
    var dateView = UIView()
    var toolBarView = UIView()
    
    override var inputView: UIView {
        
        get {
            return self.dateView
        }
        set {
            self.dateView = newValue
            self.becomeFirstResponder()
        }
        
    }
    
    override var inputAccessoryView: UIView {
        get {
            return self.toolBarView
        }
        set {
            self.toolBarView = newValue
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
}
