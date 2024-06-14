//
//  Tile.swift
//  Minesweeper-AR
//
//  Created by zjucvglab509 on 2024/6/14.
//

import RealityKit
import UIKit

fileprivate extension UIColor {
  func toMaterial(isMetallic: Bool = false) -> Material {
    return SimpleMaterial(color: self, isMetallic: isMetallic)
  }
}

class Tile: Entity, HasModel, HasCollision {
    let boxSize: SIMD3<Float> = [1, 0.2, 1]
    
    init(tile: TileData) {
        super.init()
        self.model = ModelComponent(mesh: .generateBox(size: boxSize), materials: [UIColor.gray.toMaterial()])
        self.collision = CollisionComponent(shapes: [.generateBox(size: boxSize)])
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
