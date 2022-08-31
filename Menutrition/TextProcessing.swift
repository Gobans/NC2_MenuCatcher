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
    
    enum Decomposition {
        case basic
        case jamo
        case consonant
    }
    
    static var hashDic: [String:String] = [:]
    
    private static func substitution_cost(c1: String, c2: String, mode: Decomposition, baseLength: Float) -> Float {
        switch mode {
        case .basic:
            return 1
        case .jamo:
            if c1 == c2 {
                return 0
            }
            return TextProcessing.levenshtein(base: Hangul.getJamo(c1), other: Hangul.getJamo(c2), mode: .basic)/3
        case .consonant:
            if c1 == c2 {
                return 0
            }
            return TextProcessing.levenshtein(base: Hangul.getConsonant(c1), other: Hangul.getConsonant(c2), mode: .basic)
        }
    }
    
    static func levenshtein(base: String, other: String, mode: Decomposition) -> Float {
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
    
    private class Hangul {
        // UTF-8 기준
        static let INDEX_HANGUL_START:UInt32 = 44032  // "가"
        static let INDEX_HANGUL_END:UInt32 = 55199    // "힣"
        
        static let CYCLE_CHO :UInt32 = 588
        static let CYCLE_JUNG :UInt32 = 28
        
        static let CHO = [
            "ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ",
            "ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
        ]
        
        static let JUNG = [
            "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ","ㅕ", "ㅖ", "ㅗ", "ㅘ",
            "ㅙ", "ㅚ","ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ",
            "ㅣ"
        ]
        
        static let JONG = [
            "","ㄱ","ㄲ","ㄳ","ㄴ","ㄵ","ㄶ","ㄷ","ㄹ","ㄺ",
            "ㄻ","ㄼ","ㄽ","ㄾ","ㄿ","ㅀ","ㅁ","ㅂ","ㅄ","ㅅ",
            "ㅆ","ㅇ","ㅈ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
        ]
        
        static let JONG_DOUBLE = [
            "ㄳ":"ㄱㅅ","ㄵ":"ㄴㅈ","ㄶ":"ㄴㅎ","ㄺ":"ㄹㄱ","ㄻ":"ㄹㅁ",
            "ㄼ":"ㄹㅂ","ㄽ":"ㄹㅅ","ㄾ":"ㄹㅌ","ㄿ":"ㄹㅍ","ㅀ":"ㄹㅎ",
            "ㅄ":"ㅂㅅ"
        ]
        
        private static var jamoHashTable: [String:String] = [:]
        private static var consonantHashTable: [String:String] = [:]
        
        class func getJamo(_ input: String) -> String {
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
        
        class func getConsonant(_ input: String) -> String {
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
        
        
        private class func getJamoFromOneSyllable(_ n: UnicodeScalar) -> String?{
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
        
        private class func getConsonantFromOneSyllable(_ n: UnicodeScalar) -> String?{
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
