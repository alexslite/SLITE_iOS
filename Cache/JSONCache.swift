//
//  JSONCache.swift
//  Slite
//
//  Created by Paul Marc on 09.05.2022.
//

import Foundation

/// Usage Ex:
/// - loading -- `lazy var creditCards: [CreditCard]? = JSONCache.creditCards.loadFromFile()`
/// - saving -- `JSONCache.creditCards.saveToFile(cards)`

enum JSONCache {
    private static var operationsQueues = [String : DispatchQueue]()

//    static var lights: CodableCaching<LightData> {
//        return userResource()
//    }
    
    static func clearAllSavedResource() {
        CodableCaching<Any>.deleteCachingDirectory()
    }
}

extension JSONCache {
    fileprivate static func userResourceID(function: String = #function) -> String {
//        let id = Session.currentUserID ?? ""
//        return function + "_" + id
        return function
    }

    fileprivate static func createDispatchQueue(forID id: String) -> DispatchQueue {
        if let queue = operationsQueues[id] {
            return queue
        }

        let queue = DispatchQueue(label: id, attributes: .concurrent)
        operationsQueues[id] = queue

        return queue
    }

    fileprivate static func userResource<T>(function: String = #function) -> CodableCaching<T> {
        let resourceID = userResourceID(function: function)
        return CodableCaching(resourceID: resourceID, queue: createDispatchQueue(forID: resourceID))
    }

    static func resource<T>(function: String = #function) -> CodableCaching<T> {
        let resourceID = function
        return CodableCaching(resourceID: resourceID, queue: createDispatchQueue(forID: resourceID))
    }
}

