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

struct Token: CustomStringConvertible {
    let type: TokenType
    let intValue: Int?
    let stringValue: String?
    let tupleValue: Tuple?
}

struct Tuple: CustomStringConvertible {
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
    var characters: [Character] = []
    var chunks: [Character] = []
    //CONTINUE
    func TranslateLineToCharacters(_ line: Int) {
        
    }
    func TranslateToChunks() {
        var index = 0
        var done = false
        while done != true {
            for i in 0..<characters.count{
                if characters[i] != Character(" ") {
                    //no space between characters
                    chunks[index] = Character("\(chunks[index])\(characters[i])")
                } else {
                    //space between characters, move on to next chunk
                    index += 1
                }
            }
            done = true
        }
    }
    func convertLineToBinary(_ line: Int)->Bool{
        switch accessArray(line) {
        //HINT FROM MR.STULIN
        case movrr:
            break
        case movmr:
            break
        //CONTINUE
        default:
            print("ERROR Unknown instruction \"\(arrayOfLines[line])\" at line \(line)")
            return true
        }
        if (error != 0) {
            print("ERROR #\(error) \(errorMessages[error]) at line \(line) (instruction \(accessArray(line)))");
            error = 0;
            return true;
        }
        return false;
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
