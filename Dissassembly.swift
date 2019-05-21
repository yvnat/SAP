import Foundation

class Disassembler {
    //Where we're at in the binary code
    var currentLocation = 0
    var Instructions = Assembler.instructionParameters
    var symbolTable: [String : Int]
    //Binary Code
    var memory: [Int]
    //Resulting Assembly Code
    var resultLines: [String] = []
    var parameters: [TokenType] {return Instructions[instruction(rawValue: currentLocation)]}
    init(symbolTable: [String:Int], memory: [Int]) {
        self.memory = memory
        self.symbolTable = symbolTable
    }
    func givenParameter(_ parameter: TokenType, _ value: Int) -> Bool {
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
    func matchParameters()->Bool {
        //var parameters: [TokenType] = Instructions[instruction(rawValue: location)]
        for i in 0..<parameters.count {
            //if parameters make sense
            if givenParameter(parameters[i], memory[currentLocation + i + 1]) == false {
                return false
            }
        }
        return true
    }
    func lineToAssembly() {
        if matchParameters() == true {
            var d = ""
            d = "\(Instructions[currentLocation])"
            for i in 1..<(parameters.count + 1) {
                //add parameters
                d += " \(Instructions[instruction(rawValue: currentLocation)])"
            }
            resultLines.append(d)
            currentLocation += 1 + parameters.count
        }
    }
    func convertBinaryToAssembly() {
        while currentLocation < memory.count - 2 {
            lineToAssembly()
        }
    }
}
