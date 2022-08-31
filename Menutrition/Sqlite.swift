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
//            let _ = Sqlite.copyDatabaseIfNeeded(sourcePath: path)
            self.db = try Connection(path, readonly: true)
        } catch {
            fatalError()
        }
    }
    
    let dbTable: [String:Table] = [
        "과일 채소음료류": Table("과일 채소음료류"), "과자류" : Table("과자류"), "구이류" : Table("구이류"), "국 및 탕류" : Table("과자류"), "기타 빵류" : Table("과자류"), "기타 음료류" : Table("과자류"), "도넛류" : Table("과자류"), "면 및 만두류" : Table("과자류"), "밥류" : Table("과자류"), "버거류" : Table("과자류"), "볶음류" : Table("과자류"), "샌드위치류" : Table("과자류"), "생채및 무침류" : Table("과자류"), "스무디류" : Table("과자류"), "식빵류" : Table("과자류"), "아이스크림류" : Table("과자류"), "전 적 및 부침류" : Table("과자류"), "조림류" : Table("과자류"), "찌개 및 전골류" : Table("과자류"), "찜류" : Table("과자류"), "차류" : Table("과자류"), "커피류" : Table("커피류"), "케이크류" : Table("과자류"), "크림빵류" : Table("과자류"), "탄산음료류" : Table("과자류"), "튀김류" : Table("과자류"), "페이스트리류" : Table("과자류"), "피자류" : Table("과자류")
    ]
    
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
    
    func fetchFoodNameByTable(_ tableName: String) -> [String] {
        var foodNameArray: [String] = []
        guard let myTable = dbTable[tableName] else { return [] }
        do {
            for myData in try db.prepare(myTable.select(FoodName)){
                foodNameArray.append(myData[FoodName])
            }
        }catch {
            print(error)
        }
        return foodNameArray
    }
    
    func fetchFoodDataByName(tableName: String, foodName: String) -> [String] {
        var foodNameArray: [String] = []
        guard let myTable = dbTable[tableName] else { return [] }
        do {
            for myData in try db.prepare(myTable){
                foodNameArray.append(myData[FoodName])
            }
        }catch {
            print(error)
        }
        return foodNameArray
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
