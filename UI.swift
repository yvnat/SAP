import Foundation

class UI {
    var assembler: Assembler;
    var debugger: Debugger;
    var path: String;
    init() {
        assembler = Assembler();
        debugger = Debugger();
        path = "";
    }
    func setPath(newpath: String) {
        path = newpath
        print("Path set to \(path)")
    }
    func assemble(program: String) {
        if path == "" {
            print("Error: path is unset")
            return;
        }
        let _ = assembler.assemble(path: "\(path)\(program)")
    }
    func execute(program: String) {
        if path == "" {
            print("Error: path is unset")
            return;
        }
        debugger = Debugger();
        debugger.debug(path: "\(path)\(program)")
    }
    func printLst(program: String) {
        do {
            let contents = try String(contentsOfFile: "\(path).lst", encoding: String.Encoding.utf8);
            print(contents);
        }
        catch {
            print("Could not load file")
        }
        return;
    }
    func printSym(program: String) {
        do {
            let contents = try String(contentsOfFile: "\(path)\(program).sym", encoding: String.Encoding.utf8);
            print(contents);
        }
        catch {
            print("Could not load file")
        }
        return;
    }
    func printBin(program: String) {
        do {
            let contents = try String(contentsOfFile: "\(path)\(program).bin", encoding: String.Encoding.utf8);
            print(contents);
        }
        catch {
            print("Could not load file")
        }
        return;
    }
    func printHelp() {
        print("""
                                  SAP Help
                                  --------
        path <path>                 set the path for the SAP program directory
                                     * include the final \"/\" but, but
                                       DO NOT include name of file.
                                       SAP file must have an extension of .txt
        asm <program name>          assemble the specified program
        run <program name>          run the specified program
        printlst <program name>     print listing file for the specified program
        printbin <program name>     print binary file for the specified program
        printsym <program name>     print symbol table for the specified program
        quit                        terminate SAP program
        help                        print this
        """)
    }
    func run() {
        print("Welcome to SAP!")
        printHelp();
        while true {
            print(">", terminator: "")
            let input = readLine();
            if input == nil {
                continue;
            }
            if (input! == "quit") {
                return
            }
            var splitInput = splitStringIntoParts(expression: input!)
            if splitInput.count < 1 {
                continue;
            }
            switch splitInput[0] {
            case "path":
                if splitInput.count != 2 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                setPath(newpath: splitInput[1]);
                break;
            case "asm":
                if splitInput.count != 2 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                assemble(program: splitInput[1])
            case "run":
                if splitInput.count != 2 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                execute(program: splitInput[1])
            case "printlst":
                if splitInput.count != 2 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                printLst(program: splitInput[1])
            case "printsym":
                if splitInput.count != 2 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                printSym(program: splitInput[1])
            case "printbin":
                if splitInput.count != 2 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                printBin(program: splitInput[1])
            case "help":
                if splitInput.count != 1 {print("Incorrect number of arguments for command. Type \"help\" for a list of commands.");continue}
                printHelp()
            default:
                print("Unknown command \"\(splitInput[0])\". Type \"help\" for a list of commands")
            }
        }
    }
}
