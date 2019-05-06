/*
 79
 43
 0
 20
 10
 26
 65
 32
 80
 114
 111
 103
 114
 97
 109
 32
 84
 111
 32
 80
 114
 105
 110
 116
 32
 68
 111
 117
 98
 108
 101
 115
 12
 32
 68
 111
 117
 98
 108
 101
 100
 32
 105
 115
 32
 8
 0
 8
 8
 1
 9
 8
 2
 0
 55
 3
 45
 0
 6
 8
 1
 13
 8
 1
 49
 8
 55
 30
 49
 1
 45
 0
 34
 8
 9
 12
 1
 8
 57
 56
 0

 */

//will this work now?
import Foundation
// import Glibc
func characterToUnicodeValue(_ c: Character)->Int {
    let s = String(c)
    return Int(s.unicodeScalars[s.unicodeScalars.startIndex].value)
}

func unicodeValueToCharacter(_ n: Int)->Character{
    return Character(UnicodeScalar(n)!)
}
enum instruction: Int {
    case halt = 0
    case clrr = 1
    case clrx = 2
    case clrm = 3
    case clrb = 4
    case movir = 5
    case movrr = 6
    case movrm = 7
    case movmr = 8
    case movxr = 9
    case movar = 10
    case movb = 11
    case addir = 12
    case addrr = 13
    case addmr = 14
    case addxr = 15
    case subir = 16
    case subrr = 17
    case submr = 18
    case subxr = 19
    case mulir = 20
    case mulrr = 21
    case mulmr = 22
    case mulxr = 23
    case divir = 24
    case divrr = 25
    case divmr = 26
    case divxr = 27
    case jmp = 28
    case sojz = 29
    case sojnz = 30
    case aojz = 31
    case aojnz = 32
    case cmpir = 33
    case cmprr = 34
    case cmpmr = 35
    case jmpn = 36
    case jmpz = 37
    case jmpp = 38
    case jsr = 39
    case ret = 40
    case push = 41
    case pop = 42
    case stackc = 43
    case outci = 44
    case outcr = 45
    case outcx = 46
    case outcb = 47
    case readi = 48
    case printi = 49
    case readc = 50
    case readln = 51
    case brk = 52
    case movrx = 53
    case movxx = 54
    case outs = 55
    case nop = 56
    case jmpne = 57
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

func readFromFile(path: String?, specificClass: String){
    if let filePath = path {
        do {
            if specificClass == "executioner" {
                let contents = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8);
                let lines = contents.components(separatedBy: "\n")
                // let testLines: [Int] = [79,43,0,20,10,26,65,32,80,114,111,103,114,97,109,32,84,111,32,80,114,105,110,116,32,68,111,117,98,108,101,115,12,32,68,111,117,98,108,101,100,32,105,115,32,8,0,8,8,1,9,8,2,0,55,3,45,0,6,8,1,13,8,1,49,8,55,30,49,1,45,0,34,8,9,12,1,8,57,56,0]
                // var lines: [String] = []
                // var index = 0
                // while index != testLines.count {
                //     lines.append("\(testLines[index])")
                //     index += 1
                // }
                let executioner = Executioner()
                executioner.loadProgram(lines)
                executioner.execute()
            }
            if specificClass == "assembler" {
//                let contents = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8);
//                let lines = contents.components(separatedBy: "\n")
//                let assembler = Assembler()
//                assembler.loadProgram(lines)
//                assembler.assemble()
            }
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
var a = Assembler();
var doubles = """
.Start Test
;doubles
;a program to print doubles
Begin: .Integer #0
End: .Integer #20
NewLine: .Integer #10
IntroMess: .String "A program to print doubles"
DoubleMess: .String " doubled is "
;r0 will contain the newline character
;there are some more comments about what the other registers will contain
;this is really just to make sure the assembler ignores comments
Test: movmr Begin r8
movmr End r9
movmr NewLine r0
outs IntroMess
outcr r0
Do01: movrr r8 r1
addrr r8 r1
printi r8
outs DoubleMess
printi r1
outcr r0
cmprr r8 r9
addir #1 r8
jmpne do01
wh01: halt
.End
"""
var user = "andewstadnicki"
var program = "Doubles"
a.assemble(path: "/Users/\(user)/Desktop/\(program)")
readFromFile(path: "/Users/\(user)/Desktop/\(program).bin", specificClass: "executioner")
//Andrew's computer: /Users/andrewstadnicki/Desktop/Doubles.txt
//Computer at school: /Users/STUDENT ID NUMBER HERE/Desktop/Doubles.txt
