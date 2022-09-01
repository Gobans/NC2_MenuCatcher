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
            self.db = try Connection(path, readonly: true)
        } catch {
            fatalError()
        }
    }
    
    let dbTable: [String:Table] = [
        "과일 채소음료류": Table("과일 채소음료류"), "과자류" : Table("과자류"), "구이류" : Table("구이류"), "국 및 탕류" : Table("국 및 탕류"), "기타 빵류" : Table("기타 빵류"), "기타 음료류" : Table("기타 음료류"), "도넛류" : Table("도넛류"), "면 및 만두류" : Table("면 및 만두류"), "밥류" : Table("밥류"), "버거류" : Table("버거류"), "볶음류" : Table("볶음류"), "샌드위치류" : Table("샌드위치류"), "생채및 무침류" : Table("생채및 무침류"), "스무디류" : Table("스무디류"), "식빵류" : Table("식빵류"), "아이스크림류" : Table("아이스크림류"), "전 적 및 부침류" : Table("전 적 및 부침류"), "조림류" : Table("조림류"), "찌개 및 전골류" : Table("찌개 및 전골류"), "찜류" : Table("찜류"), "차류" : Table("차류"), "커피류" : Table("커피류"), "케이크류" : Table("케이크류"), "크림빵류" : Table("크림빵류"), "탄산음료류" : Table("탄산음료류"), "튀김류" : Table("튀김류"), "페이스트리류" : Table("페이스트리류"), "피자류" : Table("피자류")
    ]
    
    let nameExpression = Expression<String>("식품명")
    let servingExpression = Expression<Int64>("1회제공량")
    let unitExpression = Expression<String>("단위")
    let energyExpression = Expression<Double>("에너지")
    let waterExpression = Expression<Double>("수분")
    let proteinExpression = Expression<Double>("단백질")
    let fatExpression = Expression<Double>("지방")
    let carbohydrateExpression = Expression<Double>("탄수화물")
    let sugarExpression = Expression<Double>("총당류")
    let caffeineExpression = Expression<Double>("카페인")

    func fetchFoodNameByTable(_ tableName: String) async -> [String] {
        var foodNameArray: [String] = []
        
        guard let myTable = dbTable[tableName] else { print("return")
            return [] }
        do {
            for myData in try db.prepare(myTable.select(nameExpression)){
                foodNameArray.append(myData[nameExpression])
            }
        }catch {
            print(error)
        }
        return foodNameArray
    }
    
    func fetchFoodDataByName(tableName: String, foodName: String) async -> FoodData? {
        guard let myTable = dbTable[tableName] else { return nil }
        let query = myTable.filter(foodName == nameExpression)
        var foodData: FoodData? = nil
        do {
            guard let foodInfo = try db.pluck(query) else { print("fetchFoodDatByName retrun")
                return nil }
            foodData = FoodData(name: foodInfo[nameExpression], serving: foodInfo[servingExpression], unit: foodInfo[unitExpression], energy: foodInfo[energyExpression], water: foodInfo[waterExpression], protein: foodInfo[proteinExpression], fat: foodInfo[fatExpression], carbohydrate: foodInfo[carbohydrateExpression], sugar: foodInfo[sugarExpression], caffeine: foodInfo[caffeineExpression])
        }catch {
            print(error)
        }
        return foodData
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
