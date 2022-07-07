//
//  CurrencyCell.swift
//  Paypay Currency Converter
//
//  Created by User on 29/06/2022.
//

import UIKit

class CurrencyCell: UICollectionViewCell {
    
    @IBOutlet weak var currencyNameLbl: UILabel!
    @IBOutlet weak var currencyAmountLbl: UILabel!
    @IBOutlet weak var holderView: UIView!
        
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateView()
    }
    
    func updateView() {
        self.holderView.layer.cornerRadius = 10
        self.holderView.layer.borderWidth = 2
        self.holderView.layer.borderColor = UIColor.black.cgColor
    }
}
