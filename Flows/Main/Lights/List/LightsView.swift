//
// LightsView.swift
// Slite
//
// Created by Efraim Budusan on 24.01.2022.
//
//

import Foundation
import SwiftUI
import SwiftUIX

struct Lights {
    
    struct ContentView: View {
        
        @EnvironmentObject var viewModel: ViewModel
        let refreshButtonHelper: ButtonStateHelper
        
        var body: some View {
            contentView
            .overlay {
                Core.LargeTitleNavigationBar(title: "Lights", showReconnect: viewModel.isAnyDisconnectedLight, showOptions: true, onAdd: {
                    viewModel.onAddLight.send()
                }, onRefresh: {
                    viewModel.reconnectToDisconnectedLights()
                }, onOptions: {
                    viewModel.onTapOptions.send()
                })
                .environmentObject(refreshButtonHelper)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .toast(message: Texts.Toast.sceneCreated, isShowing: $viewModel.displaySceneCreationToast, duration: 2)
            .toast(message: Texts.Toast.connectionFailedMessage(deviceName: viewModel.sliteNameForConnectionFailed), isShowing: $viewModel.displayLightFailedToConnectToast, config: .init(backgroundColor: .coral, duration: 4))
        }
        
        @ViewBuilder
        var contentView: some View {
            if viewModel.shouldShowEmptyState {
                placeholderView
            } else {
                ScrollView {
                    lightList
                        .scrollContainer(helper: viewModel.scrollHelper)
                }.introspectScrollView { scrollView in
                    viewModel.scrollHelper.scrollView = scrollView
                }
            }
        }

        var placeholderView: some View {
            Color.primaryBackground
                .overlay {
                    Core.EmptyListPlaceholder(title: "No lights", subtitle: "Tap on + to add new lights or create groups of lights")
                }
                .padding(.horizontal, 48)
        }
        
        var lightList: some View {
            VStack(spacing: 16) {
                Color.primaryBackground
                    .frame(height: 68)
                if !viewModel.lights.isEmpty {
                ListHeaderView(title: viewModel.lightsSectionTitle, isExpanded: viewModel.lightsSectionIsExpanded) {

                }
                if viewModel.lightsSectionIsExpanded {
                    ForEach(viewModel.lights, id: \.data.id) { light in
                        LightControlItem.ContentView(viewModel: .init(light),
                                                     isExpanded: isExpaned(light.data.id),
                                                     backgroundColor: .secondaryBackground,
                                                     onShowSettings: {
                            viewModel.onLightDetails.send(light)
                        }, onRename: {
                            viewModel.nameAction(light: light.data)
                        }, onRemove: {
                            viewModel.onRemoveLight.send(light.data)
                        }, onTapDisconnectedLight: {
                            viewModel.onTapDisconnectedLight.send()
                        }, onStateChanged: {
                            viewModel.stateChangedFor(light)
                        })
                        .padding(.horizontal, 24)
                        .scrollTarget(helper: viewModel.scrollHelper, id: light.data.id)
                    }
                    .transition(.opacity)
                } else {
                    SectionControlView(turnOffAction: {
                        viewModel.turnOffAllLights()
                    }, turnOnAction: {
                        viewModel.turnOnAllLights()
                    })
                    .transition(.opacity)
                }
                }
                if !viewModel.groups.isEmpty {
                    ListHeaderView(title: viewModel.groupsSectionTitle, isExpanded: viewModel.groupsSectionIsExpanded) {

                    }
                    if viewModel.groupsSectionIsExpanded {
                        ForEach(viewModel.groups, id: \.groupData.id) { group in
                            LightControlItem.ContentView(viewModel: .init(group),
                                                         isExpanded: isGroupExpanded(group.groupData.id),
                                                         backgroundColor: .secondaryBackground,
                                                         onShowSettings: { viewModel.onLightDetails.send(group) },
                                                         onRename: { viewModel.groupNameAction(group: group.groupData) },
                                                         onRemove: { viewModel.onRemoveGroup.send(group.data) },
                                                         onTapDisconnectedLight: {
                                viewModel.onTapDisconnectedLight.send()
                            }, onStateChanged: { viewModel.statesChangedFor(group)})
                            .padding(.horizontal, 24)
                            .scrollTarget(helper: viewModel.scrollHelper, id: group.groupData.id)
                        }
                        .transition(.opacity)
                    } else {
                        SectionControlView(turnOffAction: {
                            viewModel.turnOffAllLigthsFromGroups()
                        }, turnOnAction: {
                            viewModel.turnOnAllLightsFromGroups()
                        })
                        .transition(.opacity)
                    }
                }
                Color.primaryBackground
                    .frame(height: 51)
            }
        }
        
        func isGroupExpanded(_ itemId: String) -> Binding<Bool> {
            .init {
                return viewModel.expandedGroupItemsIds.contains(itemId)
            } set: { expaned in
                if expaned {
                    self.viewModel.expandedGroupItemsIds.append(itemId)
                    viewModel.scrollHelper.reveal(item: itemId)
                } else {
                    self.viewModel.expandedGroupItemsIds.remove(object: itemId)
                }
            }
        }
        
        func isExpaned(_ itemId: String) -> Binding<Bool>{
            .init {
                return viewModel.expandedItemIds.contains(itemId)
            } set: { expaned in
                if expaned {
                    self.viewModel.expandedItemIds.append(itemId)
                    viewModel.scrollHelper.reveal(item: itemId)
                } else {
                    self.viewModel.expandedItemIds.remove(object: itemId)
                }
            }
        }
    }
}
