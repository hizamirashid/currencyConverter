//
//  Conversion.swift
//  Paypay Currency Converter
//
//  Created by User on 29/06/2022.
//

import Foundation

struct ConversionRate: Codable {
    let disclaimer: String?
    let license: String?
    let timestamp: Int?
    let base: String?
    let rates: [String: Double]?
}
