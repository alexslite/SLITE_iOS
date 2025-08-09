//
//  ScrollViewHelper.swift
//  Slite
//
//  Created by Efraim Budusan on 08.02.2022.
//

import Foundation
import SwiftUI
import UIKit

class ScrollViewHelper {
    
    let containerId: String = UUID().uuidString
    
    var store: [String: CGRect] = [:]
    
    weak var scrollView: UIScrollView?
    
    var contentInset: UIEdgeInsets = .zero
    
    func reveal(item: String, offest: CGFloat = 0, orientation: ScrollOrientation = .vertical) {
        
        DispatchQueue.main.after(seconds: 0.3) {
            guard let rect = self.store[item] else {
                return
            }
            if orientation == .vertical {
                print("Perform \n")
                self.scrollView?.scrollVertically(toVisibleLocalRect: rect, offset: offest, contentInset: self.contentInset)
            } else {
                self.scrollView?.scrollHorizontally(toVisibleLocalRect: rect, offset: offest, contentInset: self.contentInset)
            }
        }
    }
    
    enum ScrollOrientation {
        case horizontal
        case vertical
    }

    
}

extension View {
    
    func scrollTarget(helper: ScrollViewHelper, id: String) -> some View {
        return self.readGeometry(coordinateSpace: .named(helper.containerId)) { data in
            helper.store[id] = data.relativeToCoordinateSpace
        }
    }
    
    func scrollContainer(helper: ScrollViewHelper) -> some View {
        return self.coordinateSpace(name: helper.containerId)
    }
}

struct ScrollViewWithHelper<Content: View>: View {
    
    let helper: ScrollViewHelper
    @ViewBuilder var content: () -> Content
    
    
    var body: some View {
        ScrollView {
            content()
                .scrollContainer(helper: helper)
        }.introspectScrollView { scrollView in
            helper.scrollView = scrollView
        }
    }
}


//struct ScrollTargetViewModifier: ViewModifier {
//
//    let id: String
//
//    @ViewBuilder
//    func body(content: Content) -> some View {
//        content
//            .background {
//                GeometryReader { proxy in
//                    Color.red
//                        .anchorPreference(key: ScrollTargetAnchorPreference.self, value: .topLeading) { anchor in
//                            return [ScrollTargetAnchorData(id: id, origin: anchor)]
//                        }
//                        .transformAnchorPreference(key: ScrollTargetAnchorPreference.self, value: .bounds) { (preference: inout [ScrollTargetAnchorData], anchor: Anchor<CGRect>) in
//                            preference[0].bounds = anchor
//                        }
//                }
//            }
//    }
//
//    struct ScrollTargetAnchorData {
//
//        let id: String
//        let origin: Anchor<CGPoint>
//        var bounds: Anchor<CGRect>? = nil
//
//    }
//
//    struct ScrollTargetAnchorPreference: PreferenceKey {
//        static var defaultValue: [ScrollTargetAnchorData] = []
//
//        static func reduce(value: inout [ScrollTargetAnchorData], nextValue: () -> [ScrollTargetAnchorData]) {
//            value.append(contentsOf: nextValue())
//        }
//    }
//
//}
