//
//  Grid.swift
//  Minesweeper-AR
//
//  Created by zjucvglab509 on 2024/6/14.
//

import RealityKit

class Grid: Entity, HasModel, HasAnchoring {
    let viewModel: ViewModel
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
    
    private func getTile(x: Int, y: Int) -> Tile {
        return self.children[(x * data[0].count) + y] as! Tile
    }
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self.data = viewModel.tiles
        super.init()
        self.children.removeAll()
        for i in 0..<data.count {
            for j in 0..<data[i].count {
                let tile = Tile(pos: SIMD2(i, j), tile: data[i][j], finished: false)
                tile.scale = [0.9, 0.9, 0.9]
                tile.position = [Float(j) - Float(data[i].count - 1) / 2, 0, Float(i) - Float(data.count - 1) / 2]
                self.addChild(tile)
            }
        }
    }
    
    func revealNeighbors(of tile: Tile) -> (Int, Bool) {
        let x = tile.pos.x
        let y = tile.pos.y
        var cnt = (0, false)
        for i in -1...1 {
            for j in -1...1 {
                let newX = x + i
                let newY = y + j
                if newX < 0 || newX >= data.count || newY < 0 || newY >= data[0].count {
                    continue
                }
                let neighbor = getTile(x: newX, y: newY)
                if !neighbor.tile.isRevealed && !neighbor.tile.isFlagged {
                    let res = neighbor.reveal()
                    cnt.0 += res.0
                    cnt.1 = cnt.1 || res.1
                }
            }
        }
        return cnt;
    }
    
    func safeNeighbors(of tile: Tile) -> (Int, Bool) {
        let x = tile.pos.x
        let y = tile.pos.y
        var cnt = 0
        for i in -1...1 {
            for j in -1...1 {
                let newX = x + i
                let newY = y + j
                if newX < 0 || newX >= data.count || newY < 0 || newY >= data[0].count {
                    continue
                }
                cnt += getTile(x: newX, y: newY).tile.isFlagged ? 1 : 0
            }
        }
        if cnt == tile.tile.minesAround {
            var ret = (0, false)
            // reveal all neighbors
            for i in -1...1 {
                for j in -1...1 {
                    let newX = x + i
                    let newY = y + j
                    if newX < 0 || newX >= data.count || newY < 0 || newY >= data[0].count {
                        continue
                    }
                    let neighbor = getTile(x: newX, y: newY)
                    if !neighbor.tile.isRevealed && !neighbor.tile.isFlagged {
                        let res = neighbor.reveal()
                        ret.0 += res.0
                        ret.1 = ret.1 || res.1
                    }
                }
            }
            return ret
        }
        return (0, false)
    }
    
    func generateAnotherMine(pos: SIMD2<Int>) {
        // cancel the mine at the pos
        getTile(x: pos.x, y: pos.y).tile.isMine = false
        for i in -1...1 {
            for j in -1...1 {
                if i == 0 && j == 0 {
                    continue
                }
                let newX = pos.x + i
                let newY = pos.y + j
                if newX >= 0 && newX < data.count && newY >= 0 && newY < data[0].count {
                    getTile(x: newX, y: newY).tile.minesAround -= 1
                }
            }
        }
        
        // generate another mine
        var x = Int.random(in: 0..<data.count)
        var y = Int.random(in: 0..<data[0].count)
        while data[x][y].isMine || (x == pos.x && y == pos.y) {
            // increase x and y
            if y == data[0].count - 1 {
                x += 1
                y = 0
            } else {
                y += 1
            }
            if x == data.count {
                x = 0
            }
        }
        getTile(x: x, y: y).tile.isMine = true
        for i in -1...1 {
            for j in -1...1 {
                if i == 0 && j == 0 {
                    continue
                }
                let newX = x + i
                let newY = y + j
                if newX < 0 || newX >= data.count || newY < 0 || newY >= data[0].count {
                    continue
                }
                getTile(x: newX, y: newY).tile.minesAround += 1
            }
        }
    }
    
    func finish(win: Bool) {
        for child in self.children {
            let tile = child as! Tile
            if tile.tile.isMine || tile.tile.isFlagged {
                tile.finish(win: win)
            }
        }
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
