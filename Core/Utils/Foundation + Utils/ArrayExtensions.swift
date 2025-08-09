//
//  String+Email.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }
}

extension Array {
    
    mutating func removeFirst(where condition: (Element) -> Bool) -> Element? {
        var element: Element?
        if let index = firstIndex(where: condition) {
            element = self[index]
            remove(at: index)
        }
        return element
    }
}

extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


extension Array  {
    
    public func except(_ isExclueded: (Element) throws -> Bool) rethrows -> [Element] {
        return try filter({try !isExclueded($0)})
    }
}


class Weak<T: AnyObject> {
    weak var value : T?
    init (_ value: T) {
        self.value = value
    }
}

extension Array where Element:Weak<AnyObject> {
    mutating func reap () {
        self = self.filter { nil != $0.value }
    }
}

extension Array where Element: Equatable {
    func removingDuplicates() -> Array {
        return reduce(into: []) { result, element in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
}

extension Array {
    func toDictionary<K,V>() -> [K:V] where Iterator.Element == (K,V) {
        return self.reduce([:]) {
            var dict:[K:V] = $0
            dict[$1.0] = $1.1
            return dict
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}


