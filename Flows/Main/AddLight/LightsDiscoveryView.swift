//
//  LightsDiscoveryView.swift
//  Slite
//
//  Created by Paul Marc on 14.03.2022.
//

import Foundation
import SwiftUI
import CoreBluetooth

struct LightsDiscoveryView: View {
    
    @EnvironmentObject var viewModel: LightsDiscoveryViewModel
    
    var body: some View {
        if viewModel.lightIsSettingUp {
            settingUpView
        } else if viewModel.lightWasAddedSuccesfully {
            doneView
        } else if viewModel.hasDiscoveredAnyLights {
            discoveredLightsList
        } else if viewModel.discoveryFailed {
            discoveryFailedView
        } else {
            blDiscoveryAnimation
        }
    }
    
    var doneView: some View {
        VStack(alignment: .center) {
            ZStack(alignment: .center) {
                Circle()
                    .fill(Color.tartRed)
                    .frame(width: 56, height: 56)
                Image("checkmark_big")
            }
            Text(Texts.Core.done)
                .foregroundColor(.white)
                .padding(.top, 37)
                .font(Font.Main.regular(size: 19))
        }
    }
    
    var settingUpView: some View {
        VStack(alignment: .center) {
            SettingUpAnimationView()
                .frame(.init(width: 52, height: 52))
            Text(Texts.Discovery.settingUpSliteTitle).foregroundColor(.white)
                .padding(.top, 40)
                .font(.Main.regular(size: 15))
        }
    }
    
    var discoveryFailedView: some View {
        ZStack(alignment: .center) {
            VStack {
                Image("no_device")
                    .padding(.bottom, 37)
                Text(Texts.Discovery.discoveryFailedText)
                    .font(Font.Main.regular(size: 15))
                    .foregroundColor(Color.sonicSilver)
            }
            Buttons.FilledRoundedButton(title: Texts.Discovery.tryAgainButtonTitle) {
                viewModel.retryDiscovery()
            }
            .padding([.horizontal, .bottom], 24)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
    
    var discoveredLightsList: some View {
        VStack {
            ForEach(viewModel.discoveredPeripherals) { slite in
                LightView(lightTitle: slite.data.name) {
                    viewModel.nameAction(slite: slite)
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
         .padding(.all, 24)
         .listStyle(.automatic)
    }
    
    var blDiscoveryAnimation: some View {
        VStack {
            ZStack(alignment: .center) {
                DiscoveryAnimationView()
                    .frame(.init(width: 200, height: 200))
                Image("lights_BL")
            }
            Text(Texts.Discovery.discoverySearchingText).foregroundColor(.white)
                .font(.Main.regular(size: 15))
        }
    }
}
