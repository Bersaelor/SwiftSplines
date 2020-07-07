//
//  GraphView.swift
//  SplineTestApp
//
//  Created by Konrad Feiler on 07.07.20.
//  Copyright © 2020 Konrad Feiler. All rights reserved.
//

import UIKit

struct Axis: Equatable {
    let label: String
}

class GraphView: UIView {
    
    var axis: [Axis] = [] {
        didSet {
            guard oldValue != axis else { return }
            setNeedsDisplay()
        }
    }
    
    var points: [(String, CGPoint)] = []
    
    var linePoints: [CGPoint] = [] {
        didSet { setNeedsDisplay() }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setNeedsDisplay()
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code

        guard let context = UIGraphicsGetCurrentContext() else { return }
        let size = bounds.size

        draw(axis: axis, in: context, size: size)
        
        draw(points: points, in: context, size: size)

        let cooSize = CGSize(
            width: size.width - 2 * border,
            height: size.height - 2 * border
        )
        let scaledPoints = linePoints.map {
            return CGPoint(
                x: border + $0.x * cooSize.width,
                y: border + $0.y * cooSize.height)
        }
        drawLine(points: scaledPoints, in: context)
    }
    
    private var border: CGFloat {
        return layoutMargins.left
    }
    
    func draw(axis: [Axis], in context: CGContext, size: CGSize) {
        guard axis.count == 2 else {
            print("Warning: Expected 2 axis")
            return
        }
        let axisColor = UIColor.gray
        axisColor.setStroke()
        
        let textAttributes = [
            NSAttributedString.Key.foregroundColor: axisColor,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)
        ]

        let bottomLeft = CGPoint(x: border, y: size.height - border)
        
        // draw horizontal axis
        let bottomRight = CGPoint(x: size.width - border, y: size.height - border)
        context.move(to: bottomLeft)
        context.addLine(to: bottomRight)
        context.setLineWidth(1.0)
        context.strokePath()
        
        (axis[0].label as NSString).draw(
            at: CGPoint(x: bottomRight.x - 12, y: bottomRight.y - 20),
            withAttributes: textAttributes)
        
        // draw vertical axis
        let topLeft = CGPoint(x: border, y: border)
        context.move(to: bottomLeft)
        context.addLine(to: topLeft)
        context.setLineWidth(1.0)
        context.strokePath()
        
        (axis[1].label as NSString).draw(
            at: CGPoint(x: topLeft.x + 4, y: topLeft.y),
            withAttributes: textAttributes)
    }

    func draw(points: [(String, CGPoint)], in context: CGContext, size: CGSize) {
        let radius: CGFloat = 3
        
        let pointColor = UIColor.purple
        pointColor.setStroke()
        
        let textAttributes = [
            NSAttributedString.Key.foregroundColor: pointColor,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)
        ]
        
        for point in points {
            let origin = CGPoint(
                x: point.1.x * size.width - radius,
                y: point.1.y * size.height - radius
            )
            
            let ellipse = CGRect(
                origin: origin,
                size: CGSize(width: 2*radius, height: 2*radius)
            )
            context.strokeEllipse(in: ellipse)
            
            (point.0 as NSString).draw(
                at: CGPoint(x: origin.x + 2, y: origin.y + 2),
                withAttributes: textAttributes)
        }
    }
    
    func drawLine(points: [CGPoint], in context: CGContext) {
        guard !points.isEmpty else { return }

        let lineColor = UIColor.systemTeal
        lineColor.setStroke()

        context.move(to: points[0])
        
        for point in points.dropFirst() {
            context.addLine(to: point)
        }
        context.setLineWidth(1.0)
        context.strokePath()
    }

}
