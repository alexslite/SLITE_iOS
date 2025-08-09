//
// ScenesViewModel.swift
// Slite
//
// Created by Efraim Budusan on 24.01.2022.
//
//

import Foundation
import SwiftUI
import Combine

protocol RemoveLightAlertDataSource: AnyObject {
    func scenesNamesThatContainsLightWith(_ id: String) -> [String]
    func scenesNamesThatContainsGroupWith(_ id: String) -> [String]
    
    func removeScenesWithNames(_ names: [String])
}

extension Scenes {
    
    class ViewModel: ObservableObject, RemoveLightAlertDataSource {
        // MARK: - Properties
        
        @Published var isLoading: Bool = false
        @Published var scenes: [Scene] = []
        
        var canSaveNewScene: Bool {
            sceneDataSource?.isScenesEnable ?? false
        }
        
        let inputName = Delegated<String, PassthroughSubject<String, Never>>()
        var onRemoveScene = PassthroughSubject<Scene, Never>()
        
        var onAddScene = PassthroughSubject<Void, Never>()
        var unableToSaveScene = PassthroughSubject<Void, Never>()
        @Published var showPopUp = false
        
        let scrollHelper = ScrollViewHelper()
        var disposeBag = [AnyCancellable]()
        
        weak var sceneDataSource: SceneSnapshotDataSource?
        weak var scenesDelegate: ScenesActionsDelegate?
        
        // MARK: - Init
        
        init() {
            self.scenes = Cache.loadScenes()
            
            NotificationCenter.default.addObserver(self, selector: #selector(updateCachedScenes), name: UIApplication.willResignActiveNotification, object: nil)
        }
        
        // MARK: - RemoveLightAlertDataSource
        
        func scenesNamesThatContainsLightWith(_ id: String) -> [String] {
            scenes.filter { ($0.lights + $0.groups.flatMap { $0.lights }).contains(where: { $0.id == id })}.map { $0.name }
        }
        func scenesNamesThatContainsGroupWith(_ id: String) -> [String] {
            scenes.filter { $0.groups.contains(where: { $0.id == id})}.map { $0.name }
        }
        
        func removeScenesWithNames(_ names: [String]) {
            scenes.removeAll(where: { names.contains($0.name) })
        }
        
        // MARK: - Edit scenes
        
        func checkAndSaveNewScene() {
            if canSaveNewScene {
                onAddScene.send()
            } else {
                showPopUp = true
            }
        }
        
        func saveNewSceneWithName(_ sceneName: String) {
            guard let sceneDataSource = sceneDataSource else {
                return
            }

            let scence = Scene(id: UUID().uuidString,
                               name: sceneName,
                               lights: sceneDataSource.lightsSnapshot,
                               groups: sceneDataSource.groupsSnapshot)
            scenes.append(scence)
            
            updateCachedScenes()
            Analytics.shared.trackEvent(.sceneCreatedSuccessfully)
        }
        
        func editSceneNameFor(_ scene: Scene, with name: String) {
            guard let index = scenes.firstIndex(where: { $0.id == scene.id }) else { return }
            scenes[index].name = name
            
            updateCachedScenes()
        }
        
        func remove(_ scene: Scene) {
            guard let index = scenes.firstIndex(where: { $0.id == scene.id }) else { return }
            scenes.remove(at: index)
            
            updateCachedScenes()
        }
        
        func nameAction(scene: Scene) {
            (try? inputName.call(with: scene.name))?.sink { [unowned self] name in
                editSceneNameFor(scene, with: name)
                
                updateCachedScenes()
            }.store(in: &disposeBag)
        }
        
        // MARK: - Actions
        
        func applySceneWith(id: String) {
            guard let index = scenes.firstIndex(where: { $0.id == id }) else { return }
            scenes[index].state = .appllying
            scenes[index].lights.forEach {
                scenesDelegate?.updateLightWith($0.id, to: $0.mode, data: $0.dataOutput, effect: $0.effect)
            }
            
            scenes[index].groups.forEach {
                scenesDelegate?.updateGroupWith($0.id, to: $0.dataSnapshot.mode, data: $0.dataSnapshot.dataOutput, effect: $0.dataSnapshot.effect)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
                withAnimation {
                    self.scenes[index].state = .idle
                }
            }
            
            Analytics.shared.trackEvent(.sceneAppliedSuccessfully)
        }
        
        // MARK: - Cache
        
        @objc func updateCachedScenes() {
            Cache.save(scenes)
        }
    }
}
