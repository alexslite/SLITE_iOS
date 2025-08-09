//
// LightsViewModel.swift
// Slite
//
// Created by Efraim Budusan on 24.01.2022.
//
//

import Foundation
import Combine
import SwiftUIX

protocol MenuInpuState: AnyObject {
    var isGroupEnable: Bool { get }
    var isScenesEnable: Bool { get }
}

extension Lights {
    
    class ViewModel: ObservableObject, MenuInpuState, SceneSnapshotDataSource {
        // MARK: - Properties
        
        @Published var displaySceneCreationToast = false
        @Published var displayLightFailedToConnectToast = false
        var sliteNameForConnectionFailed: String = ""
        
        var isAnyDisconnectedLight: Bool {
            !lights.filter { $0.data.isDisconnected }.isEmpty || !groups.flatMap { $0.lights }.filter { $0.data.isDisconnected }.isEmpty
        }
        
        ///SceneSnapshotDataSource
        var lightsSnapshot: [LightSnapshot] {
            lights.filter { $0.data.state == .turnedOn }.map { $0.snapShot }
        }
        var groupsSnapshot: [GroupSnapshot] {
            groups.filter { $0.data.state == .turnedOn }.map { $0.groupSnapshot }
        }
        
        ///MenuInpuState
        var isGroupEnable: Bool {
            lights.count > 1
        }
        var isScenesEnable: Bool {
            (lights.count > 0 || groups.count > 0) && atleastOneLightIsOn
        }
        
        private var atleastOneLightIsOn: Bool {
            lights.first(where: { $0.data.state == .turnedOn }) != nil ||
            groups.first(where: { $0.data.state == .turnedOn }) != nil
        }
        
        @Published var isLoading: Bool = false
        @Published var lights: [LightViewModel]
        @Published var groups: [LightGroupViewModel]
        
        var shouldShowEmptyState: Bool {
            lights.isEmpty && groups.isEmpty
        }
        
        @Published var expandedItemIds: [String] = []
        @Published var expandedGroupItemsIds: [String] = []
        @Published var lightsSectionIsExpanded: Bool = true
        @Published var groupsSectionIsExpanded: Bool = true
        
        var onAddLight = PassthroughSubject<Void, Never>()
        var onLightDetails = PassthroughSubject<LightControlViewModel, Never>()
        let inputName = Delegated<String, PassthroughSubject<String, Never>>()
        var onRemoveLight = PassthroughSubject<LightData, Never>()
        var onTurnOff = PassthroughSubject<LightControlViewModel, Never>()
        var onTapOptions = PassthroughSubject<Void, Never>()
        
        let groupInputName = Delegated<String, PassthroughSubject<String, Never>>()
        var onRemoveGroup = PassthroughSubject<LightData, Never>()
        var onTapDisconnectedLight = PassthroughSubject<Void, Never>()
        
        let scrollHelper = ScrollViewHelper()
        var disposeBag = [AnyCancellable]()
        
        private var bleStateCallback: BluetoothStateCompletion?
        
        var lightIds: [String] {
            let singlelightsIDs = self.lights.map { $0.data.id }
            let groupedLightIds = self.groups.flatMap { $0.lights.map { $0.data.id } }
            
            return singlelightsIDs + groupedLightIds
        }
        
        // MARK: - Init
        
        init() {
            let lights = Cache.loadLights()
            self.lights = lights?.compactMap { LightViewModel(data: $0)} ?? []
            
            let groups = Cache.loadGroupsViewModels()
            self.groups = groups
            
            scrollHelper.contentInset = UIEdgeInsets.init(top: 68 + UIWindow.safeAreaPadding(from: .top), left: 0, bottom: 51 + UIWindow.safeAreaPadding(from: .bottom), right: 0)
            NotificationCenter.default.addObserver(self, selector: #selector(updateCachedLights), name: UIApplication.willResignActiveNotification, object: nil)
            
            setupBindings()
            updateCachedLights()
            
            initialiseBluetooth()
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        func showConnectionFailedToast(name: String) {
            sliteNameForConnectionFailed = name
            displayLightFailedToConnectToast = true
        }
        
        private func setupBindings() {
            // for switching light off from details screen
            onTurnOff.sink { [unowned self] light in
                self.turnLightOff(light)
            }.store(in: &disposeBag)
            
            lights.forEach { light in
                light.onStateChanged.sink { [unowned self] in
                    self.updateExpandedItemsIdFor(light)
                    self.objectWillChange.send()
                }.store(in: &disposeBag)
            }
            
            groups.forEach { group in
                group.lights.forEach {
                    $0.onStateChanged.sink { [unowned self] in
                        self.updateExpandedItemsIdFor(group)
                        self.objectWillChange.send()
                    }.store(in: &disposeBag)
                }
            }
        }
        
        private func updateExpandedItemsIdFor(_ light: LightViewModel) {
            if light.isDisconnectedOrTurnedOff {
                expandedItemIds.remove(object: light.data.id)
            }
        }
        
        private func updateExpandedItemsIdFor(_ group: LightGroupViewModel) {
            if group.isDisconnectedOrTurnedOff {
                expandedGroupItemsIds.remove(object: group.groupData.id)
            }
        }
        
        private func initialiseBluetooth() {
            guard !(lights.isEmpty && groups.isEmpty) else {
                return
            }
            
            BLEService.shared.initialiseBluetooth { [unowned self] state in
                if state == .poweredOn {
                    self.reconnectToAvailableLights(ids: lightIds)
                }
            }
        }
        
        private func setupBLEStateCallback() {
            BLEService.shared.bluetoothStateCompletion = { [unowned self] state in
                if state == .poweredOn {
                    self.reconnectToAvailableLights(ids: lightIds)
                }
            }
        }
        
        private func reconnectToAvailableLights(ids: [String]) {
            BLEService.shared.reconnectToPeripheralsWith(ids) { [weak self] disconnectedLightsIds in
                guard let self = self else { return }
                self.updateUnavailableLightsState(disconnectedLightsIds: disconnectedLightsIds)
                
                self.setupConnectionStateCallback()
                self.setupLightsInfoCallbacks(disconnectedLightsIds: disconnectedLightsIds)
            }
        }
        
        private func updateUnavailableLightsState(disconnectedLightsIds: [String]) {
            self.lights.filter { disconnectedLightsIds.contains($0.data.id) }.forEach {
                $0.data.state = .disconnected
            }
            self.groups.forEach {
                $0.checkForDisconnectedLights(unavailableLightIds: disconnectedLightsIds)
            }
        }
        
        private func setupLightsInfoCallbacks(disconnectedLightsIds: [String]) {
            self.groups.forEach {
                $0.setupLightInfoCallbackForLights()
            }
            self.lights.filter { !disconnectedLightsIds.contains($0.data.id) }.forEach {
                $0.setupLightInfoCallback()
            }
        }
        
        private func setupConnectionStateCallback() {
            self.groups.forEach {
                $0.setupConnectionStateCallbackForLights()
            }
            self.lights.filter { $0.data.state != .disconnected }.forEach {
                $0.setupConnectionStateCallback()
            }
        }
        
        // MARK: - Reconnect
        
        func reconnectToDisconnectedLights() {
            let singlelightsIDs = self.lights.filter { $0.data.state == .disconnected }.map { $0.data.id }
            let groupedLightIds = self.groups.flatMap { $0.lights.filter { $0.data.state == .disconnected }.map { $0.data.id } }
            
            reconnectToAvailableLights(ids: singlelightsIDs + groupedLightIds)
        }
        
        // MARK: - On / Off actions
        
        func showSceneCreationToast() {
            displaySceneCreationToast.toggle()
        }
        
        func turnOnAllLights() {
            lights.filter { !$0.data.isDisconnected }.forEach { $0.data.state = .turnedOn }
            updateCachedLights()
        }
        func turnOffAllLights() {
            lights.filter { !$0.data.isDisconnected }.forEach { $0.data.state = .turnedOff }
            updateCachedLights()
        }
        
        func turnOnAllLightsFromGroups() {
            groups.forEach { $0.data.state = .turnedOn; $0.lights.filter { !$0.data.isDisconnected }.forEach { $0.data.state = .turnedOn }}
            
            updateCachedLights()
        }
        func turnOffAllLigthsFromGroups() {
            groups.forEach { $0.data.state = .turnedOff; $0.lights.filter { !$0.data.isDisconnected }.forEach { $0.data.state = .turnedOff }}
            
            updateCachedLights()
        }
        func stateChangedFor(_ light: LightViewModel) {
            if light.data.state == .turnedOn {
                turnLightOn(light)
                Analytics.shared.trackEvent(.lightTurnedOn)
            } else if light.data.state == .turnedOff {
                turnLightOff(light)
                Analytics.shared.trackEvent(.lightTurnedOff)
            }
        }
        func statesChangedFor(_ group: LightGroupViewModel) {
            if group.data.state == .turnedOn {
                group.lights.filter { $0.data.isConnected }.forEach {
                    $0.data.state = .turnedOn
                    turnLightOn($0)
                }
                Analytics.shared.trackEvent(.groupTurnedOn)
            } else if group.data.state == .turnedOff {
                group.lights.filter { $0.data.isConnected }.forEach {
                    $0.data.state = .turnedOff
                    turnLightOff($0)
                }
                Analytics.shared.trackEvent(.groupTurnedOff)
            }
        }
        
        // MARK: - Add / Remove light
       
        func addNewLight(light: LightData) {
            var oldLights = lights
            if oldLights.isEmpty { setupBLEStateCallback() }
            
            if let existingLightViewModelIndex = lights.firstIndex(where: { $0.data.id == light.id }) {
                oldLights.remove(at: existingLightViewModelIndex)
            }
            
            let viewModel = LightViewModel(data: light)
            oldLights.append(viewModel)
            lights = ViewModel.orderedLights(lights: oldLights)
            setupNewLightBindings(viewModel: viewModel)
            
            updateCachedLights()
            
            Analytics.shared.trackEvent(.lightAddedSuccessfully)
        }
        private func setupNewLightBindings(viewModel: LightViewModel) {
            viewModel.setupLightInfoCallback()
            viewModel.setupConnectionStateCallback()
            viewModel.onStateChanged.sink { [unowned self] in
                self.objectWillChange.send()
            }.store(in: &disposeBag)
        }
        
        func removeLight(light: LightData) {
            if let index = lights.firstIndex(where: { $0.data.id == light.id }) {
                lights.remove(at: index)
            }
            updateCachedLights()
            BLEService.shared.removePeripheralWithId(light.id)
        }
        
        // MARK: - Create / Remove groups
        
        func createNewGroup(name: String, lights: [String]) {
            let groupedLights = self.lights.filter { lights.contains($0.data.id )}
            self.lights.removeAll(where: { lights.contains($0.data.id) })
            
            let viewModel = LightGroupViewModel(groupData: LightGroupData(id: UUID().uuidString, name: name), lightData: nil, lights: groupedLights)
            viewModel.writeDefaultValues()

            groups.append(viewModel)
            groups = ViewModel.orderedLights(lights: groups)
            
            updateCachedLights()
            Analytics.shared.trackEvent(.groupCreatedSuccessfully)
        }
        
        func removeGroup(group: LightGroupData) {
            if let index = groups.firstIndex(where: { $0.groupData.id == group.id }) {
                let groupLights = groups[index].lights
                
                EffectLooper.shared.stopEffect(lightId: group.id, shouldUpdate: false)
                groupLights.forEach {
                    EffectLooper.shared.startEffect($0.effect ?? .pulsing, lightId: $0.data.id)
                }
                
                groups.remove(at: index)
                appendUngroupedLights(ungroupLights: groupLights)
            }
            
            updateCachedLights()
        }
        
        func removeGroup(with lightData: LightData) {
            if let group = groups.first(where: { $0.data.id == lightData.id }) {
                removeGroup(group: group.groupData)
            }
            
            updateCachedLights()
        }
        
        private func appendUngroupedLights(ungroupLights: [LightViewModel]) {
            var oldLights = lights
            oldLights.append(contentsOf: ungroupLights)
            lights = ViewModel.orderedLights(lights: oldLights)
            
            updateCachedLights()
        }
        
        // MARK: - Name actions
        
        func nameAction(light: LightData) {
            (try? inputName.call(with: light.name))?.sink { [unowned self] name in
                lights.first(where: { $0.data.id == light.id })?.data.name = name
                lights = ViewModel.orderedLights(lights: lights)
                
                updateCachedLights()
            }.store(in: &disposeBag)
        }
        
        func groupNameAction(group: LightGroupData) {
            (try? groupInputName.call(with: group.name))?.sink { [unowned self] name in
                groups.first(where: { $0.groupData.id == group.id })?.groupData.name = name
                // TODO: check group "data" property
                groups.first(where: { $0.groupData.id == group.id })?.data.name = name
                groups = ViewModel.orderedLights(lights: groups)
                
                updateCachedLights()
            }.store(in: &disposeBag)
        }
        
        static private func orderedLights<T: LightControlViewModel>(lights: [T]) -> [T] {
            // on -> off -> disconnected (alphabetical)
            
            let connectedLights = lights.filter { !$0.data.isDisconnected }.sorted { $0.data.name < $1.data.name }
            let disconnectedLights = lights.filter { $0.data.isDisconnected }.sorted { $0.data.name < $1.data.name }
            
            return connectedLights + disconnectedLights
        }
        
        var lightsSectionTitle: String {
            return "Individual (\(lights.count))"
        }
        
        var groupsSectionTitle: String {
            return "Groups (\(groups.count))"
        }
        
        // MARK: - Cache
        
        @objc private func updateCachedLights() {
            Cache.save(lights.map { $0.data })
            Cache.save(groups.map { LightsGroup(groupData: $0.groupData, lightData: $0.data, lights: $0.lights.map {$0.data}) })
        }
        
        // MARK: - BT updates
        
        private func writeOutputFor(_ light: LightData) {
            BLEService.shared.writeLightOutput(data: light.dataOutput, lightId: light.id)
        }
        private func write(_ data: Data, forLightWith id: String) {
            BLEService.shared.writeLightOutput(data: data, lightId: id)
        }
        private func turnLightOff(_ light: LightControlViewModel) {
            expandedItemIds.remove(object: light.data.id)
            light.turnLightOff()
        }
        private func turnLightOn(_ light: LightControlViewModel) {
            light.turnLightOn()
        }
    }
}

// MARK: - ScenesActionsDelegate

extension Lights.ViewModel: ScenesActionsDelegate {
    func updateGroupWith(_ id: String, to mode: LightData.Mode, data: Data, effect: LightData.Effect?) {
        guard let group = groups.first(where: { $0.data.id == id } ), group.data.isConnected else { return }
        group.data.updateWith(data: data)
        group.turnLightOn()
        
        if mode == .effect, let effect = effect {
            group.updateToEffectsMode(shouldWrite: true)
            group.startEffect(effect)
        } else if mode == .color {
            group.updateToColorMode(shouldWrite: true)
            group.writeGroupLightData()
        } else if mode == .whiteWithTemperature {
            group.updateToWhiteColorMode(shouldWrite: true)
            group.writeGroupLightData()
        }
    }
    
    func updateLightWith(_ id: String, to mode: LightData.Mode, data: Data, effect: LightData.Effect?) {
        guard let light = lights.first(where: { $0.data.id == id }), light.data.isConnected else { return }
        light.turnLightOn()
        
        if mode == .effect, let effect = effect {
            light.updateToEffectsMode(shouldWrite: true)
            light.startEffect(effect)
        } else if mode == .color {
            light.updateToColorMode(shouldWrite: true)
            write(data, forLightWith: id)
        } else if mode == .whiteWithTemperature {
            light.updateToWhiteColorMode(shouldWrite: true)
            write(data, forLightWith: id)
        }
    }
}
