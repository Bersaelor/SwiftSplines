
import Foundation

extension Spline {
    
    static func computeCoefficients(from points: [P], d: [P]) -> [CubicPoly] {
        return points.indices.dropLast().map { (index) -> CubicPoly in
            let p0 = points[index]
            let p1 = points[index.advanced(by: 1)]
            let d0 = d[index]
            let d1 = d[index.advanced(by: 1)]
            return CubicPoly(
                a: p0,
                b: d0,
                c: 3*(p1 - p0) - 2*d0 - d1,
                d: 2*(p0 - p1) + d0 + d1
            )
        }
    }
    
    static func computeDerivatives(
        from points: [P],
        boundaryCondition: BoundaryCondition = .smooth
    ) -> [P] {
        
        
        return points
    }
}
