import Foundation

class Tokenizer {
    var tokens: [Token] = []
    var parameters: [Character:Character] = [halt : _]
    private var characters: [Character] = []
    private var chunks: [Character] = []
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
    func Tokenize(_ line: String) {
        var chunk: String
        characters = TranslateLineToCharacters(line)
        chunks = TranslateToChunks(characters)
        for i in 0..<chunks.count {
            chunk = String(chunk[i].lowercase())
            //check for registers (contains r first and then a number)
            if chunk.contains("r") {}
            //check for LabelDefinition
            //check for Label
            //check for ImmediateString
            //check for ImmediateInteger
            //check for Instruction
            //check for Directive
            //check for BadToken
            
            //if token is a valid instruction, convert characters to token
            if chunks[i] == instruction {}
            //else don't add it to the tokens array
        }
    }
}
