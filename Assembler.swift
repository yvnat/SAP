import Foundation

func splitStringIntoParts(expression: String)->[String]{
    return expression.characters.split{$0 == " "}.map{ String($0) }
}
func splitStringIntoLines(expression: String)->[String]{
    return expression.characters.split{$0 == "\r" || $0 == "\n"}.map{ String($0) }
}
/*
 for i in tokenLine
     checkIfTokensValid()
     markLabels()
 
 */
class Assembler {
    var instructionParameters: [instruction : [TokenType]] = [
        .halt:[],
        .clrr:[.Register],
        .clrx:[.Register],
        .clrm:[.Label],
        .clrb:[.Register, .Register],
        .movir:[.ImmediateInteger, .Register],
        .movrr:[.Register, .Register],
        .movrm:[.Register, .Label],
        .movmr:[.Label, .Register],
        .movxr:[.Register, .Register],
        .movar:[.Label, .Register],
        .movb:[.Register, .Register, .Register],
        .addir:[.ImmediateInteger, .Register],
        .addrr:[.Register, .Register],
        .addmr:[.Label, .Register],
        .addxr:[.Register, .Register],
        .subir:[.ImmediateInteger, .Register],
        .subrr:[.Register, .Register],
        .submr:[.Label, .Register],
        .subxr:[.Register, .Register],
        .mulir:[.ImmediateInteger, .Register],
        .mulrr:[.Register, .Register],
        .mulmr:[.Label, .Register],
        .mulxr:[.Register, .Register],
        .divir:[.ImmediateInteger, .Register],
        .divrr:[.Register, .Register],
        .divmr:[.Label, .Register],
        .divxr:[.Register, .Register],
        .jmp:[.Label],
        .sojz:[.Register, .Label],
        .sojnz:[.Register, .Label],
        .aojz:[.Register, .Label],
        .aojnz:[.Register, .Label],
        .cmpir:[.ImmediateInteger, .Register],
        .cmprr:[.Register, .Register],
        .cmpmr:[.Label, .Register],
        .jmpn:[.Label],
        .jmpz:[.Label],
        .jmpp:[.Label],
        .jsr:[.Label],
        .ret:[],
        .push:[.Register],
        .pop:[.Register],
        .stackc:[.Register],
        .outci:[.ImmediateInteger],
        .outcr:[.Register],
        .outcx:[.Register],
        .outcb:[.Register, .Register],
        .readi:[.Register, .Register],
        .printi:[.Register],
        .readc:[.Register],
        .readln:[.Label, .Register],
        .brk:[],
        .movrx:[.Register, .Register],
        .movxx:[.Register, .Register],
        .outs:[.Label],
        .nop:[],
        .jmpne:[.Label]
    ]
    var directiveParameters: [String : [TokenType]] = [
        ".start":[.Label],
        ".end":[],
        ".integer":[.ImmediateInteger],
        ".allocate":[.ImmediateInteger],
        ".string":[.ImmediateString],
        ".tuple":[.ImmediateTuple],
    ]
    var symbolsTable: [String:Int] = [:];
    var program: [Token] = [];
    var errors = "Compile Errors:\n";
    
    var arrayOfLines: [String] = []
    var error = 1
    //WE NEED ERROR CHECKING
    //HINT FROM MR.STULIN:
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
    //this function handles directives like .allocate or .string that reserve memory. It does this by adding a bunch of "Data" tokens with the appropriate memory
    func handleDirectiveMemory(_ parameter: Token) {
        
    }
    //this function takes a line and verifies that it is correct
    func verifyLine(_ line: [Token], _ lineNumber: Int)->Bool {
        //an empty line is always correct
        if (line.count == 0) {
            return true;
        }
        var hadLabel = 0;
        var index = 0;
        //first, note if line begins with a label. If it does, mark it and move on.
        if (line[index].type == TokenType.LabelDefinition) {
            //if the label is a redefinition, that is bad
            if (symbolsTable[line[index].stringValue!] != nil && symbolsTable[line[index].stringValue!] != -1) {
                errors += "[Line \(lineNumber)] redefinition of label \"\(line[index].stringValue!)\": previously defined at location \(symbolsTable[line[index].stringValue!]!)\n";
                return false;
            }
            symbolsTable[line[index].stringValue!] = program.count;
            index+=1;
            hadLabel = 1;
            if (line.count == 1) {
                //a lone label is acceptable
                return true;
            }
        }
        //following the possible label, the next token must be either instruction or directive
        if (line[index].type == TokenType.Instruction) {
            //assume everything else is parameters and check if they are correct accordingly
            var i = 0;
            let instructionType = line[index].intValue!
            var parameters = instructionParameters[instruction(rawValue: instructionType)!]!
            //add the instruction to the program, then move to parameters
            program.append(line[index])
            index += 1;
            //loop through parameters, ensuring they match expected ones
            while (index < line.count && i < parameters.count) {
                if (parameters[i] != line[index].type) {
                    errors += "[Line \(lineNumber)] parameter mismatch at token #\(index + 1): expected \(parameters[i]), got \(line[index].type)\n";
                    return false;
                }
                //mark any labels being called, assuming they haven't been declared
                if (line[index].type == TokenType.Label) {
                    if symbolsTable[line[index].stringValue!] == nil {
                        symbolsTable[line[index].stringValue!] = -1;
                    }
                }
                //handle program and memory
                if (line[index].)
                index += 1;
                i += 1;
            }
            //then make sure the right number of parameters was provided
            if (i != parameters.count) {
                errors += "[Line \(lineNumber)] too few parameters for instruction \(instruction(rawValue: instructionType)!): expected \(parameters.count), got \(i)\n";
                return false;
            }
            if (index != line.count) {
                errors += "[Line \(lineNumber)] too many parameters for instruction \(instruction(rawValue: instructionType)!): expected \(parameters.count), got \(line.count - 1 - hadLabel)\n";
                return false;
            }
            //if nothing is wrong, line is correct
            return true;
        }
        else if (line[index].type == TokenType.Directive) {
            //assume everything else is parameters and check if they are correct accordingly
            var i = 0;
            let directiveType = line[index].stringValue!
            var parameters = directiveParameters[directiveType]!
            program.append(line[index])
            index += 1;
            //loop through parameters, ensuring they match expected ones
            while (index < line.count && i < parameters.count) {
                if (parameters[i] != line[index].type) {
                    errors += "[Line \(lineNumber)] parameter mismatch at token #\(index + 1): expected \(parameters[i]), got \(line[index].type)\n";
                    return false;
                }
                //mark any labels being called, assuming they haven't been declared
                if (line[index].type == TokenType.Label) {
                    if symbolsTable[line[index].stringValue!] == nil {
                        symbolsTable[line[index].stringValue!] = -1;
                    }
                }
                program.append(line[index])
                index += 1;
                i += 1;
            }
            //then make sure the right number of parameters was provided
            if (i != parameters.count) {
                errors += "[Line \(lineNumber)] too few parameters for directive \(directiveType): expected \(parameters.count), got \(i)\n";
                return false;
            }
            if (index != line.count) {
                errors += "[Line \(lineNumber)] too many parameters for directive \(directiveType): expected \(parameters.count), got \(line.count - 1 - hadLabel)\n";
                return false;
            }
            //if nothing is wrong, line is correct
            return true;
        }
        else {
            errors += "[Line \(lineNumber)] expected token #\(index + 1) to be instruction or directive; instead, it is \(line[index].description)\n";
            return false;
        }
        return true;
    }
    let path = "BinaryCode.txt"
//    func convertLineToBinary(_ line: Int)->Bool{
//        //function converts a line of assembly code to binary code
//        //checks if line exceeds the number of lines in the assembly code
//        if line >= arrayOfLines.count {
//            return false
//        }
//        let tokens = Tokenizer()
//        tokens.Tokenize(arrayOfLines[line])
//        //Write to file as binary code
//        var contents = ""
//        for i in 0..<tokens.tokens.count {
//            do {
//                contents = String(describing: tokens.tokens[i])
//                try contents.write(toFile: path, atomically: false, encoding: .utf8)
//            }
//            catch let error as NSError {
//                print("Unable to save to file: \(error)")
//            }
//        }
//        return true
//    }
//    func assemble() {
//        while true {
//            //execute the current line and note if it is a halt
//            let halt = convertLineToBinary(currentLine);
//            //halt if the current instruction is halt
//            if (halt) {
//                break
//            }
//            //and of course increment the current line
//            currentLine += 1;
//        }
//    }
}

