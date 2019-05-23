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
    init(symbolTable: [String:Int], memory: [Int]) {
        self.memory = memory
        self.symbolTable = symbolTable
    }
    func givenParameter(_ parameter: TokenType, _ value: Int) -> Bool {
        switch parameter {
        case .Register:
            return value >= 0 && value < 10
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
    //this takes in the value of the instruction (i.e. 0 for halt) and returns whether the things after it work as arguments
    func matchParameters(instructionValue: Int)->Bool {
        let opt_instruction = instruction(rawValue: instructionValue)
        //if not valid instruction, return false
        if opt_instruction == nil {
            print("Disassembly error: no instruction #\(instructionValue)")
            return false;
        }
        var parameters: [TokenType] = Instructions[opt_instruction!]!
        for i in 0..<parameters.count {
            //if ran out of memory, return false
            if currentLocation + i + 1 >= memory.count {
                print("Disassmebly error: memory bounds end within expected parameters")
                return false;
            }
            //if parameters don't make sense, return false
            if givenParameter(parameters[i], memory[currentLocation + i + 1]) == false {
                print("Disassembly error: parameters invalid at \(currentLocation) for instruction \(opt_instruction!) (expected \(parameters[i]), got \(memory[currentLocation + i + 1])))")
                return false
            }
        }
        return true
    }
    func valueToString(value: Int, type: TokenType)->String {
        switch type {
        case .Register:
            return "r\(value)"
        case .Label:
            //for i in symbolTable {
                //if i.value == value {
                    //return i.key
                //}
            //}
            for i in symbolTable.keys {
                if symbolTable[i] == value {
                    //DEBUGGING
                    print("Label: \(i)")
                    return i
                }
            }
            print("UNEXPECTED ERROR CANNOT FIND LABEL")
        case .ImmediateInteger:
            return "#\(value)"
        default:
            return "UNEXPECTED ERROR"
        }
        return "UNEXPECTED ERROR2"
    }
    //converts the next line to assembly.
    //returns true on success, false on failure
    func lineToAssembly()->Bool {
        if (currentLocation >= memory.count) {
            print("Disassembly error: location out of bounds")
            return false
        }
        if matchParameters(instructionValue: memory[currentLocation]) == true {
            var parameters = Instructions[instruction(rawValue: currentLocation)!]!
            var d = ""
            d = "\(instruction(rawValue: currentLocation)!)"  //it is fine to unwrap because matchParameters already checks for valid instruction
            currentLocation += 1
            for i in 0..<parameters.count {
                //add parameters
                d += " " + valueToString(value: memory[currentLocation], type: parameters[i])
                currentLocation += 1
            }
            resultLines.append(d)
            return true
        } else {
            return false
        }
    }
    func convertBinaryToAssembly() {
        currentLocation = 0;
        resultLines = [];
        while currentLocation < memory.count {
            if lineToAssembly() == false {
                for i in resultLines {
                    print("    " + i)
                }
                return
            }
        }
        for line in resultLines {
            print(line)
        }
    }
}
