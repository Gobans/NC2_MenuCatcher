//
//  Sqlite.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/08/30.
//

import Foundation
import SQLite

final class Sqlite {
    
    static let shared = Sqlite()
    let db: Connection
    
    private init() {
        do {
            let path = Bundle.main.path(forResource: "FoodDB", ofType: "sqlite3")!
            let _ = Sqlite.copyDatabaseIfNeeded(sourcePath: path)
            self.db = try Connection(path, readonly: true)
        } catch {
            fatalError()
        }
    }
    
    let dbTable: [String] = ["과일 채소음료류", "과자류", "구이류", "국 및 탕류", "기타 빵류", "기타 음료류", "도넛류", "면 및 만두류", "밥류", "버거류", "볶음류", "샌드위치류", "생채및 무침류", "스무디류", "식빵류", "아이스크림류", "전 적 및 부침류", "조림류", "찌개 및 전골류", "찜류", "차류", "커피류", "케이크류", "크림빵류", "탄산음료류", "튀김류", "페이스트리류", "피자류"]
    
    let FoodName = Expression<String>("식품명")
    let Serving = Expression<Int64>("1회제공량")
    let unit = Expression<String>("단위")
    let energy = Expression<Double>("에너지")
    let water = Expression<Double>("수분")
    let protein = Expression<Double>("단백질")
    let fat = Expression<Double>("지방")
    let carbohydrate = Expression<Double>("탄수화물")
    let sugar = Expression<Double>("총당류")
    let Caffeine = Expression<Double>("카페인")
   
    func fetchData() {
        let myTable = Table("밥류")
        do {
        for myData in try db.prepare(myTable){
            print("식품명 \(myData[FoodName])")
            print("1회제공량 \(myData[Serving])")
            print("단백질 \(myData[protein])")
            }
        }catch {
            print("faild to connect db")
        }
    }
    static private func copyDatabaseIfNeeded(sourcePath: String) -> Bool {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let destinationPath = documents + "/FoodDB.sqlite3"
        let exists = FileManager.default.fileExists(atPath: destinationPath)
        guard !exists else { return false }
        do {
            try FileManager.default.copyItem(atPath: sourcePath, toPath: destinationPath)
            return true
        } catch {
          print("error during file copy: \(error)")
            return false
        }
    }
}
