//
//  CountryCell.swift
//  Paypay Currency Converter
//
//  Created by User on 29/06/2022.
//

import UIKit

class CountryCell: UITableViewCell {
    
    var countryViewModel: CountryListViewModel! {
        didSet {
            let lazyMapCollection = countryViewModel.country.keys
            textLabel?.text = lazyMapCollection.first
            detailTextLabel?.text = countryViewModel.country[lazyMapCollection.first!]
        }
    }
    var currencyModel: Currencies! {
        didSet {
            textLabel?.text = currencyModel.shortName
            detailTextLabel?.text = currencyModel.fullName
        }
    }
}
