//
//  Currencies+CoreDataProperties.swift
//  Paypay Currency Converter
//
//  Created by User on 02/07/2022.
//
//

import Foundation
import CoreData


extension Currencies {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Currencies> {
        return NSFetchRequest<Currencies>(entityName: "Currencies")
    }

    @NSManaged public var shortName: String?
    @NSManaged public var fullName: String?

}

extension Currencies : Identifiable {

}
