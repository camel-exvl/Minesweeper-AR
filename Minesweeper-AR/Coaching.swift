//
//  Coaching.swift
//  Minesweeper-AR
//
//  Created by zjucvglab509 on 2024/6/14.
//

import SwiftUI
import RealityKit
import ARKit

extension MinesweeperARView: ARCoachingOverlayViewDelegate {
    func addCoaching() {
        self.coachingOverlay.delegate = self
        self.coachingOverlay.session = self.session
        self.coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.coachingOverlay.goal = .horizontalPlane
        
        self.addSubview(self.coachingOverlay)
    }
    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        coachingOverlayView.activatesAutomatically = false
        self.initGame()
    }
}
