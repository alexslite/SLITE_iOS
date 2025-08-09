//
//  ChildSizeReader.swift
//  MyLegends
//
//  Created by Efraim Budusan on 8/6/20.
//

import Foundation
import SwiftUI

struct ChildSizeReader<Content: View>: View {
    @Binding var size: CGSize
    let content: () -> Content
    var body: some View {
        ZStack {
            content()
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: SizePreferenceKey.self, value: proxy.size)
                    }
                )
        }
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            self.size = preferences
        }
    }
}


extension View {
    func readGlobalFrame(_ callback: @escaping (CGRect) -> ()) -> some View {
        return self.modifier(GlobalFrameReaderModifier(onFrameChange: callback))
    }
}

struct GlobalFrameReaderModifier: ViewModifier {

    let onFrameChange: (CGRect) -> ()
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .background(
                    GeometryReader { proxy in
                        let frame = proxy.frame(in:.global)
                        Color.clear
                            .edgesIgnoringSafeArea(.all)
                            .preference(key: FramePreferenceKey.self, value: frame)
                    }
                )
        }
        .onPreferenceChange(FramePreferenceKey.self) { preferences in
            if let value = preferences {
                self.onFrameChange(value)
            }
        }
    }
}

extension View {
    func readGeometry(coordinateSpace: CoordinateSpace? = nil, _ callback: @escaping (GeometryProxyData) -> ()) -> some View {
        return self.modifier(GeometryReaderModifier(coordinateSpace: coordinateSpace, onDataChange: callback))
    }
}


struct GeometryProxyData: Equatable {
    
    let localFrame:CGRect
    let globalFrame:CGRect
    var relativeToCoordinateSpace: CGRect? = nil
    
}

struct GeometryReaderModifier: ViewModifier {
    
    var coordinateSpace: CoordinateSpace? = nil
    let onDataChange: (GeometryProxyData) -> ()
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .background(
                    GeometryReader { proxy in
                        let localFrame = proxy.frame(in:.local)
                        let globalFrame = proxy.frame(in:.global)
                        let relativeToCoordinateSpace: CGRect? = {
                            if let coordinateSpace = self.coordinateSpace {
                                return proxy.frame(in: coordinateSpace)
                            }
                            return nil
                        }()
                        let data = GeometryProxyData(localFrame: localFrame, globalFrame: globalFrame, relativeToCoordinateSpace: relativeToCoordinateSpace)
                        Color.clear
                            .preference(key: GeometryProxyDataPreferenceKey.self, value: data)
                    }
                )
        }
        .onPreferenceChange(GeometryProxyDataPreferenceKey.self) { preferences in
            if let value = preferences {
                self.onDataChange(value)
            }
        }
    }
}


struct GeometryProxyDataPreferenceKey: PreferenceKey {
    typealias Value = GeometryProxyData?
    static var defaultValue: Value = nil
    
    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}

struct FramePreferenceKey: PreferenceKey {
    typealias Value = CGRect?
    static var defaultValue: Value = nil
    
    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}

struct GeometryProxyPreferenceKey: PreferenceKey {
    typealias Value = GeometryProxy?
    static var defaultValue: Value = nil
    
    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}



struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: Value = .zero
    
    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}
