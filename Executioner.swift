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

    init() {
        for _ in 0..<20000 {
            memory.append(0)
        }
    }

    //shortcut for accessing strings
    var symbolsToStrings: [Int : String] = [:]

    //wrapper functions that return an appropriate error
    func accessMemory(_ index: Int)->Int {
        if (index >= 0 && index < memory.count) {
            return memory[index]
        }
        error = 1;
        return 0; //TODO: make this crash
    }
    func writeMemory(_ index: Int, _ what: Int) {
        if (index >= 0 && index < memory.count) {
            memory[index] = what;
        }
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

    //this executes one specific line
    //returns true on halt, false otherwise
    func executeLine(_ line: Int)->Bool {
        // print("executing line \(line), which contains the instruction \(accessMemory(line))")
        //return false if halt
        if (accessMemory(line) == 0) {
            return true
        }
        //execute the line
        //note: memory[line + 1] = nextLine, memory[line + 2] = nextNextLine
        //I didn't make variables with those names so it doesn't cause crashes when
        //trying to access things outside memory if no arguments are needed for the instruction
        switch accessMemory(line) {
        case 1:
            //clrr
            writeRegister(accessMemory(line + 1), 0)
            currentLine += 1
            break
        case 2:
            //clrx
            writeRegister(accessRegister(accessMemory(line + 1)),0)
            break
        case 3:
            //clrm
            writeMemory(accessMemory(line + 1), 0)
            break
        case 4:
            //clrb
            //for i in initialPosition..<(initialPosition + count)
            for i in accessMemory(line + 1)..<(accessMemory(line + 1) + accessMemory(line + 2)) {
                writeMemory(i, 0)
            }
            break
        case 5:
            //movir
            // registers[memory[line + 2]] = registers[accessMemory(line + 1)]  //this seems wrong
            writeRegister(accessMemory(line+2), accessMemory(line+1))
            currentLine += 2
            break
        case 6:
            //movrr
            // registers[memory[line + 2]] = registers[accessMemory(line + 1)]
            writeRegister(accessMemory(line+2), accessRegister(accessMemory(line+1)))
            currentLine += 2
            break
        case 7:
            //movrm
            // memory[memory[line + 2]] = registers[accessMemory(line + 1)]
            writeMemory(accessMemory(line+2), accessRegister(accessMemory(line+1)))
            currentLine += 2
            break
        case 8:
            //movmr
            // print("registers[\(memory[line + 2])] = memory[\(accessMemory(line + 1))]")
            // registers[memory[line + 2]] = memory[accessMemory(line + 1)]
            writeRegister(accessMemory(line+2), accessMemory(accessMemory(line + 1)))
            currentLine += 2
            break;
        case 9:
            //movxr
            writeRegister(accessMemory(line+2), accessMemory(accessRegister(accessMemory(line + 1))))
            currentLine += 2
            break
        case 10:
            //movar
            writeRegister(accessMemory(line+2), accessMemory(line + 1))
            currentLine += 2
            break
        case 11:
            //movb
            moveBlock(accessRegister(accessMemory(line + 1)), accessRegister(accessMemory(line + 2)), accessRegister(accessMemory(line + 2)))
            currentLine += 3
            break
        case 12:
            //addir
            writeRegister(accessMemory(line + 2), accessRegister(accessMemory(line + 2)) + accessMemory(line + 1))
            currentLine += 2
            break;
        case 13:
            //addrr
            writeRegister(accessMemory(line + 2), accessRegister(accessMemory(line + 2)) + accessRegister(accessMemory(line + 1)))
            currentLine += 2
            break;
        case 14:
            //addmr
            // registers[memory[line + 2]] += memory[accessMemory(line + 1)]
            writeRegister(accessMemory(line + 2), accessMemory(accessMemory(line + 1)))
            currentLine += 2
            break
        case 15:
            //addxr
            
            break
        case 16:
            //subir
            registers[memory[line + 2]] -= accessMemory(line + 1)
            currentLine += 2
            break
        case 17:
            //subrr
            registers[memory[line + 2]] -= registers[accessMemory(line + 1)]
            currentLine += 2
            break
        case 18:
            //submr
            registers[memory[line + 2]] -= memory[accessMemory(line + 1)]
            currentLine += 2
            break
        case 19:
            //subxr
            break
        case 20:
            //mulir
            registers[memory[line + 2]] *= accessMemory(line + 1)
            currentLine += 2
            break
        case 21:
            //mulrr
            registers[memory[line + 2]] *= registers[accessMemory(line + 1)]
            currentLine += 2
            break
        case 22:
            //mulmr
            registers[memory[line + 2]] *= memory[accessMemory(line + 1)]
            currentLine += 2
            break
        case 23:
            //mulxr
            break
        case 24:
            //divir
            registers[memory[line + 2]] /= accessMemory(line + 1)
            currentLine += 2
            break
        case 25:
            //divrr
            registers[memory[line + 2]] /= registers[accessMemory(line + 1)]
            currentLine += 2
            break
        case 26:
            //divmr
            registers[memory[line + 2]] /= memory[accessMemory(line + 1)]
            currentLine += 2
            break
        case 27:
            //divxr
            break
        case 28:
            //jmp
            currentLine = accessMemory(line + 1) - 1
            break
        case 29:
            //sojz
            break
        case 30:
            //sojnz
            break
        case 31:
            //aojz
            break
        case 32:
            //aojnz
            break
        case 33:
            //cmpir
            break
        case 34:
            //cmprr
            compare = registers[accessMemory(line + 1)] - registers[memory[line + 2]];
            currentLine += 2
            break
        case 35:
            //cmpmr
            break
        case 36:
            //jmpn
            break
        case 37:
            //jmpz
            break
        case 38:
            //jmpp
            break
        case 39:
            //jsr
            break
        case 40:
            //ret
            break
        case 41:
            //push
            break
        case 42:
            //pop
            break
        case 43:
            //stackc
            break
        case 44:
            //outci
            print(accessMemory(line + 1))
            currentLine += 1
            break
        case 45:
            //outcr
            print(unicodeValueToCharacter(registers[accessMemory(line + 1)]), terminator: "") //prints it as a character, not a number
            currentLine += 1
            break;
        case 46:
            //outcx
            break
        case 47:
            //outcb
            break
        case 48:
            //readi
            break
        case 49:
            //printi
            print(String(registers[accessMemory(line + 1)]), terminator: "")
            currentLine += 1
            break;
        case 50:
            //readc
            break
        case 51:
            //readln
            break
        case 52:
            //brk
            break
        case 53:
            //movrx
            break
        case 54:
            //movxx
            break
        case 55:
            // outs
            print(getStringFromLocation(accessMemory(line + 1)), terminator: "")
            currentLine += 1
            break
        case 56:
            //nop
            //literally does nothing :/
            break
        case 57:
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
            print("ERROR #\(error) \(errorMessages[error]) at line \(line) (instruction \(accessMemory(line)))");
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
                break;
            }
            //and of course increment the current line
            currentLine += 1;
        }
    }
}
