//
//  RateViewModel.swift
//  Paypay Currency Converter
//
//  Created by User on 29/06/2022.
//

import Foundation

struct RateViewModel {
    
    let rates: Dictionary<String,Double>
    
    // Dependency Injection
    init(rates: Dictionary<String,Double>) {
        self.rates = rates
    }
}

