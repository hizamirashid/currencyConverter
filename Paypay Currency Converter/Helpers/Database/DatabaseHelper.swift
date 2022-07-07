//
//  DatabaseHelper.swift
//  Paypay Currency Converter
//
//  Created by User on 02/07/2022.
//

import Foundation
import CoreData

class Database {
    
    private init() {}
    private static let shared: Database = Database()
    
    lazy var container: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Paypay_Currency_Converter")
        container.loadPersistentStores { _, _ in }
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    // MARK: APIs
    
    /// For main queue use only, simple rule is don't access it from any queue other than main!!!
    static var viewContext: NSManagedObjectContext { return shared.container.viewContext }
    
    /// Context for use in background.
    static var newContext: NSManagedObjectContext { return shared.container.newBackgroundContext() }
    
    static func getAllCurrencies(completion: ((CoreDataResult, [Currencies]) -> ())?) {
        do {
            let currencies = try viewContext.fetch(Currencies.fetchRequest())
            completion?(.success,currencies)
        } catch let error {
            completion?(.fail(error), [])
        }
    }
    
    static func createCurrencies(currencies: [CurrenciesCRModel], completion: ((CoreDataResult) -> ())?) {
        for currency in currencies {
            let newCurrency = Currencies(context: viewContext)
            newCurrency.shortName = currency.shortName
            newCurrency.fullName = currency.fullName
            do {
                try viewContext.save()
                completion?(.success)
                
            } catch let error {
                viewContext.rollback()
                completion?(.fail(error))
            }
        }
    }
    
    static func deleteCurrencies() {
        do {
            let currencies = try viewContext.fetch(Currencies.fetchRequest())
            for currency in currencies {
                viewContext.delete(currency)
            }
            
            try viewContext.save()
        } catch {
            
        }
    }
    
    static func getAllRate() -> [RateViewModel] {
        do {
            let rates = try viewContext.fetch(CurrencyRate.fetchRequest())
            var newRates: [RateViewModel] = []
            for rate in rates {
                let rateVM = RateViewModel(rates: [rate.shortName! : rate.convertionRate])
                newRates.append(rateVM)
            }
            return newRates
        } catch {
            return []
        }
    }
    
    static func createRates(rates: [RateViewModel], completion: ((CoreDataResult) -> ())?) {
        for rate in rates {
            let newRate = CurrencyRate(context: viewContext)
            newRate.shortName = rate.rates.keys.first
            newRate.convertionRate = rate.rates.values.first!
            do {
                try viewContext.save()
                completion?(.success)
                
            } catch let error {
                viewContext.rollback()
                completion?(.fail(error))
            }
        }
    }
    
    static func deleteRates() {
        do {
            let rates = try viewContext.fetch(CurrencyRate.fetchRequest())
            for rate in rates {
                viewContext.delete(rate)
            }
            
            try viewContext.save()
        } catch {
            
        }
    }
}
