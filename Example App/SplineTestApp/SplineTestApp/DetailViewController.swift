//
//  DetailViewController.swift
//  SplineTestApp
//
//  Created by Konrad Feiler on 07.07.20.
//  Copyright © 2020 Konrad Feiler. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var graphView: GraphView!
    
    var detailItem: Example = .simpleFunction
    
    var tappedPoints: [CGPoint] = [] {
        didSet {
            configureView()
        }
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
        graphView.points = tappedPoints.enumerated().map({ value in
            return (detailItem.pointName(for: value.offset), value.element)
        })
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        let location = sender.location(in: graphView)
        guard graphView.frame.contains(location) else { return }
        let size = graphView.bounds.size
        tappedPoints.append(CGPoint(x: location.x / size.width, y: location.y / size.height))
    }
}

