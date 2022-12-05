//
//  Extensions.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 30/11/22.
//

import Foundation
import UIKit

extension UIViewController {
    func dismissKeyboardWhenTappedAround(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}

