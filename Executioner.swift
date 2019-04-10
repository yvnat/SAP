//this file stores the class that executes the code
//no relation to capital punishment
//crash conditions: out of memory, illegal instruction, (SOMETHING ELSE)
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

    init() {
        for _ in 0..<20000 {
            memory.append(0)
        }
    }

    //shortcut for accessing strings
    var symbolsToStrings: [Int : String] = [:]

    //a wrapper for memory[] that gives an error
    func accessMemory(_ index: Int)->Int {
        if (index > 0 && index < memory.count) {
            return memory[index]
        }
        print("[ERROR] memory address out of bounds (address: \(index), memory size: \(memory.count))");
        return 0; //TODO: make this crash
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
            print(memory.count)
            memory[i] = stringToInstruction!;
        }
        print("Successfully loaded program")
    }

    func getStringFromLocation(_ pointer: Int) -> String {
        if symbolsToStrings[pointer] != nil {
            return symbolsToStrings[pointer]!
        }
        var currentIndex = pointer + 1
        let stopIndex = accessMemory(pointer) + pointer
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
        if (memory[line] == 0) {
            return true
        }
        //execute the line
        //note: memory[line + 1] = nextLine, memory[line + 2] = nextNextLine
        //I didn't make variables with those names so it doesn't cause crashes when
        //trying to access things outside memory if no arguments are needed for the instruction
        switch memory[line] {
        case 6:
            //movrr
            registers[memory[line + 2]] = registers[memory[line + 1]]
            currentLine += 2
            return false
        case 8:
            //movmr
            // print("registers[\(memory[line + 2])] = memory[\(memory[line + 1])]")
            registers[memory[line + 2]] = memory[memory[line + 1]]
            currentLine += 2
            return false;
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
        case 34:
            //cmprr
            compare = registers[memory[line + 1]] - registers[memory[line + 2]];
            currentLine += 2
            return false;
        case 45:
            //outcr
            print(memory[line + 1])
            print(unicodeValueToCharacter(registers[memory[line + 1]]), terminator: "") //prints it as a character, not a number
            currentLine += 1
            return false;
        case 49:
            //printi
            print(String(registers[memory[line + 1]]), terminator: "")
            currentLine += 1
            return false;
        case 55:
            // outs
            print(getStringFromLocation(memory[line + 1]), terminator: "")
            currentLine += 1
            return false
        case 57:
            //jmpne
            //if compare was not equal:
            if compare != 0 {
                currentLine = memory[line + 1] - 1;
            }
            return false;
        default:
            print("[ERROR] Unknown instruction \"\(memory[line])\" at line \(line)")
            return true
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
