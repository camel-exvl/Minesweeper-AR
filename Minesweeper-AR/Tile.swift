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
    var tile: TileData
    
    init(tile: TileData) {
        self.tile = tile
        super.init()
        render()
    }
    
    func render() {
        self.children.removeAll()
        
        let grayMaterial = UIColor.gray.toMaterial()
        if tile.isFlagged {
            let flag = try! TextureResource.load(named: "flag.png")
            var imageMaterial = PhysicallyBasedMaterial()
            imageMaterial.baseColor = .init(texture: .init(flag))
            // set alpha transparent https://stackoverflow.com/questions/63505133/realitykit-materials-alpha-transparency
            imageMaterial.blending = .init(blending: .transparent(opacity: 0.9999))
            imageMaterial.opacityThreshold = 0.0
            
            let topFaceMesh = MeshResource.generatePlane(width: 1, height: 1)
            let topFaceEntity = ModelEntity(mesh: topFaceMesh, materials: [imageMaterial])
            topFaceEntity.orientation = simd_quatf(angle: 3 * .pi / 2, axis: [1, 0, 0])
            topFaceEntity.position.y = 0.101
            
            self.addChild(topFaceEntity)
        }
        
        let boxMesh = MeshResource.generateBox(size: boxSize)
        let boxEntity = ModelEntity(mesh: boxMesh, materials: [grayMaterial])
        
        self.addChild(boxEntity)
        
        self.collision = CollisionComponent(shapes: [.generateBox(size: boxSize)])
    }
    
    func flag() {
        self.tile.isFlagged.toggle()
        render()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
