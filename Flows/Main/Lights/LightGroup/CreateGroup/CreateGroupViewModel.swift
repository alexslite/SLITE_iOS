//
//  CreateGroupViewModel.swift
//  Slite
//
//  Created by Paul Marc on 15.04.2022.
//

import Foundation
import Combine

extension CreateGroup {
    class ViewModel: ObservableObject {
        
        var lightsViewModel: Lights.ViewModel

        @Published var selectedLightsIds: [String] = []
        
        var shouldShowNextButton: Bool {
            selectedLightsIds.count > 1
        }
        
        var onNext = PassthroughSubject<Void, Never>()
        
        init(lightsViewModel: Lights.ViewModel) {
            self.lightsViewModel = lightsViewModel
        }
        
        func selectionStateFor(_ light: LightData) -> Bool {
            selectedLightsIds.contains(light.id)
        }
        
        func update(_ state: Bool, for light: LightData) {
            guard state else {
                selectedLightsIds.remove(object: light.id)
                return
            }
            selectedLightsIds.append(light.id)
        }
    }
}
