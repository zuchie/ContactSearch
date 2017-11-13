//
//  UITextViewExtension.swift
//  ContactsSearch
//
//  Created by Zhe Cui on 11/13/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    
    func addButton(with title: String, tag: Int, to position: CGPoint) {
        let attributed = NSMutableAttributedString(string: title, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: self.font!.pointSize)])
        let textSize = attributed.size()
        //let inset = self.textContainerInset
        let padding: CGFloat = 4.0
        let button = UIButton(frame: CGRect(x: position.x, y: position.y, width: textSize.width + padding, height: textSize.height + padding))
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        //button.backgroundColor = UIColor.lightGray
        button.layer.cornerRadius = button.frame.height / 2
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1.0
        button.tag = tag
        
        self.addSubview(button)
        
        //self.selectedRange = NSMakeRange(Int((textSize.width + padding).rounded(.up)), 0)
        
        /*
        if let cursorPosition = self.position(from: self.beginningOfDocument, offset: Int((textSize.width + padding).rounded(.up))) {
            self.selectedTextRange = self.textRange(from: cursorPosition, to: cursorPosition)
        }
        */
    }
    
    func removeButton(_ tag: Int) -> UIButton? {
        guard let button = self.viewWithTag(tag) as? UIButton else {
            return nil
        }
        
        button.removeFromSuperview()
        
        return button
    }
    
}
