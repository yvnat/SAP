import Foundation

enum TokenType {
    case Register
    case LabelDefinition
    case Label
    case ImmediateString
    case ImmediateInteger
    case ImmediateTuple
    case Instruction
    case Directive
    case BadToken
}
//Modification: Original had CustomStringConvertible because it was causing errors
struct Token {
    let type: TokenType
    let intValue: Int?
    let stringValue: String?
    let tupleValue: Tuple?
}
//Modification: Original had CustomStringConvertible because it was causing errors
struct Tuple {
    let currentState: Int
    let inputCharacter: Int
    let newState: Int
    let outputCharacter: Int
    let direction: Int
}

func charToAscii(c: Character)->Int{
    return Int(String(c).utf8.first!)
}
func AsciiToChar(n: Int)->Character{
    return Character(UnicodeScalar(n)!)
}

func splitStringIntoParts(expression: String)->[String]{
    return expression.characters.split{$0 == " "}.map{ String($0) }
}
func splitStringIntoLines(expression: String)->[String]{
    return expression.characters.split{$0 == "\r" || $0 == "\n"}.map{ String($0) }
}

class Assembler {
    var arrayOfLines: [String] = []
    var currentLine = 0
    var errorMessages = ["ERROR: NO ERROR", "Illegal memory address"]
    var error = 1
    //WE NEED ERROR CHECKING
    //HINT FROM MR.STULIN:
    var instructionParameters: [String:String] = [:]
    func loadProgram(_ program: [String]) {
        for i in 0..<program.count{
            arrayOfLines[i] = program[i]
        }
    }
    func accessArray(_ index: Int)->String {
        if (index >= 0 && index < arrayOfLines.count) {
            return arrayOfLines[index]
        }
        error = 1
        return "" //TODO: make this crash
    }
    let path = "BinaryCode.txt"
    func convertLineToBinary(_ line: Int)->Bool{
        //function converts a line of assembly code to binary code
        //checks if line exceeds the number of lines in the assembly code
        if line >= arrayOfLines.count {
            return false
        }
        let tokens = Tokenizer()
        tokens.Tokenize(arrayOfLines[line])
        //Write to file as binary code
        var contents = ""
        for i in 0..<tokens.tokens.count {
            do {
                contents = String(tokens.tokens[i])
                try contents.write(toFile: path, atomically: false, encoding: .utf8)
            }
            catch let error as NSError {
                print("Unable to save to file: \(error)")
            }
        }
        return true
    }
    func assemble() {
        while true {
            //execute the current line and note if it is a halt
            let halt = convertLineToBinary(currentLine);
            //halt if the current instruction is halt
            if (halt) {
                break
            }
            //and of course increment the current line
            currentLine += 1;
        }
    }
}
