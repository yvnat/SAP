//Hi Yonathan, I realized that we forgot to exchange cell numbers today and so mine is 617-584-2180.  Just text me letting me know that you got this so that we can communicate.  (I'll delete this later)

import Foundation
import Darwin

func characterToUnicodeValue(_ c: Character)->Int {
    let s = String(c)
    return Int(s.unicodeScalars[s.unicodeScalars.startIndex].value)
}

func unicodeValueToCharacter(_ n: Int)->Character{
    return Character(UnicodeScalar(n)!)
}

func readFromFile(path: String?){
    if let filePath = path {
        do {
            let contents = try String(contentsOfFile: filePath)
            let lines = contents.components(separatedBy: "\n")
            doTest(code: lines)
        }
        catch {
            print("Contents Failed To Load")
        }
    }
    else {
        print("The File \(path) Was Not Found")
    }
}

func doTest(code: [String]){
    var registers: [Int] = []
    var symbolsToValues: [Int : Int] = [:]
    var startOfProgram = 0
    var intLine = 0
    var indexLine = 0
    while indexLine != code.count {
        intLine = Int(line)!
        //Detect all variables first:
        if indexLine == 0 {symbolsToValues[0] = intLine} else {
        if indexLine == 1 {startOfProgram = intLine} else {
        
        //Then run the program from 2nd line number (starting code line):
        let nextLine = Int(code[indexLine += 1])
        let nextNextLine = Int(code[indexLine += 2])
        switch intLine {
        case 0:
            //halt
            exit(0)
        case 6:
            //movrr
            registers[nextNextLine] = registers[nextLine]
        case 8:
            //movmr
            registers[nextNextLine] = symbolsToValues[nextLine]
        case 12:
            //addir
            registers[nextNextLine] += nextLine
        case 13:
            //addrr
            registers[nextNextLine] += registers[nextLine]
        case 34:
            //cmprr
        case 45:
            //outcr
            print(nextLine)
        case 49:
            //printi
            print(registers[nextLine])
        case 55:
            //outs
            print(symbolsToValues[nextLine])
        case 57:
            //jmpne
            //if compare was not equal:
            //find label of Do01 and set indexLine equal to that
        default:
            print("Unknown Command")
        }
        /*We may use this later:
         let words = line.components(separatedBy: " ")
         print("\(words[0]) is \(words[1]) and likes \(words[4])")
         */
            }
        }
        indexLine += 1
    }
}

//TEST CODE:
let path = Bundle.main.path(forResource: "test", ofType: "txt")
readFromFile(path: path)
