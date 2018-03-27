//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Rick D on 2018/03/26.
//  Copyright © 2018 Firefly. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Foundation

// CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: charactersIn))


extension String {
    
    func isNumeric() -> Bool
    {
        let scanner = Scanner(string: self)
        scanner.locale = NSLocale.current
        
        return scanner.scanDecimal(nil) && scanner.isAtEnd
    }
    
}
    

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var currencyInPicker: UIPickerView!
    @IBOutlet weak var currencyOutPicker: UIPickerView!
    
    @IBOutlet weak var amountInTextField: UITextField!
    @IBOutlet weak var resultTextField: UILabel!
    
    let SEPARATOR : String = "_"
    let currencyInRow : Int = 10
    let currencyOutRow : Int = 5
    
    var currencyPair : String = ""
    var currencyInSelected : String = ""
    var currencyOutSelected : String = ""
    var currencySymbol = ""
    
    let baseURL = "https://free.currencyconverterapi.com/api/v5/convert?q="
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    let currencySymbolsArray = ["$", "R$", "$", "¥", "€", "£", "$", "Rp", "₪", "₹", "¥", "$", "kr", "$", "zł", "lei", "₽", "kr", "$", "$", "R"]
    var finalURL = ""
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      
        if pickerView == currencyInPicker{
            currencyInSelected = currencyArray[row]
        }
        else if pickerView == currencyOutPicker {
            currencyOutSelected = currencyArray[row]
        }
    
        if (amountInTextField.text?.isEmpty)! {
            resultTextField.text? += "\nEnter an amount to convert."
        }
        else {
            currencyPair = currencyInSelected + SEPARATOR + currencyOutSelected
            finalURL = baseURL + currencyPair
            
            currencySymbol = currencySymbolsArray[row]
            
            getCurrencyData(url: finalURL)
        }
    }
 
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == currencyInPicker {
            return currencyArray[row]
        } else if pickerView == currencyOutPicker {
            return currencyArray[row]
        }
        return "Error: titleForRow"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyInPicker.delegate = self
        currencyInPicker.dataSource = self
        
        currencyOutPicker.delegate = self
        currencyOutPicker.dataSource = self
 
        currencyInPicker.selectRow(currencyInRow, inComponent: 0, animated: true)
        currencyOutPicker.selectRow(currencyOutRow, inComponent: 0, animated: true)
        
        currencyInSelected = currencyArray[currencyInRow]
        currencyOutSelected = currencyArray[currencyOutRow]
        
        currencyPair = currencyInSelected + SEPARATOR + currencyOutSelected
        finalURL = baseURL + currencyPair
        currencySymbol = currencySymbolsArray[currencyOutRow]
    }
 
    @IBAction func amountChanged(_ sender: Any) {
        
        if (amountInTextField.text?.isNumeric())! {
            getCurrencyData(url: finalURL)
        }
        else {
            resultTextField.text = "\nType a number!"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func getCurrencyData(url : String) {
        
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {

                    var currencyMultiplier : Double = 0
                    
                    let currencyJSON : JSON = JSON(response.result.value!)
                   
                    
                    print(currencyJSON)
                    currencyMultiplier = self.getCurrencyMultiplier(json: currencyJSON)
                    
                    if let amount = Double(self.amountInTextField.text!){
                        let rawResult = self.calculateResult(amount : amount, currencyMultiplier: currencyMultiplier)

                        
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .decimal
                        let result = formatter.string(from: rawResult as NSNumber)
                        
                        //let resultString = self.currencySymbol + String(format: "%.2f", result!)
                        let resultString = self.currencySymbol + String(result!)
                        self.resultTextField.text = resultString
                    }
                }
                else {
                    self.resultTextField.text? += "Connection Issues!"
                }
        }
    }
    
    func limitExceeded(json : JSON) -> Bool{
        if json["status"] == "403" {
            return true
        }
        return false
    }
    
    
    func getCurrencyMultiplier(json : JSON) -> Double{
    
        if let conversionValue = json["results"][currencyPair]["val"].double {
            return conversionValue
        }
        return 0
    }
    
    func calculateResult(amount : Double, currencyMultiplier : Double) -> Double{
        
        return amount * currencyMultiplier   
    }
}

