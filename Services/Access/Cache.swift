//
//  Cache.swift
//  Slite
//
//  Created by Paul Marc on 09.05.2022.
//

import Foundation

final class Cache {
    
    // MARK: - Load
    
    static func loadLights() -> [LightData]? {
        JSONCache.lights.loadFromFile()
    }
    
    static func loadGroups() -> [LightsGroup]? {
        JSONCache.groups.loadFromFile()
    }
    
    static func loadGroupsViewModels() -> [LightGroupViewModel] {
        let groups = loadGroups()
        var groupsViewModel: [LightGroupViewModel] = []
        
        groups?.forEach { group in
            let lights = group.lights.map { LightViewModel(data: $0) }
            groupsViewModel.append(LightGroupViewModel(groupData: group.groupData,
                                                       lightData: group.lightData,
                                                       lights: lights))
        }
        return groupsViewModel
    }
    
    static func loadScenes() -> [Scene] {
        JSONCache.scenes.loadFromFile() ?? []
    }
    
    // MARK: - Save
    
    static func save(_ scenes: [Scene]) {
        JSONCache.scenes.saveToFile(scenes)
    }
    
    static func save(_ lights: [LightData]) {
        JSONCache.lights.saveToFile(lights)
    }
    
    static func save(_ light: LightData) {
        var cachedLights = JSONCache.lights.loadFromFile()
        guard let index = cachedLights?.firstIndex(where: { $0.id == light.id }) else {
            cachedLights?.append(light)
            JSONCache.lights.saveToFile(cachedLights)
            return
        }
        cachedLights?[index] = light
        JSONCache.lights.saveToFile(cachedLights)
    }
    
    static func save(_ groups: [LightsGroup]) {
        JSONCache.groups.saveToFile(groups)
    }
    
    static func save(_ group: LightsGroup) {
        var cachedGroups = JSONCache.groups.loadFromFile()
        guard let index = cachedGroups?.firstIndex(where: { $0.groupData.id == group.groupData.id }) else {
            cachedGroups?.append(group)
            JSONCache.groups.saveToFile(cachedGroups)
            
            return
        }
        cachedGroups?[index] = group
        JSONCache.groups.saveToFile(cachedGroups)
    }
}
