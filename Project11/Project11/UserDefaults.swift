//
//  UserDefaults.swift
//  Project11
//
//  Created by Mikhail Zhuzhman on 11.06.2024.
//

import Foundation

struct UserRecord: Codable, Comparable {
    let nickname: String
    let record: Int
    let level: Int

    static func < (lhs: UserRecord, rhs: UserRecord) -> Bool {
        return lhs.record > rhs.record
    }
}

// Optional: Implementing Equatable (though Comparable inherits from Equatable)
extension UserRecord {
    static func == (lhs: UserRecord, rhs: UserRecord) -> Bool {
        return lhs.record == rhs.record
    }
}
