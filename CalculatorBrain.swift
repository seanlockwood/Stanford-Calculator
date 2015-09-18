//
//  CalculatorBrain.swift
//  Stanford Calculator
//
//  Created by Sean Lockwood on 9/5/15.
//  Copyright (c) 2015 Super Sean Inc. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    // Operations can be doubles or symbols. 
    // If they are symbols, we have functions that they perform depending on if the symbol requires 2 numbers (like addition) or 1 number (like square root)
    private enum Op: Printable {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Constant(String, () -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Constant(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    // Create array of operations
    private var opStack = [Op]()
    
    // String is the symbol (e.g. +. -, etc.) and Op is function of the operator
    private var knownOps = [String:Op]()
    
    init() {
        
        func learnOp( op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("x", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("±", { -$0 }))
        learnOp(Op.Constant("∏", { M_PI }))
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Constant(_, let operation):
                return (operation(), remainingOps)
            }
            
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over.")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    // Return the history list to the viewcontroller
    func history() -> String? {return " ".join(opStack.map{"\($0)"}) }
}
