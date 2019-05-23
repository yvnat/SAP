import Foundation

func splitStringIntoParts(expression: String)->[String]{
    return expression.characters.split{$0 == " "}.map{ String($0) }
}
func splitStringIntoLines(expression: String)->[String]{
    return expression.characters.split{$0 == "\r" || $0 == "\n"}.map{ String($0) }
}
class Assembler {
    static var instructionParameters: [instruction : [TokenType]] = [
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
    var errors = "";
    var startLocation: String? = nil;
    var wasEnded = false;   //set to true if encounters the .end directive
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
    func addStringToMemory(_ token: Token) {
        //SWIFT 4: program.append(Token(type: TokenType.Data, intValue: token.stringValue!.count, stringValue: nil, tupleValue: nil))
        program.append(Token(type: TokenType.Data, intValue: token.stringValue!.characters.count, stringValue: nil, tupleValue: nil))
        //SWIFT 4: for i in token.stringValue! {
        for i in token.stringValue!.characters {
            program.append(Token(type: TokenType.Data, intValue: characterToUnicodeValue(i), stringValue: nil, tupleValue: nil))
        }
    }
    //takes r or l, returns 1 or 0
    func convertDirToBool(_ c: Character)->Int {
        return (c == "r") ? 1 : 0
    }
    //;state|input|next state|write|dir
    func addTupleToMemory(_ token: Token) {
        let tuple = token.tupleValue!;
        program.append(Token(type: TokenType.Data, intValue: tuple.state, stringValue: nil, tupleValue: nil));
        program.append(Token(type: TokenType.Data, intValue: characterToUnicodeValue(tuple.input), stringValue: nil, tupleValue: nil));
        program.append(Token(type: TokenType.Data, intValue: tuple.nextState, stringValue: nil, tupleValue: nil));
        program.append(Token(type: TokenType.Data, intValue: characterToUnicodeValue(tuple.write), stringValue: nil, tupleValue: nil));
        program.append(Token(type: TokenType.Data, intValue: convertDirToBool(tuple.dir), stringValue: nil, tupleValue: nil));
    }
    func allocateMemory(_ token: Token) {
        for _ in 0..<token.intValue! {
            program.append(Token(type: TokenType.Data, intValue: 0, stringValue: nil, tupleValue: nil))
        }
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
            var parameters = Assembler.instructionParameters[instruction(rawValue: instructionType)!]!
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
                program.append(line[index]);
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
            index += 1;
            //immediately stop on .end
            if (directiveType == ".end") {
                wasEnded = true;
                return true;
            }
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
                //handle memory
                if (directiveType == ".string") {
                    addStringToMemory(line[index])
                }
                if (directiveType == ".tuple") {
                    addTupleToMemory(line[index])
                }
                if (directiveType == ".allocate") {
                    allocateMemory(line[index])
                }
                if (directiveType == ".integer") {
                    program.append(line[index])
                }
                if (directiveType == ".start") {
                    startLocation = line[index].stringValue!;
                }
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
    }
    func convertToBinary(_ stringProgram: String)->[Int]{
        //function converts assembly code string to binary code
        let tokenizer = Tokenizer()
        //split the program into individual lines
        let lines = splitStringIntoLines(expression: stringProgram);
        /////////////pass one: get tokens, verify that they make sense
        for i in 0..<lines.count {
            let tokens = tokenizer.Tokenize(lines[i]);
            verifyLine(tokens, i + 1);
            if (wasEnded) {
                break;
            }
        }
        //post pass one error checking
        //check if all labels are accounted for
        for (symbol, location) in symbolsTable {
            if (location == -1) {
                errors += "[symbolTable] symbol \(symbol) mentioned but never defined\n";
            }
        }
        //check if there were any errors during line verification
        if (errors != "")  {
            return []
        }
        /////////////pass two: convert tokens to binary
        var assembledProgram: [Int] = [];
        for i in program {
            if (i.type == TokenType.Instruction || i.type == TokenType.ImmediateInteger || i.type == TokenType.Data || i.type == TokenType.Register) {
                assembledProgram.append(i.intValue!);
            }
            else if (i.type == TokenType.Label) {
                assembledProgram.append(symbolsTable[i.stringValue!]!);
            } else {
                //this should not happen
                print("UNEXPECTED TOKEN TYPE \(i.type) IN PROGRAM AFTER FIRST PASS");
                return [];
            }
        }
        //just add count and start location
        assembledProgram.insert(assembledProgram.count, at: 0);
        if (startLocation == nil) {
            errors += "[dir] no start location specified. specify start location with \".start <label>\""
            return [];
        }
        assembledProgram.insert(symbolsTable[startLocation!]!, at: 1);
        return assembledProgram;
    }
    func symbolsTableToString()->String {
        var s = ""
        for i in symbolsTable {
            s += "\(i.key):\(i.value)\n";
        }
        return s;
    }
    //take a path to the code, output the files
    func assemble(path: String)->Bool {
        errors = "";
        do {
            let stringProgram = try String(contentsOfFile: "\(path).txt", encoding: String.Encoding.utf8);
            let binaryCode = convertToBinary(stringProgram);
            //if errors, write them to file
            if (binaryCode == []) {
                print("Assembly incomplete. See listing file for errors.")
                try errors.write(toFile: "\(path).lst", atomically: false, encoding: .utf8)
                return false;
            }
            //if no errors, write program to file
            var assembledProgram = "";
            for i in binaryCode {
                assembledProgram += "\(i)\n";
            }
            try assembledProgram.write(toFile: "\(path).bin", atomically: false, encoding: .utf8)
            try symbolsTableToString().write(toFile: "\(path).sym", atomically: false, encoding: .utf8)
            print("Assembly successful.")
            return true;
        }
        catch {
            print("Contents Failed To Load (\(path))");
        }
        print("An unexpected error has occured and assembly aborted")
        return false;
    }
}
