//
//  ViewController.swift
//  Stanford Calculator
//
//  Created by Sean Lockwood on 8/31/15.
//  Copyright (c) 2015 Super Sean Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Calculator display label
    @IBOutlet weak var display: UILabel!
    
    // Show complete stack as we complete calculations
    @IBOutlet weak var history: UILabel!
    
    
    // Get rid of zero when typing a new number
    var userIsInTheMiddleofTypingANumber = false
    
    var brain = CalculatorBrain()
    
    // Append Digit method when user hits a number
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleofTypingANumber {
            if (digit == ".") && (display.text!.rangeOfString(".") != nil) { return }
            display.text = display.text! + digit
        } else {
            if digit == "." {
                display.text = "0."
            } else {
                display.text = digit
            }
            userIsInTheMiddleofTypingANumber = true
        }
    }

    // Clear the stack
    @IBAction func clear() {
        brain = CalculatorBrain()
        displayValue = 0
    }
    
    // Buttons that perform operations on the operandStack
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if userIsInTheMiddleofTypingANumber {
            enter ()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
    }
    
    // Enter button to be pressed after each digit
    @IBAction func enter() {
        userIsInTheMiddleofTypingANumber = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = 0
        }
    }

    // Convert Display variable to a double so that
    // we can append it to the operandStack
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleofTypingANumber = false
            history.text = brain.history()
        }
    }
    
}

