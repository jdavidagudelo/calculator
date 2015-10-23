//
//  ViewController.swift
//  Calculator
//
//  Created by Ingenieria y Software on 19/10/15.
//  Copyright © 2015 Ingenieria y Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var labelValue: UILabel!
    var userIsInMiddleOfTypingNumber: Bool = false
    @IBOutlet weak var labelOperations: UILabel!
    var brain = CalculatorBrain()
    var historyText : String?{
        get{
            return labelOperations.text!
        }
        set
        {
            let nv = newValue ?? " "
            labelOperations.text = "\(nv)"
        }
    }
    var displayValue: Double? {
        get{
            return NSNumberFormatter().numberFromString(labelValue.text!)!.doubleValue
        }
        set{
            if let nv = newValue
            {
                labelValue.text = "\(nv)"
            }else{
                labelValue.text = " "
            }
            userIsInMiddleOfTypingNumber = false
        }
    }
    @IBAction func back(sender: UIButton){
        if let text = labelValue.text
        {
            if text.characters.count > 1 && userIsInMiddleOfTypingNumber
            {
                let range = Range<String.Index>(start: text.startIndex, end: text.startIndex.advancedBy(text.characters.count-1))
                labelValue.text = text.substringWithRange(range)
            }
        }
    }
    @IBAction func appendDecimalSeparator(sender: UIButton){
        print("\(displayValue) == "+labelValue.text!)
        if let separator = sender.currentTitle{
            if userIsInMiddleOfTypingNumber{
                if let currentText = labelValue.text{
                    if !currentText.containsString(separator){
                        labelValue.text = currentText+separator
                    }
                }
            }
            else{
                labelValue.text = "0"+separator
                userIsInMiddleOfTypingNumber = true
            }
        }
    }
    @IBAction func appendDigit(sender : UIButton){
        let digit = sender.currentTitle!
        if( userIsInMiddleOfTypingNumber){
            labelValue.text = "\(labelValue.text!)\(digit)"
        }
        else{
            labelValue.text = digit
            userIsInMiddleOfTypingNumber = true
        }
    }
    @IBAction func enter(sender: UIButton){
        userIsInMiddleOfTypingNumber = false
        if let dv = displayValue
        {
            if let (result, _) = brain.pushOperand(dv){
                print("result = \(result)")
                displayValue = result!
                historyText = brain.description
            }
            else{
                print("result = null")
                displayValue = nil
            }
        }
    }
    @IBAction func clear(){
        userIsInMiddleOfTypingNumber = false
        displayValue = nil
        historyText = ""
        brain.clear()
    }
    
    @IBAction func operate(sender: UIButton)
    {
        if(userIsInMiddleOfTypingNumber){
            enter(sender)
        }
        if let operation = sender.currentTitle
        {
            if let (result, _) = brain.performOperation(operation)
            {
                displayValue = result
                historyText = brain.description
            }
            else{
                displayValue = nil
            }
        }
    }
}

