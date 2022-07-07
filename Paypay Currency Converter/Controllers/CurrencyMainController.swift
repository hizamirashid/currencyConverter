//
//  CurrencyMainController.swift
//  Paypay Currency Converter
//
//  Created by User on 28/06/2022.
//

import UIKit

protocol CurrencyMainControllerDelegate {
    func selectedCurrencies(countryViewModel: CountryListViewModel)
    func selectedCurrencies(currencyFromDB: Currencies)
}

class CurrencyMainController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var fromCurrencyBtn: UIButton!
    @IBOutlet weak var fromCurrencyTF: UITextField!
    @IBOutlet weak var convertBtn: UIButton!
    
    var rateUSDViewModels: [RateViewModel] = []
    var rateViewModels: [RateViewModel] = []
    var countryViewModel: CountryListViewModel = CountryListViewModel(country: Country(country: ["USD" : "United States Dollar"]))
    lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.type = .axial
        gradient.colors = [
            UIColor.red.cgColor,
            UIColor.white.cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 1, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        return gradient
    }()
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(
      top: 10.0,
      left: 20.0,
      bottom: 10.0,
      right: 20.0)
    private var fromValueCurrency = ""
    private var isFirstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureCV()
        commonInit()
        
        InternetConnectionManager.isConnectedToNetwork() ? serviceCall() : convertCurrencyDB()
    }
    
    func commonInit() {
        // set navigation title
        self.title = "Currency Conversion"
        
        // init ui
        gradient.frame = self.stackView.bounds
        self.stackView.layer.insertSublayer(gradient, at: 0)
        
        self.fromCurrencyBtn.tintColor = .black
        
        self.convertBtn.layer.cornerRadius = 10
        self.convertBtn.layer.borderWidth = 3
        self.convertBtn.layer.borderColor = UIColor.black.cgColor
        self.convertBtn.tintColor = .black
        
        self.fromCurrencyTF.textColor = .black
        self.fromCurrencyTF.keyboardType = .decimalPad
        self.fromCurrencyTF.delegate = self
        self.fromCurrencyTF.text = "1.00"
        
        self.setupHideKeyboardOnTap()
    }
    
    func configureCV() {
        collectionView.register(UINib(nibName: "CurrencyCell", bundle: nil), forCellWithReuseIdentifier: "CurrencyCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: self.collectionView.frame.size.width, height: 100)
        collectionView.collectionViewLayout = layout
    }
    
    @IBAction func buttonTouchDown(_ sender: UIButton) {
        //Connected with Touch Down Action
        sender.animateButtonDown()
    }
    
    @IBAction func buttonTouchUpOutside(_ sender: UIButton) {
        //Connected with Touch Up Outside Action
        //if touch moved away from button
        sender.animateButtonUp()
    }
    
    @IBAction func buttonTouchUpInside(_ sender: UIButton) {
        //Connected with Touch Up Inside Action
        sender.animateButtonUp()
        //code to execute when button pressed
        
        //check connection
        if InternetConnectionManager.isConnectedToNetwork() {
            serviceCall()
        } else {
            convertCurrencyDB()
        }
        
        let lazyCountry = countryViewModel.country.keys
        if let amountDouble = Double(self.fromCurrencyTF.text ?? "") {
            let rateConversion = rateUSDViewModels.filter {
                let lazyRateUSD = $0.rates.keys
                return lazyRateUSD.first == lazyCountry.first
            }
            print(rateConversion)
            
            guard let lazyRateValueFirst = rateConversion.first else {
                return
            }
            
            let lazyRateValue = lazyRateValueFirst.rates.values
            let rateDouble = Double(lazyRateValue.first!)
            let amountToBeConvert = amountDouble / rateDouble //(rateUSDViewModels.first!.rates[lazyCountry.first!]!)
            self.fromValueCurrency = String(amountToBeConvert)
            
            self.collectionView.reloadData()
        }
        
    }
    
    @IBAction func changeCurrency(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CountryListController") as! CountryListController
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - API
    func getLatestConversionRate(amount: String, base: String = "USD") {
        
        ServiceManager.shared.request(url: Constants.latestRateURL, expecting: ConversionRate.self, includeAppID: true) { [weak self] result in
            switch result {
            case .success(let conversionRate):
                DispatchQueue.main.async {
                    if let rates = conversionRate.rates {
                        let sortedRates = rates.sorted { $0.key < $1.key }
                        self?.rateViewModels = sortedRates.map({ return RateViewModel(rates: [$0.key:$0.value]) })
                        if self!.isFirstLoad {
                            self?.isFirstLoad = false
                            self?.rateUSDViewModels = sortedRates.map({ return RateViewModel(rates: [$0.key:$0.value]) })
                        } else {
                            self?.rateViewModels = sortedRates.map({ return RateViewModel(rates: [$0.key:$0.value]) })
                            self?.collectionView.reloadData()
                        }
                        
                        // save to local db
                        Database.createRates(rates: self?.rateViewModels ?? []) { result in
                            switch result {
                            case .fail(let error): print("Error: ", error)
                            case .success: print("Saved successfully")
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
    
    func convertCurrencyDB() {
        self.rateUSDViewModels = Database.getAllRate()
        self.rateViewModels = Database.getAllRate()
        
        if self.rateViewModels.isEmpty || self.rateUSDViewModels.isEmpty {
            let alert = UIAlertController(title: "Error", message: "No internet connection. Please try again later.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func saveLastServiceCalledDate() {
        UserDefaults.standard.set(Date(), forKey: "lastServiceCallDate")
    }

    func isCalledInLast30Min() -> Bool {
        guard let lastDate = UserDefaults.standard.value(forKey: "lastServiceCallDate") as? Date else { return false }
        let timeElapsed: Int = Int(Date().timeIntervalSince(lastDate))
        return timeElapsed < 30 * 60 // 30 minutes
    }

    func serviceCall(amount: String = "1.00", base: String = "USD") {
        // ignore if called in last 30 minutes
        if isCalledInLast30Min() {
            convertCurrencyDB()
        } else {
            // save current date
            saveLastServiceCalledDate()

            // do service call
            getLatestConversionRate(amount: amount)
        }
    }
}

extension CurrencyMainController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rateViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrencyCell", for: indexPath) as! CurrencyCell
        
        let rateModelView = rateViewModels[indexPath.row]
        let lazyMapCollection = rateModelView.rates.keys
        cell.currencyNameLbl.text = lazyMapCollection.first
        if let fromValue = Double(self.fromValueCurrency) {
            let convertedAmount = rateModelView.rates[lazyMapCollection.first!]! * fromValue
            let roundOff = Double(round(1000 * convertedAmount) / 1000)
            cell.currencyAmountLbl.text = "\(roundOff)"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            
            return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}

extension CurrencyMainController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Limit number fields to +/- Real #s: sign as first character, one decimal separator, one decimal place after separator
        if string.isEmpty { return true }   // Allow delete key anywhere!
        guard let oldText = textField.text, let rng = Range(range, in: oldText) else {
            return true
        }
        let newText = oldText.replacingCharacters(in: rng, with: string)
        
        let isNumeric = newText.isEmpty || (Double(newText) != nil)
        
        let formatter = NumberFormatter()
        formatter.locale = .current
        let decimalPoint = formatter.decimalSeparator ?? "."
        let numberOfDots = newText.components(separatedBy: decimalPoint).count - 1
        
        let numberOfDecimalDigits: Int
        if let dotIndex = newText.firstIndex(of: ".") {
            numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }
        if newText.count == 1 && !isNumeric {   // Allow first character to be a sign or decimal point
            return CharacterSet(charactersIn: "+-" + decimalPoint).isSuperset(of: CharacterSet(charactersIn: string))
        }
        return isNumeric && numberOfDots <= 2 && numberOfDecimalDigits <= 2
    }
}

extension CurrencyMainController: CurrencyMainControllerDelegate {
    
    func selectedCurrencies(currencyFromDB: Currencies) {
        self.countryViewModel = CountryListViewModel(country: Country(country: [currencyFromDB.shortName! : currencyFromDB.fullName!]))
        self.fromCurrencyBtn.setTitle(currencyFromDB.shortName, for: .normal)
    }
    
    func selectedCurrencies(countryViewModel: CountryListViewModel) {
        let lazyCountry = countryViewModel.country.keys
        self.countryViewModel = countryViewModel
        self.fromCurrencyBtn.setTitle(lazyCountry.first, for: .normal)
    }
}
