//
//  FirmwareUpdate.swift
//  Slite
//
//  Created by Paul Marc on 12.07.2023.
//

import Foundation
import SwiftUI
import SwiftUIX
import Combine

struct FirmwareUpdate {
    
    class SliteUpdateViewModel: Identifiable, ObservableObject, FirmwareUpdateDelegate {
        
        var progressString: String {
            "\(progress) %"
        }
        
        var isLatestVersion: Bool {
            version == latestSwVersion
        }
        
        var id: String
        @Published var version: String
        @Published var name: String
        @Published var inProgress: Bool
        @Published var progress: Int = 0
        
        private var connectionHandler: SliteConnectionHandler?
        
        init(id: String, version: String, name: String, inProgress: Bool) {
            self.id = id
            self.version = version
            self.name = name
            self.inProgress = inProgress
            
            BLEService.shared.setFirmwareUpdateDelegate(self, for: id)
        }
        
        func connectionHandler(_ handler: SliteConnectionHandler, didStartedFirmwareUpdateFor peripheralId: String) {
            // Retain strong references to handler while updating firmware.
            connectionHandler = handler
            inProgress = true
        }
        
        func connectionHandler(_ handler: SliteConnectionHandler, didFinishedFirmwareUpdateFor peripheralId: String) {
            // Release reference to handler after update completes.
            connectionHandler = nil
            inProgress = false
        }
        
        func connectionHandler(_ handler: SliteConnectionHandler, didUpdateUploadProgressWith progress: Int) {
            
            self.progress = progress
        }

        func updateButtonTapped() {
            guard !isLatestVersion && !inProgress
            else { return }
            BLEService.shared.startFWUpdateForPeripheralWith(id)
        }

    }
    
    class ViewModel: ObservableObject {
        
        @Published var lights: [SliteUpdateViewModel] = []
        var disposeBag = [AnyCancellable]()
        
        init() {
            let models = BLEService.shared.getFirmwareStatusForConnectedLights()
            let cachedLights = Cache.loadLights()
            
            lights = models.map { status in SliteUpdateViewModel(id: status.id, version: status.version, name: cachedLights?.first(where: { $0.id == status.id })?.name ?? "", inProgress: status.inProgress)}
            
            BLEService.shared.onPeripheralDisconnected.sink { [weak self] identifier in
                self?.lights.removeAll(where: { $0.id == identifier && !$0.inProgress })
            }.store(in: &disposeBag)
        }
    }
    
    struct ContentView: View {
        
        @EnvironmentObject var viewModel: ViewModel
        
        var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.lights, id: \.id) {
                        ItemView(viewModel: $0)
                            .padding(.horizontal, 24)
                    }
                }
            }
            .padding(.top, 24)
        }
    }
    
    struct ItemView: View {
        
        @StateObject var viewModel: SliteUpdateViewModel
        
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(viewModel.name)
                        .font(Font.Main.bold(size: 19))
                    Text("Firmware version \(viewModel.version)")
                        .font(Font.Main.regular(size: 13))
                }
                
                Spacer()
                
                Button {
                    // #FIXME: Replace the button rather than changing its label.
                    viewModel.updateButtonTapped()
                } label: {
                    if viewModel.isLatestVersion {
                        Text("Latest version installed")
                            .foregroundColor(.sonicSilver)
                            .font(Font.Main.regular(size: 13))
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 83)
                    } else {
                        ZStack {
                            if viewModel.inProgress {
                                Text(viewModel.progressString)
                                    .foregroundColor(.white)
                                    .font(Font.Main.regular(size: 15))
                            } else {
                                Color.tartRed
                                    .cornerRadius(3)
                                Text("Update")
                                    .foregroundColor(.white)
                                    .font(Font.Main.regular(size: 15))
                                    .padding(.vertical, 13)
                                    .padding(.horizontal, 5)
                            }
                        }
                        .frame(width: 75, height: 48)
                    }
                }
            }
            .padding(.all, 16)
            .background(.eerieBlack)
            .cornerRadius(5)
        }
    }
    
    class ViewController: UIHostingController<AnyView> {
        // MARK: - Properties
        
        var disposeBag = [AnyCancellable]()
        
        // MARK: - Init
        
        init() {
            
            super.init(rootView: ContentView().environmentObject(ViewModel()).eraseToAnyView())

            let label = UILabel()
            label.font = UIFont.Main.bold(size: 19)
            label.adjustsFontForContentSizeCategory = false
            label.text = Texts.FirmwareUpdate.navigationTitle
            navigationItem.titleView = label
        }
        
        @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Lifecycle
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setupNavigationBar()
        }
        
        // MARK: - Navigation Bar setup
        
        private func setupNavigationBar() {
            navigationController?.setNavigationBarHidden(false, animated: false)
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .clear
            appearance.titleTextAttributes = [.font: UIFont.Main.bold(size: 19)]
            appearance.shadowColor = .clear
            appearance.largeTitleTextAttributes = [.font: UIFont.Main.bold(size: 19)]
            
            navigationController?.navigationBar.tintColor = .white
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
}
