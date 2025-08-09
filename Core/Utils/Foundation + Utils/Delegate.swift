//
//  Delegate.swift
//  Slite
//
//  Created by Efraim Budusan on 03.03.2022.
//

import Foundation
import Combine



class Delegated<Input, Output> {
    
    struct DelegatedError: Error {
        
    }
    
    private var _callback:((Input) -> Output)!

    func set(_ _callback:@escaping ((Input) -> Output)) {
        self._callback = _callback
    }
    
    func set(from delegated:Delegated<Input, Output>) {
        self._callback = delegated._callback
    }

    func call(with input:Input) throws -> Output {
        guard hasValue else {
            throw DelegatedError()
        }
        return _callback(input)
    }
    
    var hasValue:Bool {
        return _callback != nil
    }
}


extension Delegated where Input == Void {
    
    func call() throws -> Output {
        return try self.call(with: ())
    }
}

typealias VoidInputDelegated<Output> = Delegated<Void, Output>


@propertyWrapper
class VoidDelegated<T> {
    
    var defaultValue:T!
    var delegation: Delegated<Void,T> = Delegated()
    
    init(wrappedValue:T) {
        self.defaultValue = wrappedValue
    }
    
    init() {
        
    }
    
    var wrappedValue: T {
        get {
            do {
                return try delegation.call()
            } catch {
                return defaultValue
            }
        }
    }
    
    var projectedValue: Delegated<Void,T> {
        get {
            return self.delegation
        }
        set {
            self.delegation = newValue
        }
    }
}

//
//
//class AsyncDelegated<Input, Output> {
//        
//    private var _callback:((Input) async -> Output)!
//
//    func set(_ _callback:@escaping ((Input) async -> Output)) {
//        self._callback = _callback
//    }
//    
//    func set(from delegated: AsyncDelegated<Input, Output>) {
//        self._callback = delegated._callback
//    }
//
//    func invoke(with input:Input) async throws -> Output {
//        guard hasValue else {
//            throw DelegatedError()
//        }
//        return await _callback(input)
//    }
//    
//    var hasValue:Bool {
//        return _callback != nil
//    }
//    
//    struct DelegatedError: Error { }
//}
