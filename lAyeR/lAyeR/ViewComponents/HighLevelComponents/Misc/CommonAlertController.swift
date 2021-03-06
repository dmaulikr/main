//
//  CommonAlertController.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/14.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import UIKit
/*
 * CommonAlertController is a class that inherits BasicAlertController
 * and used to display alert messages with a dismiss button.
 */
class CommonAlertController: BasicAlertController {
    
    /// Dismiss button
    private var button: UIButton!
    /// Message Label
    private var label: UILabel!
    
    /// A singleton instance of the common alert controller that can be
    /// used in different parent view controllers to display alert message
    static let instance: CommonAlertController = CommonAlertController()
    
    /// Initializes the common alert controller
    init() {
        let alertSize = CGSize(width: HighLevelMiscConstants.suggestedPopupWidth,
                               height: HighLevelMiscConstants.suggestedPopupHeight)
        super.init(title: HighLevelMiscConstants.emptyString, size: alertSize)
        initializeCloseButton()
        initializeMessageLabel()
    }
    
    /// required initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Creates a text field that shows message
    private func initializeMessageLabel() {
        label = UILabel()
        label.font = UIFont(name: UIBasicConstants.defaultFontLight,
                            size: HighLevelMiscConstants.messageFontSize)
        label.textAlignment = NSTextAlignment.center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = UIColor.lightGray
        addViewToAlert(label)
    }
    
    /// Creates a close button
    private func initializeCloseButton() {
        button = UIButton()
        button.setTitle(HighLevelMiscConstants.confirmString, for: .normal)
        button.titleLabel?.font = UIFont(name: UIBasicConstants.defaultFontRegular,
                                         size: HighLevelMiscConstants.buttonFontSize)
        button.addTarget(self, action: #selector(closeAlert), for: .touchUpInside)
        addButtonToAlert(button)
    }
    
    /// Displays the alert in specified view with given alert title and message
    /// - Parameters:
    ///     - title: String: title of the alert
    ///     - message: String: message to be displayed
    ///     - view: UIView: the view to show this alert
    func showAlert(_ title: String, _ message: String, in view: UIView) {
        alert.setTitle(title)
        label.text = message
        presentAlert(within: view)
    }

}

