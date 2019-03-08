//
//  DesignableUITextView.swift
//  School Management System
//
//  Created by Disha Panara on 26/12/17.
//  Copyright © 2017 Disha Panara. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableUITextView: UITextView {

    private struct Constants {
        static let defaultiOSPlaceholderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0980392, alpha: 0.22)
    }
    public let placeholderLabel: UILabel = UILabel()
    
    private var placeholderLabelConstraints = [NSLayoutConstraint]()
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable open var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    @IBInspectable open var placeholderColor: UIColor = DesignableUITextView.Constants.defaultiOSPlaceholderColor {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    
    override open var font: UIFont! {
        didSet {
            if placeholderFont == nil {
                placeholderLabel.font = font
            }
        }
    }
    
    open var placeholderFont: UIFont? {
        didSet {
            let font = (placeholderFont != nil) ? placeholderFont : self.font
            placeholderLabel.font = font
        }
    }
    
    override open var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }
    
    override open var text: String! {
        didSet {
            textDidChange()
        }
    }
    
    override open var attributedText: NSAttributedString! {
        didSet {
            textDidChange()
        }
    }
    
    
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.preferredMaxLayoutWidth = textContainer.size.width - textContainer.lineFragmentPadding * 2.0
    }
    
   
    //MARK: - A UIImage value that set LeftImage to the UITextView
    @IBInspectable open var leftImage:UIImage? {
        didSet {
            if (leftImage != nil) {
                self.applyLeftImage(leftImage!)
            }
        }
    }
    
    fileprivate func applyLeftImage(_ image: UIImage) {
        let icn : UIImage = image
        let imageView = UIImageView(image: icn)
        imageView.frame = CGRect(x: 10, y: 10.0, width: icn.size.width, height: icn.size.height - 5)
//        imageView.frame = CGRect(x: 20, y: 40, width: 20, height: 20)
        imageView.contentMode = UIView.ContentMode.center
        self.addSubview(imageView)
        self.textContainerInset = UIEdgeInsets(top: 5.0, left: icn.size.width + 15.0 , bottom: 2.0, right: 2.0)
//        self.textContainerInset = UIEdgeInsets(top: 2.0, left: 60.0 , bottom: 2.0, right: 2.0)
    }
}
