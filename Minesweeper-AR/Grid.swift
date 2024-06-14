//
//  Grid.swift
//  Minesweeper-AR
//
//  Created by zjucvglab509 on 2024/6/14.
//

import RealityKit

class Grid: Entity, HasModel, HasAnchoring {
    let data: [[TileData]]
    // set bounds and scale
    var minimumBounds: SIMD2<Float>? = nil {
      didSet {
        guard let bounds = minimumBounds else {
          return
        }
        let anchorPlane = AnchoringComponent.Target.plane(
          .horizontal,
          classification: .any,
          minimumBounds: bounds)
        let anchorComponent = AnchoringComponent(anchorPlane)

        self.anchoring = anchorComponent

        let maxDim = max(data.count, data[0].count)
        let minBound = bounds.min()
        self.scale = SIMD3<Float>(repeating: minBound / Float(maxDim))
      }
    }
    
    init(data: [[TileData]]) {
        self.data = data
        super.init()
        for i in 0..<data.count {
            for j in 0..<data[i].count {
                let tile = Tile(tile: data[i][j])
                tile.scale = [0.9, 0.9, 0.9]
                tile.position = [Float(j) - Float(data[i].count - 1) / 2, 0, Float(i) - Float(data.count - 1) / 2]
                self.addChild(tile)
            }
        }
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
