//
//  MorphManager.swift
//  Spy
//
//  Created by Zeynep Müslim on 6.04.2025.
//

import UIKit

// MARK: - MorphManager

class MorphManager {
    
    // MARK: - Types
    
    enum MorphType {
        case revealTrueRole
        case switchRole
    }
    
    struct MorphLayers {
        let hat: CAShapeLayer
        let rightEye: CAShapeLayer
        let leftEye: CAShapeLayer
    }
    
    struct MorphConfiguration {
        let duration: TimeInterval
        let timingFunction: CAMediaTimingFunction
        let fillMode: CAMediaTimingFillMode
        let isRemovedOnCompletion: Bool
        
        static let `default` = MorphConfiguration(
            duration: 0.8,
            timingFunction: CAMediaTimingFunction(name: .easeInEaseOut),
            fillMode: .both,
            isRemovedOnCompletion: false
        )
    }
    
    // MARK: - Properties
    
    private let layers: MorphLayers
    private let iconContainer: UIView
    private var configuration: MorphConfiguration
    
    // MARK: - Initialization
    
    init(layers: MorphLayers, iconContainer: UIView, configuration: MorphConfiguration = .default) {
        self.layers = layers
        self.iconContainer = iconContainer
        self.configuration = configuration
    }
    
    // MARK: - Public API
    
    func morphTo(isSpy: Bool, type: MorphType = .switchRole) {
        let fromPaths = getIconPaths(for: !isSpy)
        let toPaths = getIconPaths(for: isSpy)
        let transform = getCenteringTransform(for: [toPaths.hat, toPaths.rightEye, toPaths.leftEye])
        
        performMorphAnimation(from: fromPaths, to: toPaths, transform: transform)
    }
    
    func morphFrom(_ from: Bool, to: Bool, type: MorphType = .switchRole) {
        let fromPaths = getIconPaths(for: from)
        let toPaths = getIconPaths(for: to)
        let transform = getCenteringTransform(for: [toPaths.hat, toPaths.rightEye, toPaths.leftEye])
        
        performMorphAnimation(from: fromPaths, to: toPaths, transform: transform)
    }
    
    func applyStaticPaths(for isSpy: Bool) {
        let paths = getIconPaths(for: isSpy)
        let transform = getCenteringTransform(for: [paths.hat, paths.rightEye, paths.leftEye])
        
        setLayerPaths(paths, transform: transform)
    }
    
    func updateConfiguration(_ configuration: MorphConfiguration) {
        self.configuration = configuration
    }
    
    func stopAnimations() {
        layers.hat.removeAnimation(forKey: "morphHat")
        layers.rightEye.removeAnimation(forKey: "morphRightEye")
        layers.leftEye.removeAnimation(forKey: "morphLeftEye")
    }
    
    // MARK: - Private Methods
    
    private func getIconPaths(for isSpy: Bool) -> (hat: UIBezierPath, rightEye: UIBezierPath, leftEye: UIBezierPath) {
        if isSpy {
            return (
                hat: IconPaths.spyHatPath(),
                rightEye: IconPaths.spyRightEyePath(),
                leftEye: IconPaths.spyLeftEyePath()
            )
        } else {
            return (
                hat: IconPaths.civilianHatPath(),
                rightEye: IconPaths.civilianRightEyePath(),
                leftEye: IconPaths.civilianLeftEyePath()
            )
        }
    }
    
    private func performMorphAnimation(from fromPaths: (hat: UIBezierPath, rightEye: UIBezierPath, leftEye: UIBezierPath),
                                       to toPaths: (hat: UIBezierPath, rightEye: UIBezierPath, leftEye: UIBezierPath),
                                       transform: CGAffineTransform) {
        let animations = createMorphAnimations(from: fromPaths, to: toPaths, transform: transform)
        
        configureMorphAnimations(animations)
        applyAnimationsToLayers(animations)
        setLayerPaths(toPaths, transform: transform)
    }
    
    private func createMorphAnimations(from: (hat: UIBezierPath, rightEye: UIBezierPath, leftEye: UIBezierPath),
                                       to: (hat: UIBezierPath, rightEye: UIBezierPath, leftEye: UIBezierPath),
                                       transform: CGAffineTransform) -> [CAKeyframeAnimation] {
        let morphHat = CAKeyframeAnimation(keyPath: "path")
        let morphRightEye = CAKeyframeAnimation(keyPath: "path")
        let morphLeftEye = CAKeyframeAnimation(keyPath: "path")
        
        morphHat.values = [from.hat.transformed(by: transform).cgPath, to.hat.transformed(by: transform).cgPath]
        morphRightEye.values = [from.rightEye.transformed(by: transform).cgPath, to.rightEye.transformed(by: transform).cgPath]
        morphLeftEye.values = [from.leftEye.transformed(by: transform).cgPath, to.leftEye.transformed(by: transform).cgPath]
        
        return [morphHat, morphRightEye, morphLeftEye]
    }
    
    /// Example usage:
    /// ```swift
    /// let fastConfig = MorphManager.MorphConfiguration(
    ///     duration: 0.3,
    ///     timingFunction: CAMediaTimingFunction(name: .easeOut),
    ///     fillMode: .both,
    ///     isRemovedOnCompletion: false
    /// )
    /// cell.updateMorphConfiguration(fastConfig)
    /// ```
    
    private func configureMorphAnimations(_ animations: [CAKeyframeAnimation]) {
        animations.forEach { animation in
            animation.duration = configuration.duration
            animation.timingFunction = configuration.timingFunction
            animation.fillMode = configuration.fillMode
            animation.isRemovedOnCompletion = configuration.isRemovedOnCompletion
        }
    }
    
    private func applyAnimationsToLayers(_ animations: [CAKeyframeAnimation]) {
        guard animations.count == 3 else { return }
        
        layers.hat.add(animations[0], forKey: "morphHat")
        layers.rightEye.add(animations[1], forKey: "morphRightEye")
        layers.leftEye.add(animations[2], forKey: "morphLeftEye")
    }
    
    private func setLayerPaths(_ paths: (hat: UIBezierPath, rightEye: UIBezierPath, leftEye: UIBezierPath),
                               transform: CGAffineTransform) {
        layers.hat.path = paths.hat.transformed(by: transform).cgPath
        layers.rightEye.path = paths.rightEye.transformed(by: transform).cgPath
        layers.leftEye.path = paths.leftEye.transformed(by: transform).cgPath
    }
    
    private func getCenteringTransform(for paths: [UIBezierPath]) -> CGAffineTransform {
        let combinedPath = UIBezierPath()
        paths.forEach { combinedPath.append($0) }
        
        let pathBounds = combinedPath.bounds
        let iconSize = iconContainer.bounds.size
        
        guard iconSize.width > 0, iconSize.height > 0, pathBounds.width > 0, pathBounds.height > 0 else {
            return .identity
        }
        
        let scaleX = iconSize.width / pathBounds.width
        let scaleY = iconSize.height / pathBounds.height
        let scale = min(scaleX, scaleY) * 0.8
        
        let translationToOrigin = CGAffineTransform(translationX: -pathBounds.origin.x, y: -pathBounds.origin.y)
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        
        let scaledPathWidth = pathBounds.width * scale
        let scaledPathHeight = pathBounds.height * scale
        let translationToCenter = CGAffineTransform(translationX: (iconSize.width - scaledPathWidth) / 2, y: (iconSize.height - scaledPathHeight) / 2)
        
        return translationToOrigin.concatenating(scaleTransform).concatenating(translationToCenter)
    }
}

// MARK: - Extensions

extension UIBezierPath {
    func transformed(by transform: CGAffineTransform) -> UIBezierPath {
        let path = self.copy() as! UIBezierPath
        path.apply(transform)
        return path
    }
}
