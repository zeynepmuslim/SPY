import UIKit

class WinkAnimationView: UIView {
    
    // MARK: - Types
    enum Role: String, CaseIterable {
        case spy = "spy"
        case civil = "civil"
    }
    
    enum Color: String, CaseIterable {
        case black = "b"
        case white = "w"
    }
    
    // MARK: - Constants
    private struct AnimationConstants {
        static let defaultInterval: TimeInterval = 2.5
        static let sequenceLengthRange = 5...6
        static let winkDelay: TimeInterval = 0.2
        static let normalDelay: TimeInterval = 0.25
    }
    
    // MARK: - Properties
    private var imageView: UIImageView!
    private var animationTimer: Timer?
    
    private let role: Role
    private let color: Color
    private let size: CGSize
    
    // MARK: - Computed Properties
    private var baseImages: [String] {
        return ["\(role.rawValue)-left-\(color.rawValue)", "\(role.rawValue)-right-\(color.rawValue)"]
    }
    
    private var winkImage: String {
        return "\(role.rawValue)-wink-\(color.rawValue)"
    }
    
    // MARK: - Initialization
    init(role: Role, color: Color, size: CGSize) {
        self.role = role
        self.color = color
        self.size = size
        super.init(frame: CGRect(origin: .zero, size: size))
        setupImageView()
        startAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopAnimation()
    }
    
    // MARK: - Setup
    private func setupImageView() {
        imageView = UIImageView(image: UIImage(named: baseImages[0]))
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Animation Control
    func startAnimation() {
        startAnimationWithInterval(AnimationConstants.defaultInterval)
    }
    
    func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    func setAnimationInterval(_ interval: TimeInterval) {
        startAnimationWithInterval(interval)
    }
    
    // MARK: - Private Animation Methods
    private func startAnimationWithInterval(_ interval: TimeInterval) {
        stopAnimation()
        
        DispatchQueue.main.async {
            self.executeImageSequence()
        }
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.executeImageSequence()
            }
        }
    }
    
    private func executeImageSequence() {
        let sequence = generateImageSequence()
        playImageSequence(sequence)
    }
    
    private func generateImageSequence() -> [String] {
        let sequenceLength = Int.random(in: AnimationConstants.sequenceLengthRange)
        var sequence: [String] = []
        
        for _ in 0..<sequenceLength {
            sequence.append(baseImages[Int.random(in: 0...1)])
        }
        
        let insertIndex = Int.random(in: 1...(sequence.count - 1))
        sequence.insert(winkImage, at: insertIndex)
        
        return sequence
    }
    
    private func playImageSequence(_ sequence: [String]) {
        var delay: TimeInterval = 0
        
        for imageName in sequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.imageView.image = UIImage(named: imageName)
            }
            
            delay += (imageName == winkImage) ? AnimationConstants.winkDelay : AnimationConstants.normalDelay
        }
    }
}

// MARK: - Convenience Methods
extension WinkAnimationView {
    
    /// Creates a WinkAnimationView with square dimensions
    convenience init(role: Role, color: Color, sideLength: CGFloat) {
        self.init(role: role, color: color, size: CGSize(width: sideLength, height: sideLength))
    }
} 
