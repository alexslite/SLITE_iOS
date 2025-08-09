//
// AddMenuViewModel.swift
// Slite
//
// Created by Efraim Budusan on 24.01.2022.
//
//

import Foundation
import Combine

extension AddMenu {
    
    class ViewModel: ObservableObject {
        
        weak var menuInputsState: MenuInpuState?
        
        @Published var isLoading: Bool = false
        @Published var entranceAnimation: EntranceAnimationState = .armed
        
        init(menuInputState: MenuInpuState) {
            self.menuInputsState = menuInputState
        }
        
        var isGroupEnabled: Bool {
            menuInputsState?.isGroupEnable ?? false
        }
        var isScenesEnabled: Bool {
            menuInputsState?.isScenesEnable ?? false
        }
        
        let onClose = PassthroughSubject<Void, Never>()
        let onAddLight = PassthroughSubject<Void, Never>()
        let onCreateGroup = PassthroughSubject<Void, Never>()
        let onCreateScene = PassthroughSubject<Void, Never>()
    }
}

enum EntranceAnimationState {
    case armed
    case finished
    case none
}
