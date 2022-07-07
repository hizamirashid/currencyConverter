//
//  ConversionRateViewModel.swift
//  Paypay Currency Converter
//
//  Created by User on 29/06/2022.
//

import Foundation

struct ConversionRateViewModel {
    
    let conversionData: ConversionRate
    
    // Dependency Injection
    init(conversionData: ConversionRate) {
        self.conversionData = conversionData
    }
}
