//
//  UserDefaults+Extension.swift
//  Menutrition
//
//  Created by Lee Myeonghwan on 2022/10/12.
//

import Foundation

extension UserDefaults {
    var isUserSeenOnboarding: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isUserSeenOnboarding")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isUserSeenOnboarding")
        }
    }
}
