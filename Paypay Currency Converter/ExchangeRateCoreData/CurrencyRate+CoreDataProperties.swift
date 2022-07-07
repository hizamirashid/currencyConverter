//
//  CurrencyRate+CoreDataProperties.swift
//  Paypay Currency Converter
//
//  Created by User on 02/07/2022.
//
//

import Foundation
import CoreData


extension CurrencyRate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrencyRate> {
        return NSFetchRequest<CurrencyRate>(entityName: "CurrencyRate")
    }
    
    @NSManaged public var shortName: String?
    @NSManaged public var convertionRate: Double

}

extension CurrencyRate : Identifiable {

}
