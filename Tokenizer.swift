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
    case Data   //this is only used by the assembler
}
//Modification: Original had CustomStringConvertible because it was causing errors
struct Token: CustomStringConvertible {
    let type: TokenType
    let intValue: Int?
    let stringValue: String?
    let tupleValue: Tuple?
    var description: String {
        var desc = "\(self.type)";
        if (intValue != nil) {
            desc += " #\(intValue!)";
        }
        if (stringValue != nil) {
            desc += " \"\(stringValue!)\"";
        }
        if (tupleValue != nil) {
            desc += " / \(tupleValue!) /";
        }
        return desc;
    }
}
//;state|input|next state|write|dir
struct Tuple: CustomStringConvertible {
    var state: Int
    var input: Character;
    var nextState: Int;
    var write: Character;
    var dir: Character;
    init(_ state: Int, _ input: Character, _ nextState: Int, _ write: Character, _ dir: Character) {
        self.state = state;
        self.input = input;
        self.nextState = nextState;
        self.write = write;
        self.dir = dir;
    }
    var description: String {
        return "\(state) \(input) \(nextState) \(write) \(dir)"
    }
}
//any reasonable language will let you treat a string as an array of chars, making this class pointless. Alas, swift is not a reasonable language.
class Chunk: CustomStringConvertible {
    var string: String
    var chars: [Character]
    init(string: String, chars: [Character]) {
        self.string = string;
        self.chars = chars;
    }
    var description: String {
        return "\"\(string)\""
    }
}

//this class takes a string of a single line and converts it to an array of tokens
//for example:
//"Loop: cmpir #1 r10" -> [LabelDefinition, Instruction, ImmediateInteger, BadToken]
class Tokenizer {
    //array containing all instructions (this is initialized in init)
    var instructionNames: [String] = []
    init() {
        //sets up "instructions" as an array containing all instruction names in the form of strings
        for i in 0..<58 {
            instructionNames.append("\(instruction(rawValue: i)!)");
        }
    }
    //takes a string and outputs [character]
    func stringToCharacters(_ line: String) -> [Character] {
        var characters: [Character] = []
        //SWIFT 4: let strings: [String] = line.map{ String($0) }
        let strings: [String] = line.unicodeScalars.map{ String($0) }
        for i in 0..<strings.count{
            characters.append(Character(strings[i]))
        }
        return characters
    }
    //converts a string to a Chunk. The division normally occurs at spaces, except when inside a string or a tuple
    func stringToChunks(_ line: String) -> [Chunk]{
        var inString = false;
        var inTuple = false;
        var stringArray: [String] = [];
        let chars = stringToCharacters(line);
        var word = ""
        for i in chars {
            if ((i == "\t" || i == " ") && !inString && !inTuple) {
                if (word != "") {
                    stringArray.append(word);
                    word = "";
                }
                continue;
            }
            if (i == "\"") {
                if (!inTuple){inString = !inString}
            }
            if (i == "\\") {
                if (!inString){inTuple = !inTuple}
            }
            //a comment is the same as a linebreak, assuming it is in neither a string nor a tuple
            if (i == ";" && !inTuple && !inString) {
                break;
            }
            word.append(i);
        }
        if (word != "") {
            stringArray.append(word);
        }
        var chunkArray: [Chunk] = [];
        for i in stringArray {
            chunkArray.append(Chunk(string: i.lowercased(), chars: stringToCharacters(i.lowercased())))
        }
        return chunkArray;
    }
    
    //these functions take a chunk and attempt to convert it to a token, if possible. They return nil if not.
    func chunkToInstruction(_ c: Chunk)->Token? {
        let index = instructionNames.index(of: c.string);
        if index != nil {
            return Token(type: .Instruction, intValue: index, stringValue: nil, tupleValue: nil)
        }
        return nil;
    }
    func chunkToRegister(_ c: Chunk)->Token? {
        //can't be a register if it doesn't follow format of "rX"
        if (c.chars.count != 2 || c.chars[0] != "r") {
            return nil;
        }
        //if "X" is a number, it's a register. else, not
        let registerNumber = Int(String(c.chars[1]));
        if (registerNumber != nil) {
            return Token(type: .Register, intValue: registerNumber, stringValue: nil, tupleValue: nil)
        }
        return nil;
    }
    func chunkToString(_ c : Chunk)->Token? {
        //if starts and ends with quotes, and contains characters within it, it's a string
        if (c.chars[0] == "\"") && (c.chars[c.chars.count - 1] == "\"") && (c.chars.count > 2) {
            var substring = ""  //the string but without the quotes
            for i in 1..<c.chars.count-1 {
                substring.append(c.chars[i])
            }
            return Token(type: .ImmediateString, intValue: nil, stringValue: substring, tupleValue: nil)
        }
        return nil;
    }
    func chunkToInt(_ c: Chunk)->Token? {
        //an int must begin with a "#"
        if (c.chars[0] != "#") {
            return nil;
        }
        var substring = ""  //the string but without the #
        for i in 1..<c.chars.count {
            substring.append(c.chars[i])
        }
        let number = Int(substring);
        if (number != nil) {
            return Token(type: .ImmediateInteger, intValue: number, stringValue: nil, tupleValue: nil)
        }
        return nil;
    }
    func chunkToDirective(_ c: Chunk)->Token? {
        let isDirective = (c.string == ".string" || c.string == ".integer" || c.string == ".tuple" || c.string == ".start" || c.string == ".end" || c.string == ".allocate");
        if (isDirective) {
            return Token(type: .Directive, intValue: nil, stringValue: c.string, tupleValue: nil);
        }
        return nil;
    }
    func chunkToTuple(_ c: Chunk)->Token? {
        let explodedTuple = c.string.components(separatedBy: " ");
        if (explodedTuple.count != 7) {
            return nil;
        }
        var isValidTuple = true;    //checks if the potential tuple...
        isValidTuple = isValidTuple && (explodedTuple[0] == "\\")   //starts with /
        isValidTuple = isValidTuple && (Int(explodedTuple[1]) != nil)  //is a valid int
        //SWIFT 4: isValidTuple = isValidTuple && (explodedTuple[2].count == 1)
        isValidTuple = isValidTuple && (explodedTuple[2].characters.count == 1)   //is a valid character
        isValidTuple = isValidTuple && (Int(explodedTuple[3]) != nil)
        //SWIFT 4: isValidTuple = isValidTuple && (explodedTuple[4].count == 1)
        isValidTuple = isValidTuple && (explodedTuple[4].characters.count == 1)
        isValidTuple = isValidTuple && (explodedTuple[5] == "r" || explodedTuple[5] == "l")    //is either r or l
        isValidTuple = isValidTuple && (explodedTuple[6] == "\\") //ends with /
        if (isValidTuple) {
            return Token(type: .ImmediateTuple, intValue: nil, stringValue: nil, tupleValue: Tuple(Int(explodedTuple[1])!, Character(explodedTuple[2]), Int(explodedTuple[3])!, Character(explodedTuple[4]), Character(explodedTuple[5])));
        }
        return nil;
    }
    func chunkToLabel(_ c: Chunk)->Token? {
        //a label cannot start with something that's not a letter
        //SWIFT 4: if (!CharacterSet.letters.contains(Unicode.Scalar(characterToUnicodeValue(c.chars[0]))!)) {
        if (!CharacterSet.letters.contains(UnicodeScalar(characterToUnicodeValue(c.chars[0]))!)) {
            return nil;
        }
        //a label cannot be a register or a label definition or an instruction
        if (c.chars[c.chars.count - 1] == ":" || chunkToRegister(c) != nil || chunkToInstruction(c) != nil) {
            return nil;
        }
        return Token(type: .Label, intValue: nil, stringValue: c.string, tupleValue: nil)
    }
    func chunkToLabelDefinition(_ c: Chunk)->Token? {
        //a label cannot start with something that's not a letter
        //SWIFT 4: if (!CharacterSet.letters.contains(Unicode.Scalar(characterToUnicodeValue(c.chars[0]))!)) {
        if (!CharacterSet.letters.contains(UnicodeScalar(characterToUnicodeValue(c.chars[0]))!)) {
            return nil;
        }
        //a label cannot be a register or an instruction
        if (chunkToRegister(c) != nil || chunkToInstruction(c) != nil) {
            return nil;
        }
        //and a label definition must end with a ":"
        if (c.chars[c.chars.count - 1] == ":") {
            var substring = "";
            for i in 0..<c.chars.count - 1 {
                substring.append(c.chars[i])
            }
            return Token(type: .LabelDefinition, intValue: nil, stringValue: substring, tupleValue: nil)
        }
        return nil
    }
    //this function takes a chunk and converts it to the appropriate token type
    func chunkToToken(_ c: Chunk)->Token {
        var token: Token? = nil;
        token = chunkToRegister(c);
        if (token != nil) {
            return token!;
        }
        token = chunkToInt(c);
        if (token != nil) {
            return token!;
        }
        token = chunkToDirective(c);
        if (token != nil) {
            return token!;
        }
        token = chunkToInstruction(c);
        if (token != nil) {
            return token!;
        }
        token = chunkToTuple(c);
        if (token != nil) {
            return token!;
        }
        token = chunkToString(c);
        if (token != nil) {
            return token!;
        }
        token = chunkToLabelDefinition(c);
        if (token != nil) {
            return token!;
        }
        token = chunkToLabel(c);
        if (token != nil) {
            return token!;
        }
        return Token(type: .BadToken, intValue: nil, stringValue: nil, tupleValue: nil);
    }
    func Tokenize(_ line: String)->[Token] {
        let chunks = stringToChunks(line)
        var tokens: [Token] = [];
        for i in chunks {
            tokens.append(chunkToToken(i));
        }
        return tokens;
    }
}
