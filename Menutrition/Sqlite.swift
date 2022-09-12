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
            fatalError("Faild to connect DataBase")
        }
    }
    
    let dbTable: [String:Table] = [
        "과일 채소음료류": Table("과일 채소음료류"), "과자류" : Table("과자류"), "기타 빵류" : Table("기타 빵류"), "기타 음료류" : Table("기타 음료류"), "기타 음식류": Table("기타 음식류"), "샌드위치류" : Table("샌드위치류"), "스무디류" : Table("스무디류"), "식빵류" : Table("식빵류"), "아이스크림류" : Table("아이스크림류"), "차류" : Table("차류"), "커피류" : Table("커피류"), "케이크류" : Table("케이크류"), "탄산음료류" : Table("탄산음료류"), "튀김류" : Table("튀김류"), "페이스트리류" : Table("페이스트리류"), "피자류" : Table("피자류")
    ]
    
    let FoodCategory: [String] = [
        "과일 채소음료류", "과자류", "기타 빵류", "기타 음료류", "기타 음식류", "샌드위치류", "스무디류", "식빵류", "아이스크림류", "차류", "커피류", "케이크류", "탄산음료류", "튀김류", "페이스트리류", "피자류"
    ]
    
    let dbFoodNameDictionary: [String: [String]] = [:]
    
    let nameExpression = Expression<String>("식품명")
    let servingExpression = Expression<Int64>("1회제공량")
    let unitExpression = Expression<String>("단위")
    let energyExpression = Expression<Double>("에너지")
    let proteinExpression = Expression<Double>("단백질")
    let fatExpression = Expression<Double>("지방")
    let carbohydrateExpression = Expression<Double>("탄수화물")
    let sugarExpression = Expression<Double>("총당류")
    let natriumExpression = Expression<Double>("나트륨")
    let cholesterolExpression = Expression<Double>("콜레스테롤")
    let saturatedFatExpression = Expression<Double>("포화지방")
    let transFatExpression = Expression<Double>("트랜스지방")
    let caffeineExpression = Expression<Double>("카페인")

    func fetchAllFoodName() async -> [String: [String]] {
        var foodNameDictionary: [String: [String]] = [:]
        let _ =  FoodCategory.map {
            foodNameDictionary[$0] = []
        }
        for item in dbTable {
            let myTable = item.value
            do {
                for myData in try db.prepare(myTable.select(nameExpression)){
                    foodNameDictionary[item.key]?.append(myData[nameExpression])
                }
            }catch {
                print("Faild to fetch all food name")
            }
        }
        return foodNameDictionary
    }
    
    func fetchFoodDataByName(tableName: String, foodName: String) async -> FoodData? {
        guard let myTable = dbTable[tableName] else { return nil }
        let query = myTable.filter(foodName == nameExpression)
        var foodData: FoodData? = nil
        do {
            guard let foodInfo = try db.pluck(query) else { print("fetchFoodDatByName retrun")
                return nil }
            foodData = FoodData(
                name: foodInfo[nameExpression],
                serving: foodInfo[servingExpression],
                unit: foodInfo[unitExpression],
                energy: foodInfo[energyExpression],
                protein: foodInfo[proteinExpression],
                fat: foodInfo[fatExpression],
                carbohydrate: foodInfo[carbohydrateExpression],
                sugar: foodInfo[sugarExpression],
                natrium: foodInfo[natriumExpression],
                cholesterol: foodInfo[cholesterolExpression],
                saturatedFat: foodInfo[saturatedFatExpression],
                transFat: foodInfo[transFatExpression],
                caffeine: foodInfo[caffeineExpression]
            )
        }catch {
            print(error)
        }
        return foodData
    }
}
