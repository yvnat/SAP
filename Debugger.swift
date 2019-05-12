import Foundation

class Debugger {
    var assembler = Assembler();
    var executioner = Executioner();
    var path = "";
    var breakpoints = Set<Int>();
    var areBreakpointsDisabled = false;
    var symbolTable: [String: Int] = [:]
    
    func isCurrentlyAtBreakpoint(_ point: Int)->Bool {
        if areBreakpointsDisabled {
            return false;
        }
        return breakpoints.contains(point);
    }
    func setPath(_ newpath: String) {
        path = newpath;
    }
    func addBreakpoint(_ point: Int) {
        if point < 0 || point >= executioner.memory.count {
            print("Error: memory location \(point) out of bounds");
            return;
        }
        breakpoints.insert(point);
    }
    func removeBreakpoint(_ point: Int) {
        if !breakpoints.contains(point) {
            print("Error: no breakpoint at \(point)");
            return;
        }
        breakpoints.remove(point);
    }
    func clearBreakpoints() {
        breakpoints = Set<Int>();
    }
    func disableAllBreakpoints() {
        areBreakpointsDisabled = true;
    }
    func enableAllBreakpoints() {
        areBreakpointsDisabled = false;
    }
    func printBreakpoints() {
        print("Breakpoint locations:")
        for i in breakpoints {
            print(i);
        }
    }
    func printRegisters() {
        print("Registers:")
        for i in 0..<executioner.registers.count {
            print("r\(i): \(executioner.registers[i])");
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
            print("Error: memory location \(value) out of bounds");
        }
        executioner.currentLine = value;
    }
    func printMemory(_ value1: Int, _ value2: Int) {
        if value1 >= value2 {
            print("Error: \(value1) must be smaller than \(value2)")
        }
        if value1 < 0 || value2 >= executioner.memory.count {
            print("Error: memory location out of bounds");
        }
        for i in value1...value2 {
            print(executioner.memory[i])
        }
    }
    func changeMemory(_ location: Int, _ value: Int) {
        if location < 0 || location >= executioner.memory.count {
            print("Error: memory location \(location) out of bounds");
        }
        executioner.memory[location] = value;
    }
    func printSymbolTable() {
        for i in symbolTable {
            print("\(i.key) : \(i.value)");
        }
    }
    func help() {
        print("""
                                    Commands:
                                   -----------
        setbk<address>                      set breakpoint at <address>
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
            print("Sdb (\(executioner.currentLine),\(executioner.accessMemory(executioner.currentLine)))>", terminator: " ")
            var input = readLine();
            if input == nil {
                continue;
            }
            if (input! == "exit") {
                return
            }
            var splitInput = splitStringIntoParts(expression: input!);
            if splitInput.count < 1 {
                print("what. this should not happen.")
                continue;
            }
            switch splitInput[0] {
            case "setbk":
                if splitInput.count != 2 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue;}
                if Int(splitInput[1]) == nil {print("\(splitInput[1]) must be a valid int");continue;}
                addBreakpoint(Int(splitInput[1])!)
            case "rembk":
                if splitInput.count != 2 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue;}
                if Int(splitInput[1]) == nil {print("\(splitInput[1]) must be a valid int");continue;}
                removeBreakpoint(Int(splitInput[1])!)
            case "pbk":
                if splitInput.count != 1 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue;}
                printBreakpoints();
            default:
                print("Unknown command \"\(splitInput[0])\". Type \"help\" for a list of commands")
            }
        }
    }
}
