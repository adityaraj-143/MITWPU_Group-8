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

class CameraManager: NSObject {

    static let shared = CameraManager()
    private override init() {}

    // MARK: AR
    private let session = ARSession()
    private let arView = ARView(frame: .zero)

    // MARK: State
    private(set) var isRunning = false
    private(set) var currentDistance: Int = 0
    private(set) var isFaceDetected = false
    private(set) var alignmentState: CameraAlignmentState = .noFace

    private let minDistance = 37
    private let maxDistance = 45

    // MARK: Setup

    func configure() {
        guard ARFaceTrackingConfiguration.isSupported else { return }

        session.delegate = self
        arView.session = session
    }

    func attachPreview(to container: UIView) {

        arView.removeFromSuperview()

        container.addSubview(arView)
        arView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: container.topAnchor),
            arView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            arView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
    }

    // MARK: Session Control

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

    // MARK: Helpers

    func isDistanceInRange() -> Bool {
        currentDistance >= minDistance && currentDistance <= maxDistance
    }
}

// MARK: ARSessionDelegate

extension CameraManager: ARSessionDelegate {

    func session(_ session: ARSession, didUpdate frame: ARFrame) {

        guard let faceAnchor = frame.anchors.compactMap({ $0 as? ARFaceAnchor }).first else {
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
