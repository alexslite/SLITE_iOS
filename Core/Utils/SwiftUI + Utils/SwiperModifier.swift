//
//  SwiperModifier.swift
//  Slite
//
//  Created by Efraim Budusan on 11.02.2022.
//

import Foundation
import SwiftUI
import UIKit
import SwiftUIX

extension View {
    
    func addSwipe<B: View>(state: Binding<SwipeState>, maxDragDistance: CGFloat, onTap: @escaping () -> Void, @ViewBuilder background: @escaping () -> B) -> some View {
        return self.modifier(SwipeModifier(swipeState: state, maxDragDistance: maxDragDistance, background: background))
    }
}


enum SwipeState: Equatable {
    case programatic(Bool)
    case dragged
    
    var toggle: SwipeState {
        switch self {
        case .programatic(let bool):
            guard bool else {
                return .programatic(true)
            }
            return .programatic(false)
        case .dragged:
            return .programatic(false)
        }
    }
}

struct SwipeModifier<B: View>: ViewModifier {

    @Binding var swipeState: SwipeState
    var maxDragDistance: CGFloat
    @ViewBuilder var background: () -> B
    
    @State var draggedDistance: CGFloat = 0
    
    @State var lastTranslation: CGFloat = 0
    
    var isHidden: Bool {
        switch swipeState {
        case .programatic(let bool):
            return !bool
        case .dragged:
            return draggedDistance == 0
        }
    }
    
    var offset: CGFloat {
        switch swipeState {
        case .programatic(let swipped):
            if swipped {
                return -maxDragDistance
            } else {
                return 0
            }
        case .dragged:
            return draggedDistance
        }
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: offset, y: 0)
//            .overlay({
//                ClearDragGestureView { value in
//                    swipeState = .dragged
//                    let dx = value.translation.width - lastTranslation
//                    draggedDistance = max(min(draggedDistance + dx, 0), -maxDragDistance)
//                    lastTranslation = value.translation.width
//                } onEnded: { value in
//                    withAnimation(.easeIn) {
//                        let dx = value.translation.width - lastTranslation + value.predictedEndTranslation.width * 0.3
//                        let newDraggedDistance = max(min(draggedDistance + dx, 0), -maxDragDistance)
//                        if newDraggedDistance < -(maxDragDistance / 2) {
//                            draggedDistance = -maxDragDistance
//                        } else {
//                            draggedDistance = 0
//                        }
//                    }
//                    lastTranslation = 0
//                }
//            })
            .gesture(dragGesture())
            .background {
                background()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.all, 1)
                    .hidden(isHidden)
            }
        
    }



    func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .local)
            .onChanged({ value in
                swipeState = .dragged
                let dx = value.translation.width - lastTranslation
                draggedDistance = max(min(draggedDistance + dx, 0), -maxDragDistance)
                lastTranslation = value.translation.width
            })
            .onEnded { value in
                withAnimation(.easeIn) {
                    let dx = value.predictedEndTranslation.width - lastTranslation
                    let newDraggedDistance = max(min(draggedDistance + dx, 0), -maxDragDistance)
                    
                    if newDraggedDistance < -(maxDragDistance / 2) {
                        draggedDistance = -maxDragDistance
                    } else {
                        swipeState = .programatic(false)
                        draggedDistance = 0
                    }
                }
                lastTranslation = 0
            }
            
     }
     
}
