//this file stores the class that executes the code
//no relation to capital punishment
class Executioner {
    //the registers
    var registers: [Int] = Array(repeating: 0, count: 10)
    var compare = 0  //positive if bigger, negative if smaller, 0 if equal
    //a pointer to the current memory block being executed
    var currentLine = 0
    //the length of the current program
    var programLength = 0
    //it would be more valid to have these be local to the execute function, but
    //having them be a member of the class is more accurate to real world (not necessarily in a good way)
    //memory holds program
    var memory: [Int] = []
    
    //shortcut for accessing strings
    var symbolsToStrings: [Int : String] = [:]
    
    //this takes a [string] program, clears memory, and puts program into memory as [int]
    func loadProgram(_ program: [String]) {
        memory.removeAll()
        for i in program {
            let stringToInstruction: Int? = Int(i)
            if (stringToInstruction == nil) {
                //print("FATAL ERROR LOADING PROGRAM: Invalid instruction (\"\(i)\")");
                return;
            }
            memory.append(stringToInstruction!);
        }
    }
    
    func getStringFromLocation(_ pointer: Int) -> String {
        if symbolsToStrings[pointer] != nil {
            return symbolsToStrings[pointer]!
        }
        var currentIndex = pointer + 3
        //plus 3 was to account for the two variables at the beginning and the beggining index of 0 in the memory array
        let stopIndex = memory[pointer + 2] + pointer + 3
        var string = ""
        while currentIndex != stopIndex {
            string += String(unicodeValueToCharacter(memory[currentIndex]))
            currentIndex += 1
        }
        symbolsToStrings[pointer] = string
        return symbolsToStrings[pointer]!
    }
    
    //this executes one specific line
    //returns true on halt, false otherwise
    func executeLine(_ line: Int)->Bool {
        //return false if halt
        if (memory[line] == 0) {
            return true
        }
        //execute the line
        //note: memory[line + 1] = nextLine, memory[line + 2] = nextNextLine
        //I didn't make variables with those names so it doesn't cause crashes when
        //trying to access things outside memory if no arguments are needed for the instruction
        switch memory[line] {
        case 1:
            //clrr
            registers[memory[line + 1]] = 0
            currentLine += 1
            return false
        case 2:
            //clrx
            break
        case 3:
            //clrm
            break
        case 4:
            //clrb
            break
        case 5:
            //movir
            registers[memory[line + 2]] = registers[memory[line + 1]]
            currentLine += 2
            return false
        case 6:
            //movrr
            registers[memory[line + 2]] = registers[memory[line + 1]]
            currentLine += 2
            return false
        case 7:
            //movrm
            memory[memory[line + 2]] = registers[memory[line + 1]]
            currentLine += 2
            return false
        case 8:
            //movmr
            registers[memory[line + 2]] = memory[memory[line + 1] + 2]
            currentLine += 2
            return false;
        case 9:
            //movxr
            break
        case 10:
            //movar
            break
        case 11:
            //movb
            break
        case 12:
            //addir
            registers[memory[line + 2]] += memory[line + 1]
            currentLine += 2
            return false;
        case 13:
            //addrr
            registers[memory[line + 2]] += registers[memory[line + 1]]
            currentLine += 2
            return false;
        case 14:
            //addmr
            registers[memory[line + 2]] += memory[memory[line + 1]]
            currentLine += 2
            return false
        case 15:
            //addxr
            break
        case 16:
            //subir
            registers[memory[line + 2]] -= memory[line + 1]
            currentLine += 2
            return false
        case 17:
            //subrr
            registers[memory[line + 2]] -= registers[memory[line + 1]]
            currentLine += 2
            return false
        case 18:
            //submr
            registers[memory[line + 2]] -= memory[memory[line + 1]]
            currentLine += 2
            return false
        case 19:
            //subxr
            break
        case 20:
            //mulir
            registers[memory[line + 2]] *= memory[line + 1]
            currentLine += 2
            return false
        case 21:
            //mulrr
            registers[memory[line + 2]] *= registers[memory[line + 1]]
            currentLine += 2
            return false
        case 22:
            //mulmr
            registers[memory[line + 2]] *= memory[memory[line + 1]]
            currentLine += 2
            return false
        case 23:
            //mulxr
            break
        case 24:
            //divir
            registers[memory[line + 2]] /= memory[line + 1]
            currentLine += 2
            return false
        case 25:
            //divrr
            registers[memory[line + 2]] /= registers[memory[line + 1]]
            currentLine += 2
            return false
        case 26:
            //divmr
            registers[memory[line + 2]] /= memory[memory[line + 1]]
            currentLine += 2
            return false
        case 27:
            //divxr
            break
        case 28:
            //jmp
            currentLine = memory[line + 1] - 1
            return false
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
            compare = registers[memory[line + 1]] - registers[memory[line + 2]];
            currentLine += 2
            return false;
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
            print(memory[line + 1])
            currentLine += 1
            return false
        case 45:
            //outcr
            print(unicodeValueToCharacter(registers[memory[line + 1]]), terminator: "") //prints it as a character, not a number
            currentLine += 1
            return false;
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
            print(String(registers[memory[line + 1]]), terminator: "")
            currentLine += 1
            return false;
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
            print(getStringFromLocation(memory[line + 1]), terminator: "")
            currentLine += 1
            return false
        case 56:
            //nop
            //literally does nothing :/
            return false
        case 57:
            //jmpne
            //if compare was not equal:
            if compare != 0 {
                //find label of Do01 and set indexLine equal to that
                currentLine = memory[line + 1] - 1;
            }
            return false;
        default:
            print("ERROR Unknown instruction \"\(memory[line])\" at line \(line)")
        }
        return false;
    }
    
    //this executes whatever is currently in memory
    func execute() {
        //if a program doesn't even have a length and a pointer to begin, you got a problem
        if (memory.count < 2) {
            print("FATAL ERROR EXECUTING PROGRAM: program has less than 2 instructions");
            return;
        }
        //read and act on program length and beginning point
        programLength = memory[0]
        currentLine = memory[1] + 2  //this is where the program begins
        //the program runs until it is told to stop
        while true {
            //break conditions: if trying to read beyond program length,
            if (currentLine >= programLength) {
                break;
            }
            //if trying to read outside memory,
            if (currentLine >= memory.count) {
                print("FATAL ERROR EXECUTING PROGRAM: out of memory");
                break;
            }
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
