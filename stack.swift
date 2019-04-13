import Foundation

//Helper Function:
func setArraySize(_ s: Int)->[Int?]{
    var a: [Int?] = []
    var index2 = 0
    while index2 != s {
        a.append(nil)
        index2 += 1
    }
    return a
}

struct IntStack : CustomStringConvertible{
    var pointer: Int = 0
    var array: [Int?] = []
    var size: Int
    init(size: Int){
        self.size = size
        array = setArraySize(size)
    }
    //Nothing to pop
    func isEmpty()->Bool{
        for e in array {
            if e != nil {
                return false
            }
        }
        return true
    }
    //Don't add if full
    func isFull()->Bool{
        for e in array {
            if e == nil {
                return false
            }
        }
        return true
    }
    var index = 0
    mutating func push(_ element: Int){
        //if not full
        if isFull() == false {
            array[pointer] = element
            //move pointer up 1
            pointer += 1
        }
    }
    //remove last value
    mutating func pop()->Int?{
        //if not empty
        if isEmpty() == false {
            pointer -= 1
            //if pointer is less than 0, move it back to 0
            if pointer < 0 {
                pointer = 0
            }
            let value: Int? = array[pointer]
            array[pointer] = nil
            if value == nil {
                return nil
            }
            return value
        }
        else {
            return nil
        }
    }
    //prints array
    var description: String {
        var d: String = ""
        var index = 0
        while index != size {
            d += "\(array[index]) "
            index += 1
        }
        return d
    }
}
