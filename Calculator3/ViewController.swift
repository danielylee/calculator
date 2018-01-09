//
//  ViewController.swift
//  Calculator3
//
//  Created by Daniel Lee on 12/21/17.
//  Copyright © 2017 Daniel Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    private var model = CalculatorModel()
    
    var numberFormatter = NumberFormatter()
    
    var userIsTyping = false
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = numberFormatter.string(from: newValue as NSNumber)
        }
    }
    

    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsTyping {
            display.text = display.text! + digit
        }
        else {
            display.text = digit
            userIsTyping = true
        }
    }
    
    
    @IBAction func touchPlaceValue() {
        if !userIsTyping {
            display.text = "0" + numberFormatter.decimalSeparator
        }
        else if !display.text!.contains(numberFormatter.decimalSeparator) {
            display.text = display.text! + numberFormatter.decimalSeparator
        }
        userIsTyping = true
    }
    
    

    @IBAction func touchOperation(_ sender: UIButton) {
        if userIsTyping {
            model.setOperand(displayValue)
            userIsTyping = false
        }
        if let mathmaticalSymbol = sender.currentTitle {
            model.performOperation(mathmaticalSymbol)
        }
        if let result = model.result {
            displayValue = result
        }
        let trailingResult = model.resultIsPending ? "..." : "="
        history.text = model.description + trailingResult
    }


    @IBAction func clearDisplay(_ sender: UIButton) {
        model.clear()
        displayValue = 0.0
        history.text = " "
        userIsTyping = false
    }
    
    @IBAction func backSpace(_ sender: UIButton) {
        guard userIsTyping else {
            return
        }
        display.text = String(display.text!.characters.dropLast())
        if display.text?.characters.count == 0 {
            displayValue = 0.0
            userIsTyping = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        history.text = " "
        numberFormatter.alwaysShowsDecimalSeparator = false
        numberFormatter.maximumFractionDigits = 6
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.minimumIntegerDigits = 1
        model.numberFormatter = numberFormatter
    }
}

