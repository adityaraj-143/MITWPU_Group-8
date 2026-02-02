//
//  CameraManager.swift
//  EyeRis
//
//  Created by SDC-USER on 23/01/26.
//

import Foundation
import ARKit
import RealityKit
import UIKit

enum CameraAlignmentState {
    case manual
    case tooClose
    case tooFar
    case noFace
}

private(set) var alignmentState: CameraAlignmentState = .noFace

class CameraManager: NSObject {
    
    static let shared = CameraManager()
    
    private override init() {}
    
    // MARK: AR Core
    private let session = ARSession()
    private let arView = ARView(frame: .zero)
    private(set) var isRunning = false
    private(set) var currentDistance: Int = 0
    private(set) var isFaceDetected = false
    private(set) var alignmentState: CameraAlignmentState = .noFace
    private let minDistance = 37
    private let maxDistance = 45
    
    func configure() {
        guard ARFaceTrackingConfiguration.isSupported else { return }

        session.delegate = self
        arView.session = session
    }
    
    func start() {
        guard !isRunning else { return }

        let config = ARFaceTrackingConfiguration()
        config.isLightEstimationEnabled = false

        session.run(config, options: [.resetTracking, .removeExistingAnchors])
        isRunning = true
    }

    func stop() {
        guard isRunning else { return }
        session.pause()
        isRunning = false
    }
    
    func reset() {
        stop()
        isFaceDetected = false
        currentDistance = 0
        alignmentState = .noFace
    }

    func attachPreview(to containerView: UIView) {

        // Remove from previous parent if any
        arView.removeFromSuperview()

        containerView.addSubview(arView)
        arView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: containerView.topAnchor),
            arView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            arView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }

    func isDistanceInRange() -> Bool {
        return currentDistance >= minDistance && currentDistance <= maxDistance
    }
}
extension CameraManager: ARSessionDelegate {

    func session(_ session: ARSession, didUpdate frame: ARFrame) {

        let faceAnchors = frame.anchors.compactMap { $0 as? ARFaceAnchor }

        guard let faceAnchor = faceAnchors.first else {
            isFaceDetected = false
            currentDistance = 0
            alignmentState = .noFace
            return
        }

        isFaceDetected = true

        let z = faceAnchor.transform.columns.3.z
        let distanceMeters = abs(z)
        currentDistance = Int(distanceMeters * 100)

        if currentDistance < minDistance {
            alignmentState = .tooClose
        } else if currentDistance > maxDistance {
            alignmentState = .tooFar
        } else {
            alignmentState = .manual
        }
    }
}
