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
//Modification: Original had CustomStringConvertible but it was causing errors
struct Token {
    let type: TokenType
    let intValue: Int?
    let stringValue: String?
    let tupleValue: Tuple?
}
//Modification: Original had CustomStringConvertible but it was causing errors
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
    //CONTINUE
    func TranslateLineToCharacters(_ line: String) -> [Character] {
        var characters: [Character] = []
        let strings: [String] = splitStringIntoParts(expression: line)
        for i in 0..<strings.count{
            characters.append(Character(strings[i]))
        }
        return characters
    }
    func TranslateToChunks(_ characters: [Character]) -> [Character]{
        var chunks: [Character] = []
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
        return chunks
    }
    enum instruction: Int {
        case halt = 0
        case clrr = 1
        case clrx = 2
        case clrm = 3
        case clrb = 4
        case movir = 5
        case movrr = 6
        case movrm = 7
        case movmr = 8
        case movxr = 9
        case movar = 10
        case movb = 11
        case addir = 12
        case addrr = 13
        case addmr = 14
        case addxr = 15
        case subir = 16
        case subrr = 17
        case submr = 18
        case subxr = 19
        case mulir = 20
        case mulrr = 21
        case mulmr = 22
        case mulxr = 23
        case divir = 24
        case divrr = 25
        case divmr = 26
        case divxr = 27
        case jmp = 28
        case sojz = 29
        case sojnz = 30
        case aojz = 31
        case aojnz = 32
        case cmpir = 33
        case cmprr = 34
        case cmpmr = 35
        case jmpn = 36
        case jmpz = 37
        case jmpp = 38
        case jsr = 39
        case ret = 40
        case push = 41
        case pop = 42
        case stackc = 43
        case outci = 44
        case outcr = 45
        case outcx = 46
        case outcb = 47
        case readi = 48
        case printi = 49
        case readc = 50
        case readln = 51
        case brk = 52
        case movrx = 53
        case movxx = 54
        case outs = 55
        case nop = 56
        case jmpne = 57
    }
    let path = "BinaryCode.txt"
    func convertLineToBinary(_ line: Int)->Bool{
        //function converts a line of assembly code to binary code
        //checks if line exceeds the number of lines in the assembly code
        if line >= arrayOfLines.count {
            return false
        }
        let characters: [Character] = TranslateLineToCharacters(arrayOfLines[line])
        let chunks: [Character] = TranslateToChunks(characters)
        var contents = ""
        for i in 0..<chunks.count {
            do {
                contents = String(chunks[i])
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
