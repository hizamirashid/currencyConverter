//
//  CountryListViewModel.swift
//  Paypay Currency Converter
//
//  Created by User on 28/06/2022.
//

import Foundation

struct CountryListViewModel {
    
    let country: [String : String]
    
    // Dependency Injection
    init(country: Country) {
        self.country = country.country ?? ["":""]
    }
}
