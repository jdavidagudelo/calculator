//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Ingenieria y Software on 19/10/15.
//  Copyright © 2015 Ingenieria y Software. All rights reserved.
//
import Foundation

class CalculatorBrain: CustomStringConvertible {
    private enum Op: CustomStringConvertible{
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Constant(String, Double)
        var description: String {
            get{
                switch self{
                case  .Operand(let operand):
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
    var description: String{
        get{
            let (result, _, _) = getInfix(opStack)
            if let r = result
            {
                return r
            }
            return ""
        }
    }
    private func enclose(op: Op, localOp: Op,  result:String, start: Bool) -> String{
        switch op
        {
        case .Operand(_):
            return result
        case .Constant(_, _):
            return result
        case .UnaryOperation(_, _):
            return result
        case .BinaryOperation(_, _):
            if start
            {
               if let rule = opsSeparatorStart[op.description]
               {
                    if rule
                    {
                        switch localOp
                        {
                        case .Operand(_):
                            fallthrough
                        case .Constant(_, _):
                            fallthrough
                        case .UnaryOperation(_, _):
                            return result
                        case .BinaryOperation(_, _):
                            return "("+result+")"
                        }
                    }
                }
                
            }
            else{
                if let rule = opsSeparatorEnd[op.description]
                {
                    if rule
                    {
                        switch localOp
                        {
                        case .Operand(_):
                            fallthrough
                        case .Constant(_, _):
                            fallthrough
                        case .UnaryOperation(_, _):
                            return result
                        case .BinaryOperation(_, _):
                            return "("+result+")"
                        }
                    }
                }
            }
            return result
        }
    }
    private func getInfix(ops:[Op]) -> (infix: String?, remainingOps: [Op], op: Op?){
        if !ops.isEmpty
        {
            var remainingOps = ops;
            let op = remainingOps.removeLast()
            switch op{
            case .Operand(let operand):
                return (operand.description, remainingOps, op)
            case .UnaryOperation(let symbol, _):
                var s: String = symbol
                if s == "+/-"
                {
                        s = "-"
                }
                let operandEvaluation = getInfix(remainingOps)
                if let infix = operandEvaluation.infix{
                    return (s+"("+infix+")", operandEvaluation.remainingOps, op)
                }
            case .Constant(let symbol, _):
                return (symbol, remainingOps, op)
            case .BinaryOperation(let symbol, _):
                let op1Evaluation = getInfix(remainingOps)
                if let operand1 = op1Evaluation.infix
                {
                    let op2Evaluation = getInfix(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.infix
                    {
                        return (enclose(op, localOp: op2Evaluation.op!,  result: operand2, start: true)+symbol+enclose(op, localOp: op1Evaluation.op!, result: operand1, start: false), op2Evaluation.remainingOps, op)
                    }
                }
            }
        }
        return (nil, ops, nil)
    }
    private var opStack: Array<Op> = Array<Op>()
    private var knownOps =   [String:Op]()
    private var opsSeparatorStart = [String: Bool]()
    private var opsSeparatorEnd = [String: Bool]()
    
    init()
    {
        func learnOp(op:Op, separateStart: Bool = false, separateEnd : Bool = false){
            knownOps[op.description] = op
            opsSeparatorStart[op.description] = separateStart
            opsSeparatorEnd[op.description] = separateEnd
        }
        learnOp(Op.BinaryOperation("×", {$0*$1}), separateStart: true, separateEnd: true)
        learnOp(Op.BinaryOperation("+", {$0+$1}))
        learnOp(Op.BinaryOperation("-", {$1-$0}), separateStart: false, separateEnd: true)
        learnOp(Op.BinaryOperation("÷", {$1/$0}), separateStart: true, separateEnd: true)
        learnOp(Op.UnaryOperation("√"){sqrt($0)})
        learnOp(Op.UnaryOperation("sin"){sin($0)})
        learnOp(Op.UnaryOperation("cos"){cos($0)})
        learnOp(Op.Constant("π", M_PI))
        learnOp(Op.UnaryOperation("+/-", {-$0}))
    }
    
    var program: AnyObject{
        //is a propertyList
        get{
            return opStack.map {$0.description}
        }
        set{
            if let opSymbols = newValue as? Array<String>
            {
                var newOpStack = [Op]()
                for opSymbol in opSymbols{
                    if let op = knownOps [opSymbol]{
                        newOpStack.append(op)
                    }else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue{
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    func pushOperand(operand: Double) -> (result: Double?, operators: String?)?{
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    func performOperation(symbol: String) -> (result: Double?, operators: String?)?{
        if let operation = knownOps  [symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    private func evaluate( ops:[Op]) -> (result:Double?, remainingOps: [Op]){
        if !ops.isEmpty{
            var remainingOps = ops;
            let op = remainingOps.removeLast()
            switch op{
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result{
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .Constant(_, let value):
                return (value, remainingOps)
            case .BinaryOperation(_, let operation):
                    let op1Evaluation = evaluate(remainingOps)
                    if let operand1 = op1Evaluation.result
                    {
                        let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                        if let operand2 = op2Evaluation.result
                        {
                            return (operation(operand1, operand2), op2Evaluation.remainingOps)
                        }
                    }
            }
        }
        return (nil, ops)
    }
    func clear(){
        opStack.removeAll()
    }
    func evaluate() -> (result: Double?, operators: String?)? {
        let (result, remainder) = evaluate(opStack)
        let reversed = opStack.reverse()
        let operators = reversed.reduce("", combine: {"\($0)\($1.description),"})
        let range = Range<String.Index>(start: operators.startIndex, end: operators.startIndex.advancedBy(operators.characters.count-1))
        print ("\(opStack) = \(result) with \(remainder) left over")
        return (result, operators.substringWithRange(range))
    }
}