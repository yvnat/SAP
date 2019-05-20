import Foundation

class Debugger {
    var executioner: Executioner;
    var breakpoints: Set<Int>;
    var areBreakpointsDisabled: Bool;
    var symbolTable: [String: Int];
    var executing: Bool;
    var done: Bool;
    
    init() {
        breakpoints = Set<Int>()
        areBreakpointsDisabled = false
        symbolTable = [:]
        executing = false;
        done = false;
        executioner = Executioner()
    }
    
    func isCurrentlyAtBreakpoint(_ point: Int)->Bool {
        if areBreakpointsDisabled {
            return false;
        }
        return breakpoints.contains(point);
    }
    func addBreakpoint(_ point: Int) {
        if point < 0 || point >= executioner.memory.count {
            print("Error: memory location \(point) out of bounds")
            return
        }
        breakpoints.insert(point)
    }
    func removeBreakpoint(_ point: Int) {
        if !breakpoints.contains(point) {
            print("Error: no breakpoint at \(point)");
            return
        }
        breakpoints.remove(point)
    }
    func clearBreakpoints() {
        breakpoints = Set<Int>()
    }
    func disableAllBreakpoints() {
        areBreakpointsDisabled = true
    }
    func enableAllBreakpoints() {
        areBreakpointsDisabled = false
    }
    func printBreakpoints() {
        print("Breakpoint locations:")
        for i in breakpoints {
            print(i)
        }
    }
    func printRegisters() {
        print("Registers:")
        for i in 0..<executioner.registers.count {
            print("r\(i): \(executioner.registers[i])")
        }
    }
    func writeToRegister(_ register: Int, _ value: Int) {
        if register < 0 || register > 9 {
            print("Error: r\(register) is not a valid register")
            return
        }
        executioner.registers[register] = value
    }
    func changeProgramCounter(_ value: Int) {
        if value < 0 || value >= executioner.memory.count {
            print("Error: memory location \(value) out of bounds")
        }
        executioner.currentLine = value
    }
    func printMemory(_ value1: Int, _ value2: Int) {
        if value1 >= value2 {
            print("Error: \(value1) must be smaller than \(value2)")
        }
        if value1 < 0 || value2 >= executioner.memory.count {
            print("Error: memory location out of bounds")
        }
        for i in value1...value2 {
            print(executioner.memory[i])
        }
    }
    func deassemble(_ value1: Int, _ value2: Int) {
        if (value1 >= value2) {
            print("First location must be smaller than second value")
            return;
        }
        if (value1 < 0 || value2 >= executioner.memory.count) {
            print("Memory locations out of bound")
            return;
        }
        var memorySubset: [Int] = [];
        for i in value1..<value2 {
            memorySubset.append(executioner.memory[i])
        }
        var d = Disassembler(symbolTable: symbolTable, memory: memorySubset)
        d.convertBinaryToAssembly();
    }
    func changeMemory(_ location: Int, _ value: Int) {
        if location < 0 || location >= executioner.memory.count {
            print("Error: memory location \(location) out of bounds")
        }
        executioner.memory[location] = value
    }
    func printSymbolTable() {
        for i in symbolTable {
            print("\(i.key) : \(i.value)")
        }
    }
    func help() {
        print("""
                                    Commands:
                                   -----------
        setbk <address>                     set breakpoint at <address>
        rmbk <address>                      remove breakpoint at <address>
        clrbk                               clear all breakpoints
        disbk                               temporarily disable all breakpoints
        enbk                                enable breakpoints
        pbk                                 print breakpoint table
        preg                                print registers
        wreg <number> <value>               write value of register <number> to <value?
        wpc <value>                         change value of PC to <value>
        pmem <start address> <end address>  print memory locations
        deas <start address> <end address>  deassemble memory locations
        wmem <address> <value>              change value of memory at <address> to <value>
        pst                                 print symbol table
        g                                   continue program execution
        s                                   single step
        exit                                terminate virtual machine
        help                                print this help table
        """)

    }
    func run() {
        while true {
            while executing {
                let executionState = executioner.executeLine(executioner.currentLine);
                if isCurrentlyAtBreakpoint(executioner.currentLine) {
                    executing = false;
                }
                if executionState == 1 {
                    executing = false;
                } else if executionState == -1 {
                    executing = false;
                    done = true;
                    print("\nProgram finished.")
                }
            }
            print("Sdb (\(executioner.currentLine),\(executioner.accessMemory(executioner.currentLine)))>", terminator: " ")
            let input = readLine();
            if input == nil {
                continue;
            }
            if (input! == "exit") {
                return
            }
            var splitInput = splitStringIntoParts(expression: input!)
            if splitInput.count < 1 {
                continue;
            }
            switch splitInput[0] {
            case "setbk":
                if splitInput.count != 2 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                if Int(splitInput[1]) == nil {print("\(splitInput[1]) must be a valid int");continue}
                addBreakpoint(Int(splitInput[1])!)
            case "rembk":
                if splitInput.count != 2 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                if Int(splitInput[1]) == nil {print("\(splitInput[1]) must be a valid int");continue}
                removeBreakpoint(Int(splitInput[1])!)
            case "clrbk":
                if splitInput.count != 1 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                clearBreakpoints()
            case "disbk":
                if splitInput.count != 1 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                disableAllBreakpoints()
            case "enbk":
                if splitInput.count != 1 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                enableAllBreakpoints()
            case "pbk":
                if splitInput.count != 1 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                printBreakpoints()
            case "preg":
                if splitInput.count != 1 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                printRegisters()
            case "wreg":
                if splitInput.count != 3 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                if Int(splitInput[1]) == nil {print("\(splitInput[1]) must be a valid int");continue}
                if Int(splitInput[2]) == nil {print("\(splitInput[2]) must be a valid int");continue}
                writeToRegister(Int(splitInput[1])!, Int(splitInput[2])!)
            case "wpc":
                if splitInput.count != 2 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                if Int(splitInput[1]) == nil {print("\(splitInput[1]) must be a valid int");continue}
                changeProgramCounter(Int(splitInput[1])!)
            case "pmem":
                if splitInput.count != 3 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                if Int(splitInput[1]) == nil {print("\(splitInput[1]) must be a valid int");continue}
                if Int(splitInput[2]) == nil {print("\(splitInput[2]) must be a valid int");continue}
                printMemory(Int(splitInput[1])!, Int(splitInput[2])!)
            case "deas":
                if splitInput.count != 3 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                if Int(splitInput[1]) == nil {print("\(splitInput[1]) must be a valid int");continue}
                if Int(splitInput[2]) == nil {print("\(splitInput[2]) must be a valid int");continue}
                deassemble(Int(splitInput[1])!, Int(splitInput[2])!)
            case "wmem":
                if splitInput.count != 3 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                if Int(splitInput[1]) == nil {print("\(splitInput[1]) must be a valid int");continue}
                if Int(splitInput[2]) == nil {print("\(splitInput[2]) must be a valid int");continue}
                changeMemory(Int(splitInput[1])!, Int(splitInput[2])!)
            case "pst":
                if splitInput.count != 1 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                printSymbolTable()
            case "g":
                if done {print("Cannot continue because the program has finished execution");continue}
                if splitInput.count != 1 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                executing = true;
                break;
            case "s":
                if done {print("Cannot step because the program has finished execution");continue}
                if splitInput.count != 1 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                executioner.executeLine(executioner.currentLine)
                break;
            case "help":
                help()
            default:
                print("Unknown command \"\(splitInput[0])\". Type \"help\" for a list of commands")
            }
        }
    }
    func debug(path: String) {
        var bad = false;
        //load program
        do {
            let contents = try String(contentsOfFile: "\(path).bin", encoding: String.Encoding.utf8);
            let lines = contents.components(separatedBy: "\n")
            executioner.loadProgram(lines)
        }
        catch {
            print("Debugger could not be initialized because binary file at \(path) could not be loaded")
            bad = true;
        }
        //load symbols table
        do {
            let contents = try String(contentsOfFile: "\(path).sym", encoding: String.Encoding.utf8);
            let lines = contents.components(separatedBy: "\n")
            var symbols: [[String]] = [];
            for i in lines {
                symbols.append(i.components(separatedBy: ":"));
            }
            for i in symbols {
                //ensure that all sections of the file are either valid or empty
                if (i.count == 1 && i[0] == "") {
                    continue;
                }
                if i.count != 2 {
                    print("Debugger could not be initialized because the following section of the symbols file does not conform to the format of \"symbol:location\" \(i)")
                    return;
                }
                if Int(i[1]) == nil {
                    print("Debugger could not be initialized because \(i[1]) is not an int (\(i))")
                    return;
                }
                symbolTable[i[0]] = Int(i[1])!;
            }
        }
        catch {
            print("Debugger could not be initialized because symbols file at \(path) could not be loaded")
            bad = true;
        }
        if bad {
            return;
        }
        run();
    }
}
