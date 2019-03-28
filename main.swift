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
    var symbolsToValues: [Int : Character] = [:]
    var startOfProgram = 0
    var intLine = 0
    var indexLine = 0
    var compare = false
    while indexLine != code.count {
        let currentLine = Int(code[indexLine])!
        //Detect all variables first:
        if indexLine == 0 {symbolsToValues[0] = currentLine} else {
            if indexLine == 1 {startOfProgram = currentLine} else {
                //Btw Yonathan, this is the only part that isn't quite right, I think everything else should be fine so please work on this.  It just adds every value from the start until it reaches the start of program line, thus each letter in a string will just save as a new variable integer in the symbolsToValues dictionary.  We need to figure out how to detect when the integer variables are done and we're moving on to the string variables.  Text me if you have any questions.
                if indexLine < startOfProgram + 2 {symbolsToValues[indexLine] = currentLine} else {
                    
                    //Then run the program from 2nd line number (starting code line):
                    let nextLine = Int(code[indexLine + 1])!
                    let nextNextLine = Int(code[indexLine + 2])!
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
                        if registers[nextLine] < registers[nextNextLine] {compare = false}
                        else {compare = true}
                    case 45:
                        //outcr
                        print(nextLine)
                    case 49:
                        //printi
                        print(registers[nextLine])
                    case 55:
                        //outs
                        print(symbolsToValues[nextLine]!)
                    case 57:
                        //jmpne
                        //if compare was not equal:
                        if compare == false {
                            //find label of Do01 and set indexLine equal to that
                            indexLine = nextLine + 1
                        }
                    default:
                        print("Unknown Command")
                    }
                /*We may use this later:
                 let words = line.components(separatedBy: " ")
                 print("\(words[0]) is \(words[1]) and likes \(words[4])")
                 */
                }
            }
        }
        indexLine += 1
    }
}

//TEST CODE:
let path = Bundle.main.path(forResource: "test", ofType: "txt")
readFromFile(path: path)
