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
    let pos: SIMD2<Int>
    var finished: Bool
    var win: Bool = false
    var tile: TileData
    
    init(pos: SIMD2<Int>, tile: TileData, finished: Bool) {
        self.pos = pos
        self.finished = finished
        self.tile = tile
        super.init()
        render()
    }
    
    private func render() {
        self.children.removeAll()
        
        let grayMaterial = UIColor.gray.toMaterial()
        
        if tile.isFlagged || (finished && win && tile.isMine) {
            let flag = try! TextureResource.load(named: finished && !tile.isMine ? "mine_error.png" : "flag.png")
            renderTopFace(texture: flag)
        } else if tile.isMine && (tile.isRevealed || finished) {
            let mine = try! TextureResource.load(named: tile.isRevealed ? "mine_red.png" : "mine.png")
            renderTopFace(texture: mine)
        } else if !tile.isMine && tile.isRevealed {
            if tile.minesAround == 0 {
                return
            }
            let number = try! TextureResource.load(named: "\(tile.minesAround).png")
            renderTopFace(texture: number)
        }
        
        let boxMesh = MeshResource.generateBox(size: boxSize)
        let boxEntity = ModelEntity(mesh: boxMesh, materials: [grayMaterial])
        
        self.addChild(boxEntity)
        
        self.collision = CollisionComponent(shapes: [.generateBox(size: boxSize)])
    }
    
    private func renderTopFace(texture: TextureResource) {
        var imageMaterial = PhysicallyBasedMaterial()
        imageMaterial.baseColor = .init(texture: .init(texture))
        // set alpha transparent https://stackoverflow.com/questions/63505133/realitykit-materials-alpha-transparency
        imageMaterial.blending = .init(blending: .transparent(opacity: 0.9999))
        imageMaterial.opacityThreshold = 0.0
        
        let topFaceMesh = MeshResource.generatePlane(width: 1, height: 1)
        let topFaceEntity = ModelEntity(mesh: topFaceMesh, materials: [imageMaterial])
        topFaceEntity.orientation = simd_quatf(angle: 3 * .pi / 2, axis: [1, 0, 0])
        topFaceEntity.position.y = 0.101
        
        self.addChild(topFaceEntity)
    }
    
    func reveal() -> (Int, Bool) {
        tile.isRevealed = true
        render()
        var cnt = (tile.isMine ? 0 : 1, tile.isMine)
        if tile.minesAround == 0 && !tile.isMine {
            let res = (self.parent as! Grid).revealNeighbors(of: self)
            cnt.0 += res.0
            cnt.1 = cnt.1 || res.1
        }
        return cnt;
    }
    
    func longPress() {
        self.tile.isFlagged.toggle()
        render()
    }
    
    func finish(win: Bool) {
        self.finished = true
        self.win = win
        render()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
