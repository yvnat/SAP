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

var u = UI()
u.run();
//Andrew's computer: /Users/andrewstadnicki/Desktop/Doubles.txt
//Computer at school: /Users/STUDENT ID NUMBER HERE/Desktop/Doubles.txt
