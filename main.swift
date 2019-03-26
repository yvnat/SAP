//Hi Yonathan, I realized that we forgot to exchange cell numbers today and so mine is 617-584-2180.  Just text me letting me know that you got this so that we can communicate.  (I'll delete this later)

import Foundation

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
    var symbolsToValues: [Int : Int] = []
    //Detect all variables first:
    
    //Then run the program from 2nd line number (starting code line):
    for line in code {
        switch Int(line) {
        case 0:
            //halt
        case 6:
            //movrr
        case 8:
            //movmr
        case 12:
            //addir
        case 13:
            //addrr
        case 34:
            //cmprr
        case 45:
            //outcr
        case 49:
            //printi
        case 55:
            //outs
        case 57:
            //jmpne
        default:
            print("Unknown Command")
        }
        /*We may use this later:
         let words = line.components(separatedBy: " ")
         print("\(words[0]) is \(words[1]) and likes \(words[4])")
         */
    }
}

//TEST CODE:
let path = Bundle.main.path(forResource: "test", ofType: "txt")
readFromFile(path: path)
