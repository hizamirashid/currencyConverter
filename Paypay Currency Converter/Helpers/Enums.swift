//
//  Enums.swift
//  Paypay Currency Converter
//
//  Created by User on 28/06/2022.
//

import Foundation

enum CustomError: Error {
    case invalidUrl
    case invalidData
}

enum CoreDataResult { // for coredata
    case success, fail(Error)
}
