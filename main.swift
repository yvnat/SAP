import Foundation
// import Glibc
// import Darwin
func characterToUnicodeValue(_ c: Character)->Int {
    let s = String(c)
    return Int(s.unicodeScalars[s.unicodeScalars.startIndex].value)
}

func unicodeValueToCharacter(_ n: Int)->Character{
    return Character(UnicodeScalar(n)!)
}

var symbolsToStrings: [Int : String] = [:]
var symbolsToInts: [Int : Int] = [:]
func detectVariableString(code: [String], index: Int)->String{
    var currentIndex = index
    let stopIndex = Int(code[index])!
    if symbolsToStrings[index] != nil {return symbolsToStrings[index]!}
    else {
        var variable = ""
        while currentIndex != (stopIndex + index) {
            let currentLine = Int(code[currentIndex])!
            variable += String(unicodeValueToCharacter(currentLine))
            currentIndex += 1
        }
        symbolsToStrings[index] = variable
    }
    return symbolsToStrings[index]!
}
func detectVariableInt(code: [String], index: Int)->Int{
    if symbolsToInts[index] != nil {return symbolsToInts[index]!}
    else {
        let currentLine = Int(code[index])!
        symbolsToInts[index] = currentLine
    }
    return symbolsToInts[index]!
}
/*
 func doTest(code: [String]){
 print("Beginning execution");
 var registers: [Int] = Array(repeating: 0, count: 10)
 let startOfProgram = Int(code[1])!
 var intLine = 0
 var indexLine = startOfProgram + 2
 var compare = false
 //stores program length
 symbolsToInts[0] = Int(code[0])!
 while indexLine != code.count {
 let currentLine = Int(code[indexLine])!
 //Then run the program from 2nd line number (starting code line):
 intLine = Int(code[indexLine])!
 let nextLine = Int(code[indexLine + 1])!
 let nextNextLine = Int(code[indexLine + 2])!
 //DEBUGGING:
 print(intLine)
 switch intLine {
 case 0:
 //halt
 return;
 case 6:
 //movrr
 registers[nextNextLine] = registers[nextLine]
 indexLine += 2
 case 8:
 //movmr
 registers[nextNextLine] = detectVariableInt(code: code, index: nextLine)
 indexLine += 2
 case 12:
 //addir
 registers[nextNextLine] += nextLine
 indexLine += 2
 case 13:
 //addrr
 registers[nextNextLine] += registers[nextLine]
 indexLine += 2
 case 34:
 //cmprr
 if registers[nextLine] < registers[nextNextLine] {compare = false}
 else {compare = true}
 indexLine += 2
 case 45:
 //outcr
 print(registers[nextLine])
 indexLine += 1
 case 49:
 //printi
 print(registers[nextLine])
 indexLine += 1
 case 55:
 //outs
 print(detectVariableString(code: code, index: nextLine))
 indexLine += 1
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
 indexLine += 1
 }
 }
 */

func readFromFile(path: String?){
    if let filePath = path {
        do {
            let contents = try String(contentsOfFile: filePath)
            let lines = contents.components(separatedBy: "\n")
            // let testLines: [Int] = [79,43,0,20,10,26,65,32,80,114,111,103,114,97,109,32,84,111,32,80,114,105,110,116,32,68,111,117,98,108,101,115,12,32,68,111,117,98,108,101,100,32,105,115,32,8,0,8,8,1,9,8,2,0,55,3,45,0,6,8,1,13,8,1,49,8,55,30,49,1,45,0,34,8,9,12,1,8,57,56,0]
            // var lines: [String] = []
            // var index = 0
            // while index != testLines.count {
            //     lines.append("\(testLines[index])")
            //     index += 1
            // }
            let executioner = Executioner();
            executioner.loadProgram(lines);
            executioner.execute();
        }
        catch {
            print("Contents Failed To Load")
        }
    }
    else {
        print("The File \(path) Was Not Found")
    }
}

//TEST CODE:
readFromFile(path: "/Users/andrewstadnicki/Desktop/Final Project Sap/Final Project Sap/Doubles.txt")
