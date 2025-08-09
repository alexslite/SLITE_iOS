//
// ScenesView.swift
// Slite
//
// Created by Efraim Budusan on 24.01.2022.
//
//

import Foundation
import SwiftUI
import SwiftUIX

struct Scenes {
    
    struct ContentView: View {
        
        @EnvironmentObject var viewModel: ViewModel
        
        var body: some View {
            contentView
            .overlay {
                Core.LargeTitleNavigationBar(title: "Scenes", showReconnect: false, showOptions: false) {
                    viewModel.checkAndSaveNewScene()
                } onRefresh: {
                    
                } onOptions: {
                    
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        
        var contentView: some View {
            VStack {
                if viewModel.scenes.isEmpty {
                    emptyStateView
                } else {
                    baseContent
                }
            }
            .popup(isPresented: $viewModel.showPopUp) {
                SaveScenePopUp()
            }
        }
        
        var baseContent: some View {
            ScrollView {
                scenesList
                    .scrollContainer(helper: viewModel.scrollHelper)
            }.introspectScrollView { scrollView in
                viewModel.scrollHelper.scrollView = scrollView
            }
        }
        
        var scenesList: some View {
            VStack(spacing: 16) {
                Color.primaryBackground
                    .frame(height: 68)
                ForEach(viewModel.scenes, id: \.id) { scene in
                    SceneControlItem.ContentView(scene: scene,
                                                 onRename: {
                        viewModel.nameAction(scene: scene)
                    },
                                                 onRemove: {
                        viewModel.onRemoveScene.send(scene)
                    }, onApply: {
                        viewModel.applySceneWith(id: scene.id)
                    })
                    .padding(.horizontal, 24)
                    .scrollTarget(helper: viewModel.scrollHelper, id: scene.id)
                }.transition(.identity)
            }
            .padding(.bottom, 70)
        }
        
        var emptyStateView: some View {
            VStack {
                Color.primaryBackground
                    .overlay {
                        Core.EmptyListPlaceholder(title: "No scene saved", subtitle: "Adjust your preferred light or group, then tap on the + to save scene.")
                    }
                    .padding(.horizontal, 48)
            }
        }
    }
}
