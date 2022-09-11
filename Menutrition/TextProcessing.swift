//
//  Regex.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/08/31.
//

import RegexBuilder
import Foundation

extension String {
    subscript(index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}

extension CharacterSet{
    static var modernHangul: CharacterSet{
        return CharacterSet(charactersIn: ("가".unicodeScalars.first!)...("힣".unicodeScalars.first!))
    }
}

final class TextProcessing {
    
    private let hangul: Hangul = Hangul()
    
    enum Decomposition {
        case basic
        case jamo
        case consonant
    }
    
//    func findSimliarWord(baseString: String, otehrStringArray: [String]) -> (String, [String]){
//        var resultString: String = ""
//        var candidateArray: [String] = []
//        var precedingCandidateArray: [(String, Float)] = []
//        var trailingCandidateArray: [String] = []
//        for otherString in otehrStringArray {
//            let consonantResultCost: Float = levenshtein(base: baseString, other: otherString, mode: .consonant)
//            if consonantResultCost <= 1 {
//                let jamoResultCost: Float = levenshtein(base: baseString, other: otherString, mode: .jamo)
//                if jamoResultCost < 1 {
//                    resultString = otherString
//                    break
//                } else {
//                    precedingCandidateArray.append((otherString, jamoResultCost))
//                }
//            } else if consonantResultCost <= 3 {
//                trailingCandidateArray.append(otherString)
//            }
//        }
//        while (!trailingCandidateArray.isEmpty && precedingCandidateArray.count < 5) {
//            if let trailingCandidateString = trailingCandidateArray.popLast() {
//                let jamoResultCost: Float = levenshtein(base: baseString, other: trailingCandidateString, mode: .jamo)
//                precedingCandidateArray.append((trailingCandidateString, jamoResultCost))
//            }
//        }
//        if !precedingCandidateArray.isEmpty {
//            precedingCandidateArray.sort(by: {$0.1 > $1.1})
//            while (!precedingCandidateArray.isEmpty && candidateArray.count < 5) {
//                if let similarItem = precedingCandidateArray.popLast() {
//                    candidateArray.append(similarItem.0)
//                }
//            }
//        }
//        if resultString == "" && !candidateArray.isEmpty {
//            resultString = candidateArray.removeFirst()
//        }
//        return (resultString, candidateArray)
//    }
    func findSimliarWord(baseString: String, vaildfoodNameDictionary: [String: [String]]) -> ((String,String), [(String,String)]){
        var result: (String, String) = ("","")
        var candidateArray: [(String, String)] = []
        var tempCandidateArray: [String:(String, Float)] = [:]
        for item in vaildfoodNameDictionary {
            for vaildFoodName in item.value {
                let rmSpacingFoodName = vaildFoodName.replacingOccurrences(of: " ", with: "")
                let jamoResultCost: Float = levenshtein(base: baseString, other: rmSpacingFoodName, mode: .jamo)
                tempCandidateArray[vaildFoodName] = (item.key, jamoResultCost)
            }
        }
        print("------------------------")
        print("baseString: \(baseString)")
        print(tempCandidateArray)
        var sortedTempCandidateArray = tempCandidateArray.sorted(by: {$0.value.1 > $1.value.1}).map{($0.key, $0.value.0)}
        if result.0 == "" && !sortedTempCandidateArray.isEmpty{
            result = sortedTempCandidateArray.popLast()!
        }
        while (!sortedTempCandidateArray.isEmpty && candidateArray.count < 5) {
            candidateArray.append(sortedTempCandidateArray.popLast()!)
        }
        return (result, candidateArray)
    }
    
    func checkVaildConsonantFood(verifyString: String, dbFoodNameArray: [String]) -> [String] {
        var vaildConsonantFoodArray: [String] = []
        for dbFoodName in dbFoodNameArray {
            let rmSpacingFoodName = dbFoodName.replacingOccurrences(of: " ", with: "")
            let consonantResultCost: Float = levenshtein(base: verifyString, other: rmSpacingFoodName, mode: .consonant)
            if consonantResultCost <= 2 {
                vaildConsonantFoodArray.append(dbFoodName)
            }
        }
        
        return vaildConsonantFoodArray
    }
    
    func isValidWord(_ phase: String) -> Bool {
        if phase == "" { return false }
        let wordRegEx = "(?=.*[가-힣])"
        let isContainHangul = phase.range(of: wordRegEx, options: .regularExpression) != nil
        if !isContainHangul { return false }
        var spacingCount:Int = 0
        for char in phase {
            if char == " " {
                spacingCount += 1
                if spacingCount == 4 { return false }
            }
        }
        return true
    }
    
    
    private func substitution_cost(c1: String, c2: String, mode: Decomposition, baseLength: Float) -> Float {
        switch mode {
        case .basic:
            return 1
        case .jamo:
            if c1 == c2 {
                return 0
            }
            return levenshtein(base: hangul.getJamo(c1), other: hangul.getJamo(c2), mode: .basic)/3
        case .consonant:
            if c1 == c2 {
                return 0
            }
            return levenshtein(base: hangul.getConsonant(c1), other: hangul.getConsonant(c2), mode: .basic)
        }
    }
    
    func levenshtein(base: String, other: String, mode: Decomposition) -> Float {
        let bCount = base.count
        let oCount = other.count
        
        guard bCount != 0 else {
            return Float(oCount)
        }
        
        guard oCount != 0 else {
            return Float(bCount)
        }
        
        let line: [Float] = Array(repeating: 0, count: oCount + 1)
        var mat: [[Float]] = Array(repeating: line, count: bCount + 1)
        
        for i in 0...bCount {
            mat[i][0] = Float(i)
        }
        
        for j in 0...oCount {
            mat[0][j] = Float(j)
        }
        
        for j in 1...oCount {
            for i in 1...bCount {
                if base[i - 1] == other[j - 1] {
                    mat[i][j] = mat[i - 1][j - 1]       // no operation
                }
                else {
                    let del = mat[i - 1][j] + 1         // deletion
                    let ins = mat[i][j - 1] + 1         // insertion
                    let sub = mat[i - 1][j - 1] + substitution_cost(c1: String(base[i - 1]), c2: String(other[j - 1]), mode: mode, baseLength: Float(bCount))    // substitution
                    mat[i][j] = min(min(del, ins), sub)
                }
            }
        }
        return mat[bCount][oCount]
    }
    
    private final class Hangul {
        // UTF-8 기준
        private let INDEX_HANGUL_START:UInt32 = 44032  // "가"
        private let INDEX_HANGUL_END:UInt32 = 55199    // "힣"
        
        private let CYCLE_CHO :UInt32 = 588
        private let CYCLE_JUNG :UInt32 = 28
        
        private let CHO = [
            "ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ",
            "ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
        ]
        
        private let JUNG = [
            "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ","ㅕ", "ㅖ", "ㅗ", "ㅘ",
            "ㅙ", "ㅚ","ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ",
            "ㅣ"
        ]
        
        private let JONG = [
            "","ㄱ","ㄲ","ㄳ","ㄴ","ㄵ","ㄶ","ㄷ","ㄹ","ㄺ",
            "ㄻ","ㄼ","ㄽ","ㄾ","ㄿ","ㅀ","ㅁ","ㅂ","ㅄ","ㅅ",
            "ㅆ","ㅇ","ㅈ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
        ]
        
        private let JONG_DOUBLE = [
            "ㄳ":"ㄱㅅ","ㄵ":"ㄴㅈ","ㄶ":"ㄴㅎ","ㄺ":"ㄹㄱ","ㄻ":"ㄹㅁ",
            "ㄼ":"ㄹㅂ","ㄽ":"ㄹㅅ","ㄾ":"ㄹㅌ","ㄿ":"ㄹㅍ","ㅀ":"ㄹㅎ",
            "ㅄ":"ㅂㅅ"
        ]
        
        private var jamoHashTable: [String:String] = [:]
        private var consonantHashTable: [String:String] = [:]
        
        func getJamo(_ input: String) -> String {
            // hashing
            guard let hashJamo = jamoHashTable[input] else {
                var jamo = ""
                //let word = input.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .punctuationCharacters)
                for scalar in input.unicodeScalars{
                    jamo += getJamoFromOneSyllable(scalar) ?? ""
                }
                jamoHashTable[input] = jamo
                return jamo
            }
            return hashJamo
        }
        
        func getConsonant(_ input: String) -> String {
            // hashing
            guard let hashConsonant = consonantHashTable[input] else {
                var consonant = ""
                //let word = input.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .punctuationCharacters)
                for scalar in input.unicodeScalars{
                    consonant += getConsonantFromOneSyllable(scalar) ?? ""
                }
                consonantHashTable[input] = consonant
                return consonant
            }
            return hashConsonant
        }
        
        
        private func getJamoFromOneSyllable(_ n: UnicodeScalar) -> String?{
            if CharacterSet.modernHangul.contains(n){
                let index = n.value - INDEX_HANGUL_START
                let cho = CHO[Int(index / CYCLE_CHO)]
                let jung = JUNG[Int((index % CYCLE_CHO) / CYCLE_JUNG)]
                var jong = JONG[Int(index % CYCLE_JUNG)]
                if let disassembledJong = JONG_DOUBLE[jong] {
                    jong = disassembledJong
                }
                return cho + jung + jong
            }else{
                return String(UnicodeScalar(n))
            }
        }
        
        private func getConsonantFromOneSyllable(_ n: UnicodeScalar) -> String?{
            if CharacterSet.modernHangul.contains(n){
                let index = n.value - INDEX_HANGUL_START
                let cho = CHO[Int(index / CYCLE_CHO)]
                return cho
            } else{
                return String(UnicodeScalar(n))
            }
        }
    }
}
