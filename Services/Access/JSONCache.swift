//
//  JSONCache.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation

/// Usage Ex:
/// - loading -- `lazy var creditCards: [CreditCard]? = JSONCache.creditCards.loadFromFile()`
/// - saving -- `JSONCache.creditCards.saveToFile(cards)`
enum JSONCache {
    
    private static var operationsQueues = [String : DispatchQueue]()
    
    static var scenes: CodableCaching<[Scene]> {
        return resource()
    }
    
    static var groups: CodableCaching<[LightsGroup]> {
        return resource()
    }
    
    static var light: CodableCaching<LightData> {
        return resource()
    }
    
    static var lights: CodableCaching<[LightData]> {
        return resource()
    }
    
    static var currentUser: CodableCaching<User> {
        return userResource()
    }
    
    static func clearAllSavedResource() {
        CodableCaching<Any>.deleteCachingDirectory()
    }
}

extension JSONCache {
    fileprivate static func userResourceID(function: String = #function) -> String {
        return function
    }
    
    fileprivate static func userResource<T>(function: String = #function) -> CodableCaching<T> {
        let resourceID = userResourceID(function: function)
        return CodableCaching(resourceID: resourceID, queue: createDispatchQueue(forID: resourceID))
    }
    
    fileprivate static func resource<T>(function: String = #function) -> CodableCaching<T> {
        let resourceID = function
        return CodableCaching(resourceID: resourceID, queue: createDispatchQueue(forID: resourceID))
    }
    
    fileprivate static func createDispatchQueue(forID id: String) -> DispatchQueue {
        if let queue = operationsQueues[id] {
            return queue
        }

        let queue = DispatchQueue(label: id, attributes: .concurrent)
        operationsQueues[id] = queue

        return queue
    }
}

