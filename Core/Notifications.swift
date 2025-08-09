//
//  Notifications.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation

enum Notifications {
    public class Notification<T, Identifier: Equatable> {
        private var allObservers: [WeakContainer] = []
        
        public var observers: [RegisteredObserver] {
            observersRegisteredByOwners = observersRegisteredByOwners.filter({ $0.owner != nil }) // remove observers where owner is nil
            let aliveObservers = allObservers.compactMap({ $0.value })
            
            if aliveObservers.count != allObservers.count {
                allObservers = allObservers.filter({ $0.value != nil }) // remove dead observers
            }
            
            return aliveObservers
        }
        
        /// save returned token to have this observation alive.
        public func register(identifier: Identifier? = nil, callback: @escaping (T) -> Void) -> Any {
            let observation = RegisteredObserver(identifier: identifier, callback: callback)
            allObservers.append(WeakContainer(value: observation))
            return observation
        }
        
        public func post(_ payload: T, identifier: Identifier? = nil) {
            observers.filter({ $0.identifier == nil || $0.identifier == identifier }).forEach { $0.callback(payload) }
        }
        
        
        private var observersRegisteredByOwners: [RegisteredObserver] = []
        /// only while onwer is alive, callback will be triggered. No need to unregister
        public func addObserver<Observer: AnyObject>(_ observer: Observer, identifier: Identifier? = nil, callback: @escaping (Observer, T) -> Void) {
            let observation = RegisteredObserver(identifier: identifier, callback: { [weak observer] payload in
                if let observer = observer {
                    callback(observer, payload)
                }
            })
            observation.owner = observer
            allObservers.append(WeakContainer(value: observation))
            observersRegisteredByOwners.append(observation) // keep this observation alive until owner is deallocated
        }
        
        /// only while onwer is alive, callback will be triggered. No need to unregister
        public func addObserver<Observer: NSObject>(_ observer: Observer, identifier: Identifier? = nil, selector: Selector) {
            addObserver(observer, identifier: identifier, callback: { (observer, type) in
                observer.perform(selector, with: type)
            })
        }
        
        /// remove all observations registered by owner
        public func remove(owner: AnyObject) {
            observersRegisteredByOwners = observersRegisteredByOwners.filter({ $0.owner !== owner })
        }
        
        public class RegisteredObserver: CustomDebugStringConvertible {
            
            public let identifier: Identifier?
            public var callback: (T) -> Void
            public weak var owner: AnyObject?
            
            public init(identifier: Identifier?, callback: @escaping (T) -> Void) {
                self.callback = callback
                self.identifier = identifier
            }
            
            var debugDescription: String {
                return String(describing: type(of: self)) + "_" + String(describing: T.self) + "_" + (identifier != nil ? String(describing:identifier!) : "")
            }
        }
        
        private class WeakContainer {
            weak var value: RegisteredObserver?
            
            init(value: RegisteredObserver) {
                self.value = value
            }
        }
    }
}



extension Notifications.Notification where T == Void {
    
    internal func post(identifier: Identifier? = nil) {
        post((), identifier: identifier)
    }
    
    internal func addObserver<Observer: AnyObject>(_ observer: Observer, identifier: Identifier? = nil, callback: @escaping (Observer) -> Void) {
        addObserver(observer, identifier: identifier, callback: { (observer, _) in
            callback(observer)
        })
    }
}

