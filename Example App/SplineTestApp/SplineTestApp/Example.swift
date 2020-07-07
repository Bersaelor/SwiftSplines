//
//  Example.swift
//  SplineTestApp
//
//  Created by Konrad Feiler on 07.07.20.
//  Copyright © 2020 Konrad Feiler. All rights reserved.
//

import Foundation

enum Example {
    case simpleFunction
    case curve2D
}

extension Example {
    var displayName: String {
        switch self {
        case .simpleFunction:
            return "Simple Function t -> y(t)"
        case .curve2D:
            return "Function t -> [x(t), y(t)]"
        }
    }
    
    var axis: [Axis] {
        switch self {
        case .simpleFunction:
            return [Axis(label: "t"), Axis(label: "y(t)")]
        case .curve2D:
            return [Axis(label: "x"), Axis(label: "y")]
        }
    }
    
    func pointName(for index: Int) -> String {
        switch self {
        case .simpleFunction:
            return "y_\(index)"
        case .curve2D:
            return "p_\(index)"
        }
    }
}
