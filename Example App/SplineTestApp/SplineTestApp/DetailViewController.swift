//
//  DetailViewController.swift
//  SplineTestApp
//
//  Created by Konrad Feiler on 07.07.20.
//  Copyright © 2020 Konrad Feiler. All rights reserved.
//

import SwiftSplines
import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var graphView: GraphView!
    
    var detailItem: Example = .simpleFunction
    
    private var tappedPoints: [CGPoint] = [] {
        didSet {
            graphView.points = tappedPoints.enumerated().map({ value in
                return (detailItem.pointName(for: value.offset), value.element)
            })
            updateSpline()
        }
    }
    
    private var linePoints: [CGPoint] = [] {
        didSet { graphView.linePoints = linePoints }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()

        let tapGR = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        view.addGestureRecognizer(tapGR)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureView()
    }
    
    private func configureView() {
        title = detailItem.displayName

        graphView.axis = detailItem.axis

    }
    
    private func updateSpline() {
        // TODO add the 2D case
        guard tappedPoints.count > 0 else { return }
        let arguments = tappedPoints.map({ Double($0.x) })
        let values = tappedPoints.map({ Double($0.y) })
        
        let function: (Double) -> Double
        if arguments.count > 1 {
            let spline = Spline(values: values, arguments: arguments)
            function = spline.f(t:)
        } else {
            function = { _ in return values[0] }
        }
        
        let resolution = 5000
        linePoints = (0 ..< resolution).map({ (offset) -> CGPoint in
            let argument = Double(offset)/Double(resolution)
            return CGPoint(x: argument, y: function(argument))
        })
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        let location = sender.location(in: graphView)
        guard graphView.frame.contains(location) else { return }
        let size = graphView.bounds.size
        let newPoint = CGPoint(x: location.x / size.width, y: location.y / size.height)
        
        switch detailItem {
        case .simpleFunction:
            if !tappedPoints.isEmpty && newPoint.x < tappedPoints[0].x {
                tappedPoints.insert(newPoint, at: 0)
            } else if let smallerIndex = tappedPoints.enumerated().first(where: {
                $0.element.x <= newPoint.x
                    && $0.offset+1 < tappedPoints.endIndex
                    && newPoint.x < tappedPoints[$0.offset+1].x
            }) {
                tappedPoints.insert(newPoint, at: smallerIndex.offset + 1)
            } else {
                tappedPoints.append(newPoint)
            }
        case .curve2D:
            tappedPoints.append(newPoint)
        }
    }
}

