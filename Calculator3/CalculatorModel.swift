//
//  CalculatorModel.swift
//  Calculator3
//
//  Created by Daniel Lee on 12/21/17.
//  Copyright © 2017 Daniel Lee. All rights reserved.
//

import Foundation

struct CalculatorModel {
    
    var numberFormatter = NumberFormatter()
    
    var result: Double? {
        return accumulator
    }
    
    var resultIsPending: Bool {
        return pendingBinaryOperation != nil
    }
    
    var description: String {
        var outputString = ""
        for element in descriptions {
            outputString += element
        }
        return outputString
    }
    
    mutating func setOperand(_ operand: Double) {
        if !resultIsPending {
            clear()
        }
        accumulator = operand
        descriptions.append(formattedAccumulator!)
    }
    
    mutating func clear() {
        accumulator = nil
        pendingBinaryOperation = nil
        descriptions = []
    }
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                descriptions.append(symbol)
            case .unaryOperation(let function, let descriptionFunction):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                    descriptions = [descriptionFunction(description)]
                }
            case .binaryOperation(let function):
                if resultIsPending {
                    performPendingBinaryOperation()
                }
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(firstOperand: accumulator!, function: function)
                    descriptions.append(symbol)
                    // accumulator needs to be reset for next part of operation
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }

    
    private var descriptions = [String]()
    
    private var accumulator: Double?
    
    private var formattedAccumulator: String? {
        if let number = accumulator {
            return numberFormatter.string(from: number as NSNumber) ?? String(number)
        }
        else {
            return nil
        }
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation(((Double) -> Double), (String) -> String)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> =
    [
        "π": Operation.constant(Double.pi),
        "√": Operation.unaryOperation(sqrt, { "√(\($0))" }),
        "±": Operation.unaryOperation({ -$0 }, { "-(\($0))"  }),
        "x²": Operation.unaryOperation({ $0 * $0 }, { "(\($0))²"}),
        "x⁻¹": Operation.unaryOperation({ 1 / $0 }, {"(\($0))⁻¹"}),
        "+": Operation.binaryOperation(+),
        "-": Operation.binaryOperation(-),
        "×": Operation.binaryOperation(*),
        "÷": Operation.binaryOperation(/),
        "=": Operation.equals
    ]
    
    private struct PendingBinaryOperation {
        let firstOperand: Double
        let function: (Double, Double) -> Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private mutating func performPendingBinaryOperation() {
        guard resultIsPending && accumulator != nil else { return }
        
        accumulator = pendingBinaryOperation!.perform(with: accumulator!)
        pendingBinaryOperation = nil
        
    }


}
