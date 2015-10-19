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
    var brain = CalculatorBrain()
    var displayValue: Double {
        get{
            return NSNumberFormatter().numberFromString(labelValue.text!)!.doubleValue
        }
        set{
            labelValue.text = "\(newValue)"
            userIsInMiddleOfTypingNumber = false
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
        if let result = brain.pushOperand(displayValue){
            print("result = \(result)")
            displayValue = result
        }
        else{
            print("result = null")
            displayValue = 0
        }
    }
 
    @IBAction func operate(sender: UIButton)
    {
        if let operation = sender.currentTitle
        {
            if let result = brain.performOperation(operation)
            {
                displayValue = result
            }
            else{
                displayValue = 0
            }
        }
        if(userIsInMiddleOfTypingNumber){
            enter(sender)
        }
    }
}

