//
//  AnyObservableObject.swift
//  Slite
//
//  Created by Efraim Budusan on 09.02.2022.
//

import Foundation
import Combine

protocol TypeErasedObservableObject {

    var erasedPublisher: AnyPublisher<Void, Never> { get }
}

extension TypeErasedObservableObject where Self: ObservableObject {
    
    var erasedPublisher: AnyPublisher<Void, Never> {
        return self.objectWillChange.map({ _ in () }).eraseToAnyPublisher()
    }
}

class AnyObservableObject: ObservableObject {

    private var base: TypeErasedObservableObject

    var diposeBag = [AnyCancellable]()

    init(base: TypeErasedObservableObject) {
        self.base = base
        base.erasedPublisher.sink { [weak self] in
            self?.objectWillChange.send()
        }.store(in: &diposeBag)
    }
}
