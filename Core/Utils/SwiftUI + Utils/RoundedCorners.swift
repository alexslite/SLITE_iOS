//
//  RoundedCorners.swift
//  Wellory
//
//  Created by Efraim Budusan on 4/1/21.
//  Copyright © 2021 Wellory. All rights reserved.
//

import Foundation
import SwiftUI


struct RoundedCornersShape: Shape {
    
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let w = rect.size.width
            let h = rect.size.height
            
            // Make sure we do not exceed the size of the rectangle
            let tr = min(min(self.tr, h/2), w/2)
            let tl = min(min(self.tl, h/2), w/2)
            let bl = min(min(self.bl, h/2), w/2)
            let br = min(min(self.br, h/2), w/2)
            
            path.move(to: CGPoint(x: w / 2.0, y: 0))
            path.addLine(to: CGPoint(x: w - tr, y: 0))
            path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
            path.addLine(to: CGPoint(x: w, y: h - br))
            path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
            path.addLine(to: CGPoint(x: bl, y: h))
            path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
            path.addLine(to: CGPoint(x: 0, y: tl))
            path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
            path.addLine(to: CGPoint(x: w / 2.0, y: 0))
        }
    }
    
    
}

struct RoundedCorners<Fill: ShapeStyle, Stroke: ShapeStyle>: View {

    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    var fill: Fill
    var stroke: Stroke
    var strokeStyle: StrokeStyle
    
    var body: some View {
        RoundedCornersShape(tl: tl, tr: tr, bl: bl, br: br)
        .fill(fill, stroke: stroke, strokeStyle: strokeStyle)
    }
    
    init(tl: CGFloat = 0.0,
         tr: CGFloat = 0.0,
         bl: CGFloat = 0.0,
         br: CGFloat = 0.0,
         fill: Fill) where Stroke == Color {
        self.tl = tl
        self.tr = tr
        self.bl = bl
        self.br = br
        self.fill = fill
        self.stroke = Color.clear
        self.strokeStyle = StrokeStyle(lineWidth: 0)
    }
    
    init(tl: CGFloat = 0.0,
         tr: CGFloat = 0.0,
         bl: CGFloat = 0.0,
         br: CGFloat = 0.0,
         stroke: Stroke,
         lineWidth: CGFloat) where Fill == Color {
        self.tl = tl
        self.tr = tr
        self.bl = bl
        self.br = br
        self.fill = Color.clear
        self.stroke = stroke
        self.strokeStyle = StrokeStyle(lineWidth: lineWidth)
    }
    
    init(tl: CGFloat = 0.0,
         tr: CGFloat = 0.0,
         bl: CGFloat = 0.0,
         br: CGFloat = 0.0,
         fill: Fill,
         stroke: Stroke,
         lineWidth: CGFloat) {
        self.tl = tl
        self.tr = tr
        self.bl = bl
        self.br = br
        self.fill = fill
        self.stroke = stroke
        self.strokeStyle = StrokeStyle(lineWidth: lineWidth)
    }
    
}


extension Shape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fill: Fill, stroke: Stroke, strokeStyle: StrokeStyle) -> some View {
        self
            .stroke(stroke, style: strokeStyle)
            .background(self.fill(fill))
    }
}

