//test
//this file stores the class that executes the code
//no relation to capital punishment
//crash conditions: out of memory, illegal instruction, div by 0, illegal register, stack overflow
class Executioner {
    //the registers
    var registers: [Int] = Array(repeating: 0, count: 10)
    var compare = 0;  //positive if bigger, negative if smaller, 0 if equal
    //a pointer to the current memory block being executed
    var currentLine = 0;
    //it would be more valid to have these be local to the execute function, but
    //having them be a member of the class is more accurate to real world (not necessarily in a good way)
    //memory holds program
    var memory: [Int] = []
    //1 = out of memory, 2 = div by 0, 3 = illegal register, 4 = stack overflow, 5 = stack empty
    var errorMessages = ["ERROR: NO ERROR", "Illegal memory address", "Divide by 0", "Illegal register", "Stack overflow", "Stack empty"]
    var error = 0;
    var errorDetails = "";
    
    init() {
        for _ in 0..<20000 {
            memory.append(0)
        }
    }
    
    //stack
    var stack = IntStack(size: 1000)
    
    //shortcut for accessing strings
    var symbolsToStrings: [Int : String] = [:]
    
    //wrapper functions that return an appropriate error
    func accessMemory(_ index: Int)->Int {
        if (index >= 0 && index < memory.count) {
            return memory[index]
        }
        errorDetails = " \(index)/\(memory.count)";
        error = 1;
        return 0; //TODO: make this crash
    }
    func writeMemory(_ index: Int, _ what: Int) {
        if (index >= 0 && index < memory.count) {
            memory[index] = what;
            return;
        }
        errorDetails = " \(index)/\(memory.count)";
        error = 1;
        // print(index)
        return; //TODO: make this crash
    }
    func divide(_ numerator: Int, _ denominator: Int)->Int {
        if (denominator == 0) {
            error = 2
            return 0
        }
        return numerator / denominator
    }
    func accessRegister(_ register: Int)->Int {
        if (register < 0 || register > 9) {
            error = 3;
            return 0;
        }
        return registers[register]
    }
    func writeRegister(_ register: Int, _ what: Int) {
        if (register < 0 || register > 9) {
            error = 3;
            return;
        }
        registers[register] = what
    }
    func moveBlock(_ source: Int, _ destination: Int, _ length: Int) {
        //store the contents fo the block
        var block: [Int] = [];
        //move from memory to temporary storage
        for i in 0..<length {
            block.append(accessMemory(source + i));
        }
        //move to new location
        for i in 0..<length {
            writeMemory(destination + i, block[i])
        }
    }
    func printBlock(_ source: Int, _ count: Int) {
        for i in 0..<count {
            print(unicodeValueToCharacter(accessMemory(source + i)), terminator: "")
        }
    }
    //WE NEED TO FIGURE OUT WHAT readln (51) DOES AND IF THE readLine()! IS NECESSARY
    func readString(_ memoryLocation: Int, _ register: Int) {
        let input = readLine()!
        //SWIFT 4: writeRegister(register, input.count)
        writeRegister(register, input.characters.count)
        var i = 0
        //SWIFT 4: for char in input {
        for char in input.characters {
            writeMemory(memoryLocation + i, characterToUnicodeValue(char))
            i += 1;
        }
    }
    
    //this takes a [string] program, clears memory, and puts program into memory as [int]
    func loadProgram(_ program: [String]) {
        //if a program doesn't even have a length and a pointer to begin, you got a problem
        if (program.count < 3) {
            print("FATAL ERROR LOADING PROGRAM: program too short");
            return;
        }
        //read and act on program length and beginning point
        let programLength: Int? = Int(program[0])
        if (programLength == nil) {
            print("FATAL ERROR LOADING PROGRAM: Invalid length (\"\(program[0])\")");
            return;
        }
        if (programLength! != program.count - 3) {
            print("FATAL ERROR LOADING PROGRAM: mismatching lengths. Progarm has \(program.count - 3) instructions but declares \(programLength).");
            return;
        }
        let beginLine: Int? = Int(program[1])
        if (beginLine == nil) {
            print("FATAL ERROR LOADING PROGRAM: Invalid beginning (\"\(program[1])\")");
            return;
        }
        currentLine = beginLine! //this is where the program begins
        for i in 0..<program.count-3 {
            let stringToInstruction: Int? = Int(program[i + 2])
            if (stringToInstruction == nil) {
                print("FATAL ERROR LOADING PROGRAM: Invalid instruction (\"\(program[i + 2])\")");
                return;
            }
            memory[i] = stringToInstruction!;
        }
        print("Successfully loaded program")
    }
    
    func getStringFromLocation(_ pointer: Int) -> String {
        if symbolsToStrings[pointer] != nil {
            return symbolsToStrings[pointer]!
        }
        var currentIndex = pointer + 1
        let stopIndex = accessMemory(pointer) + pointer + 1
        //print("memory pointer \(memory[pointer + 2])")
        var string = ""
        while currentIndex != stopIndex {
            //print(currentIndex)
            string += String(unicodeValueToCharacter(accessMemory(currentIndex)))
            currentIndex += 1
        }
        symbolsToStrings[pointer] = string
        return symbolsToStrings[pointer]!
    }
    var lastCurrentLine = 0
    //this executes one specific line
    //returns true on halt, false otherwise
    func executeLine(_ line: Int)->Bool {
        //return false if halt
        if (accessMemory(line) == 0) {
            return true
        }
        //execute the line
        //note: memory[line + 1] = nextLine, memory[line + 2] = nextNextLine
        //I didn't make variables with those names so it doesn't cause crashes when
        //trying to access things outside memory if no arguments are needed for the instruction
        if (instruction(rawValue: accessMemory(line)) == nil) {
            print("ERROR Unknown instruction \"\(accessMemory(line))\" at line \(line)")
            return true
        }
        //        print("execusting line \(line), which contains the instruction \(accessMemory(line))/\(instruction(rawValue: accessMemory(line))!)")
        switch instruction(rawValue: accessMemory(line))! {
        case instruction.clrr:
            //clrr
            writeRegister(accessMemory(line + 1), 0)
            currentLine += 1
            break
        case instruction.clrx:
            //clrx
            writeRegister(accessRegister(accessMemory(line + 1)),0)
            break
        case instruction.clrm:
            //clrm
            writeMemory(accessMemory(line + 1), 0)
            break
        case instruction.clrb:
            //clrb
            //for i in initialPosition..<(initialPosition + count)
            for i in accessMemory(line + 1)..<(accessMemory(line + 1) + accessMemory(line + 2)) {
                writeMemory(i, 0)
            }
            break
        case instruction.movir:
            //movir
            // registers[memory[line + 2]] = registers[accessMemory(line + 1)]  //this seems wrong
            writeRegister(accessMemory(line+2), accessMemory(line+1))
            currentLine += 2
            break
        case instruction.movrr:
            //movrr
            // registers[memory[line + 2]] = registers[accessMemory(line + 1)]
            writeRegister(accessMemory(line+2), accessRegister(accessMemory(line+1)))
            currentLine += 2
            break
        case instruction.movrm:
            //movrm
            // memory[memory[line + 2]] = registers[accessMemory(line + 1)]
            writeMemory(accessMemory(line+2), accessRegister(accessMemory(line+1)))
            currentLine += 2
            break
        case instruction.movmr:
            //movmr
            // print("registers[\(memory[line + 2])] = memory[\(accessMemory(line + 1))]")
            // registers[memory[line + 2]] = memory[accessMemory(line + 1)]
            writeRegister(accessMemory(line+2), accessMemory(accessMemory(line + 1)))
            currentLine += 2
            break;
        case instruction.movxr:
            //movxr
            writeRegister(accessMemory(line+2), accessMemory(accessRegister(accessMemory(line + 1))))
            currentLine += 2
            break
        case instruction.movar:
            //movar
            writeRegister(accessMemory(line+2), accessMemory(line + 1))
            currentLine += 2
            break
        case instruction.movb:
            //movb
            moveBlock(accessRegister(accessMemory(line + 1)), accessRegister(accessMemory(line + 2)), accessRegister(accessMemory(line + 2)))
            currentLine += 3
            break
        case instruction.addir:
            //addir
            writeRegister(accessMemory(line + 2), accessRegister(accessMemory(line + 2)) + accessMemory(line + 1))
            currentLine += 2
            break;
        case instruction.addrr:
            //addrr
            writeRegister(accessMemory(line + 2), accessRegister(accessMemory(line + 2)) + accessRegister(accessMemory(line + 1)))
            currentLine += 2
            break;
        case instruction.addmr:
            //addmr
            // registers[memory[line + 2]] += memory[accessMemory(line + 1)]
            writeRegister(accessMemory(line + 2), accessMemory(line + 2) + accessMemory(accessMemory(line + 1)))
            currentLine += 2
            break
        case instruction.addxr:
            //addxr
            writeRegister(accessMemory(line+2), accessRegister(accessMemory(line+2)) - accessMemory(accessRegister(accessMemory(line+1))))
            currentLine += 2;
            break
        case instruction.subir:
            //subir
            // registers[memory[line + 2]] -= accessMemory(line + 1)
            writeRegister(accessMemory(line + 2), accessRegister(accessMemory(line + 2)) - accessMemory(line + 1))
            currentLine += 2
            break
        case instruction.subrr:
            //subrr
            // registers[memory[line + 2]] -= registers[accessMemory(line + 1)]
            writeRegister(accessMemory(line + 2), accessRegister(accessMemory(line + 2)) - accessRegister(accessMemory(line + 1)))
            currentLine += 2
            break
        case instruction.submr:
            //submr
            // registers[memory[line + 2]] -= memory[accessMemory(line + 1)]
            writeRegister(accessMemory(line + 2), accessMemory(line + 2) - accessMemory(accessMemory(line + 1)))
            currentLine += 2
            break
        case instruction.subxr:
            //subxr
            writeRegister(accessMemory(line+2), accessRegister(accessMemory(line+2)) - accessMemory(accessRegister(accessMemory(line+1))))
            currentLine += 2
            break
        case instruction.mulir:
            //mulir
            // registers[memory[line + 2]] *= accessMemory(line + 1)
            writeRegister(accessMemory(line+2), accessRegister(accessMemory(line + 2)) * accessMemory(line + 1))
            currentLine += 2
            break
        case instruction.mulrr:
            //mulrr
            // registers[memory[line + 2]] *= registers[accessMemory(line + 1)]
            writeRegister(accessMemory(line + 2), accessRegister(accessMemory(line + 2)) * accessRegister(accessMemory(line + 1)))
            currentLine += 2
            break
        case instruction.mulmr:
            //mulmr
            // registers[memory[line + 2]] *= memory[accessMemory(line + 1)]
            writeRegister(accessMemory(line + 2), accessMemory(line + 2) * accessMemory(accessMemory(line + 1)))
            currentLine += 2
            break
        case instruction.mulxr:
            //mulxr
            writeRegister(accessMemory(line+2), accessRegister(accessMemory(line+2)) * accessMemory(accessRegister(accessMemory(line+1))))
            currentLine += 2
            break
        case instruction.divir:
            //divir
            // registers[memory[line + 2]] /= accessMemory(line + 1)
            writeRegister(accessMemory(line+2), divide(accessRegister(accessMemory(line + 2)), accessMemory(line + 1)));
            currentLine += 2
            break
        case instruction.divrr:
            //divrr
            // registers[memory[line + 2]] /= registers[accessMemory(line + 1)]
            writeRegister(accessMemory(line+2), divide(accessRegister(accessMemory(line + 2)), accessRegister(accessMemory(line + 1))))
            currentLine += 2
            break
        case instruction.divmr:
            //divmr
            // registers[memory[line + 2]] /= memory[accessMemory(line + 1)]
            writeRegister(accessMemory(line+2), divide(accessMemory(line + 2), accessMemory(accessMemory(line + 1))))
            currentLine += 2
            break
        case instruction.divxr:
            //divxr
            writeRegister(accessMemory(line+2), divide(accessRegister(accessMemory(line+2)), accessMemory(accessRegister(accessMemory(line+1)))))
            currentLine += 2
            break
        case instruction.jmp:
            //jmp
            currentLine = accessMemory(line + 1) - 1
            break
        case instruction.sojz:
            //sojz
            writeRegister(accessMemory(line + 1), accessRegister(accessMemory(line + 1)) - 1)
            if (accessRegister(accessMemory(line + 1)) == 0) {
                currentLine = accessMemory(line + 2) - 1;
                break
            }
            currentLine += 2;
            break
        case instruction.sojnz:
            //sojnz
            writeRegister(accessMemory(line + 1), accessRegister(accessMemory(line + 1)) - 1)
            if (accessRegister(accessMemory(line + 1)) != 0) {
                currentLine = accessMemory(line + 2) - 1
                break;
            }
            currentLine += 2;
            break
        case instruction.aojz:
            //aojz
            writeRegister(accessMemory(line + 1), accessRegister(accessMemory(line + 1)) + 1)
            if (accessRegister(accessMemory(line + 1)) == 0) {
                currentLine = accessMemory(line + 2) - 1
                break;
            }
            currentLine += 2;
            break
        case instruction.aojnz:
            //aojnz
            writeRegister(accessMemory(line + 1), accessRegister(accessMemory(line + 1)) + 1);
            if (accessRegister(accessMemory(line + 1)) != 0) {
                currentLine = accessMemory(line + 2) - 1;
                break;
            }
            currentLine += 2;
            break
        case instruction.cmpir:
            //cmpir
            compare = accessMemory(line + 1) - accessRegister(accessMemory(line + 2));
            currentLine += 2
            break
        case instruction.cmprr:
            //cmprr
            compare = accessRegister(accessMemory(line + 1)) - accessRegister(accessMemory(line + 2));
            currentLine += 2
            break
        case instruction.cmpmr:
            //cmpmr
            compare = accessMemory(accessMemory(line + 1)) - accessRegister(accessMemory(line + 2))
            currentLine += 2
            break
        case instruction.jmpn:
            //jmpn
            if compare < 0 {
                currentLine = accessMemory(line + 1) - 1;
                // print("currentLine - \(currentLine)")
                break
            }
            currentLine += 1;
            break
        case instruction.jmpz:
            //jmpz
            if compare == 0 {
                currentLine = accessMemory(line + 1) - 1;
                // print("currentLine - \(currentLine)")
                break
            }
            currentLine += 1;
            break
        case instruction.jmpp:
            //jmpp
            if compare > 0 {
                currentLine = accessMemory(line + 1) - 1;
                // print("currentLine - \(currentLine)")
                break
            }
            currentLine += 1;
            break
        case instruction.jsr:
            //jsr
            for index in 5...9 {
                if (stack.isFull()) {
                    error = 4;
                    break;
                }
                stack.push(registers[index])
            }
            if (stack.isFull()) {
                error = 4;
                break;
            }
            stack.push(currentLine);
            currentLine = accessMemory(line + 1) - 1
            break
        case instruction.ret:
            //ret
            var popResult = stack.pop();
            if (popResult == nil) {
                error = 5;
                break;
            }
            currentLine = popResult! + 1    // + 1 to account for the fact that the next thing is jsr's argument
            var index = 5
            while index != 10 {
                popResult = stack.pop();
                if (popResult == nil) {
                    error = 5;
                    break;
                }
                registers[index] = popResult!
                index += 1
            }
            break
        case instruction.push:
            //push
            if (stack.isFull()) {
                error = 4;
                break;
            }
            stack.push(accessRegister(accessMemory(line + 1)));
            currentLine += 1
            break
        case instruction.pop:
            //pop
            let popResult = stack.pop();
            if (popResult == nil) {
                error = 5;
                break;
            }
            writeRegister(accessMemory(line + 1), popResult!);
            currentLine += 1
            break
        case instruction.stackc:
            //stackc
            let count = stack.array.count
            if count == 0 {writeRegister(accessMemory(line + 1), 2)}
            if count != 0 && count < stack.size {writeRegister(accessMemory(line + 1), 0)}
            if count >= stack.size {writeRegister(accessMemory(line + 1), 1)}
            currentLine += 1
            break
        case instruction.outci:
            //outci
            print(accessMemory(line + 1))
            currentLine += 1
            break
        case instruction.outcr:
            //outcr
            print(unicodeValueToCharacter(accessRegister(accessMemory(line + 1))), terminator: "") //prints it as a character, not a number
            currentLine += 1
            break
        case instruction.outcx:
            //outcx
            print(unicodeValueToCharacter(accessMemory(accessRegister(accessMemory(line + 1)))), terminator: "")
            currentLine += 1
            break
        case instruction.outcb:
            //outcb
            printBlock(accessRegister(accessMemory(line + 1)), accessRegister(accessMemory(line + 2)))
            currentLine += 2
            break
        case instruction.readi:
            //readi
            var readi_input = Int(readLine()!)
            if (readi_input == nil) {
                writeRegister(accessMemory(line + 2), 1)
                break
            }
            writeRegister(accessMemory(line + 1), readi_input!)
            writeRegister(accessMemory(line + 2), 0)
            currentLine += 2
            break
        case instruction.printi:
            //printi
            print(String(accessRegister(accessMemory(line + 1))), terminator: "")
            currentLine += 1
            break;
        case instruction.readc:
            //readc
            writeMemory(1, accessMemory(line + 1))
            currentLine += 1
            break
        case instruction.readln:
            //readln
            readString(accessMemory(line + 1), accessMemory(line + 2))
            currentLine += 2
            break
        case instruction.brk:
            //brk
            break
        case instruction.movrx:
            //movrx
            writeMemory(accessRegister(accessMemory(line + 2)), accessRegister(accessMemory(line + 1)))
            currentLine += 2
            break
        case instruction.movxx:
            //movxx
            writeMemory(accessRegister(accessMemory(line + 2)), accessMemory(accessRegister(accessMemory(line + 1))))
            currentLine += 2;
            break
        case instruction.outs:
            // outs
            print(getStringFromLocation(accessMemory(line + 1)), terminator: "")
            currentLine += 1
            break
        case instruction.nop:
            //nop
            //literally does nothing :/
            break
        case instruction.jmpne:
            //jmpne
            //if compare was not equal:
            if compare != 0 {
                currentLine = accessMemory(line + 1) - 1;
                // print("currentLine - \(currentLine)")
                break;
            }
            currentLine += 2;
            break;
        default:
            print("ERROR Unknown instruction \"\(memory[line])\" at line \(line)")
            return true
        }
        if (error != 0) {
            print("ERROR #\(error) \(errorMessages[error])\(errorDetails) at line \(line) (instruction \(accessMemory(line)))");
            error = 0;
            return true;
        }
        return false;
    }
    
    //this executes whatever is currently in memory
    func execute() {
        while true {
            //execute the current line and note if it is a halt
            let halt = executeLine(currentLine);
            //halt if the current instruction is halt
            if (halt) {
                break
            }
            //and of course increment the current line
            currentLine += 1;
        }
    }
}
