import Foundation

class Dissassembler {
    var symbolTable: [String : Int]
    var memory: [Int]
    init(symbolTable: [String:Int], memory: [Int]) {
        self.memory = memory
        self.symbolTable = symbolTable
    }
    func givenParameter(parameter: TokenType, value: Int) -> Bool {
        switch parameter {
        case .Register:
            return value > 0 && value < 10
        case .Label:
            for i in symbolTable {
                if i.value == value {
                    return true
                }
            }
            return false
        case .ImmediateInteger:
            return true
        default:
            print("Unexpected Parameter Type: \(parameter)")
            return false
        }
    }
    func matchParameters(location: Int)->Bool {
        var parameters: [TokenType] = Assembler.instructionParameters[instruction(rawValue: location)]
        for i in 0..<parameters.count {
            //if parameters make sense
            if givenParameter(parameter: parameters[i], value: memory[location + i + 1]) == false {
                return false
            }
        }
        
        return true
    }
    func lineToAssembly() {
        
    }
    func convertBinaryToAssembly() {
        
    }
}
