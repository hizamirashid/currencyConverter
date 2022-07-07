//
//  CountryListController.swift
//  Paypay Currency Converter
//
//  Created by User on 28/06/2022.
//

import UIKit

class CountryListController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var countryListViewModels: [CountryListViewModel] = []
    var delegate: CurrencyMainControllerDelegate?
    var currenciesFromDB: [Currencies] = []
//    let dataSource: CurrenciesDataSource = Database.viewContext.dataSource
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        
        // check internet connection, if there is no internet connection, fetch currencies from core data
        if InternetConnectionManager.isConnectedToNetwork(){
            print("Connected")
            serviceCall()
        }else{
            print("Not Connected")
            fetchFromDB()
        }
        
    }
    
    private func configureTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CountryCell.self, forCellReuseIdentifier: "TableViewCell")
    }
    
    private func fetchCurrencies() {
        
        isLoading = true
        ServiceManager.shared.request(url: Constants.countryListURL, expecting: [String : String].self) { [weak self] result in
            switch result {
            case .success(let countries):
                DispatchQueue.main.async {
                    let sortedCountries = countries.sorted { $0.key < $1.key }
                    self?.countryListViewModels = sortedCountries.map({ return CountryListViewModel(country: Country(country: [$0.key : $0.value])) })
                    
                    // save to core data
                    if let countryListViewModels = self?.countryListViewModels {
                        var currenciesArray: [CurrenciesCRModel] = []
                        for countryListViewModel in countryListViewModels {
                            let countrykey = countryListViewModel.country.keys
                            let countryValue = countryListViewModel.country.values
                            let currencyCRModel = CurrenciesCRModel(reference: nil, shortName: countrykey.first ?? "", fullName: countryValue.first ?? "")
                            currenciesArray.append(currencyCRModel)
                        }
                        
                        Database.deleteCurrencies()
                        Database.createCurrencies(currencies: currenciesArray) { result in
                            switch result {
                            case .fail(let error): print("Error: ", error)
                            case .success:
                                print("Saved successfully")
                                
                                self?.fetchFromDB()
                                self?.tableView.reloadData()
                                self?.isLoading = false
                            }
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Helper
    
    private func fetchFromDB() {
        isLoading = true
        Database.getAllCurrencies(completion: { Result, currencies in
            self.currenciesFromDB = currencies
            
            if self.currenciesFromDB.isEmpty {
                let alert = UIAlertController(title: "Error", message: "No internet connection. Please try again later.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.isLoading = false
            }
        })
    }
    
    func saveLastServiceCalledDate() {
        UserDefaults.standard.set(Date(), forKey: "lastServiceCallDate_Currencies")
    }

    func isCalledInLast30Min() -> Bool {
        guard let lastDate = UserDefaults.standard.value(forKey: "lastServiceCallDate_Currencies") as? Date else { return false }
        let timeElapsed: Int = Int(Date().timeIntervalSince(lastDate))
        return timeElapsed < 30 * 60 // 30 minutes
    }

    func serviceCall() {
        // ignore if called in last 30 minutes
        if isCalledInLast30Min() {
            fetchFromDB()
        } else {
            // save current date
            saveLastServiceCalledDate()

            // do service call
            fetchCurrencies()
        }
    }
}

extension CountryListController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isCalledInLast30Min() ? currenciesFromDB.count : countryListViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CountryCell(style: .subtitle, reuseIdentifier: "TableViewCell")
        if !isCalledInLast30Min() {
            let countryViewModel = countryListViewModels[indexPath.row]
            cell.countryViewModel = countryViewModel
            return cell
        } else {
            let currency = currenciesFromDB[indexPath.row]
            cell.currencyModel = currency
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isLoading {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            
            return spinner
        } else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        !isCalledInLast30Min() ? delegate?.selectedCurrencies(countryViewModel: countryListViewModels[indexPath.row]) : delegate?.selectedCurrencies(currencyFromDB: currenciesFromDB[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}
