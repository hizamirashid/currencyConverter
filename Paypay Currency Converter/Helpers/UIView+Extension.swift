//
//  UIView+Extension.swift
//  Paypay Currency Converter
//
//  Created by User on 28/06/2022.
//

import Foundation
import UIKit

extension UIView {

    func animateButtonDown() {

        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }

    func animateButtonUp() {

        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }

}
