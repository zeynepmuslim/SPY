//
//  TimerManager.swift
//  Spy
//
//  Created by Zeynep Müslim on 27.06.2025.
//

import UIKit
import Foundation

// MARK: - Delegate Protocol

protocol TimerManagerDelegate: AnyObject {
    func timerDidFire(_ timer: ManagedTimer)
    func timerDidComplete(_ timer: ManagedTimer)
}

// MARK: - Managed Timer

class ManagedTimer {
    // MARK: - Properties
    let identifier: String
    let timeInterval: TimeInterval
    let repeats: Bool
    private weak var target: AnyObject?
    private let selector: Selector
    weak var delegate: TimerManagerDelegate?
    
    private(set) var isActive: Bool = false
    private(set) var isPaused: Bool = false
    private var timer: Timer?
    
    // MARK: - Initialization
    init(identifier: String, timeInterval: TimeInterval, target: AnyObject, selector: Selector, repeats: Bool = true, delegate: TimerManagerDelegate? = nil) {
        self.identifier = identifier
        self.timeInterval = timeInterval
        self.target = target
        self.selector = selector
        self.repeats = repeats
        self.delegate = delegate
    }
    
    // MARK: - Timer Control Methods
    func start() {
        guard !isActive, let target = target else { return }
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: target, selector: selector, userInfo: nil, repeats: repeats)
        isActive = true
        isPaused = false
    }
    
    func pause() {
        guard isActive && !isPaused else { return }
        timer?.invalidate()
        timer = nil
        isPaused = true
    }
    
    func resume() {
        guard isActive && isPaused, let target = target else { return }
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: target, selector: selector, userInfo: nil, repeats: repeats)
        isPaused = false
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isActive = false
        isPaused = false
        delegate?.timerDidComplete(self)
    }
    
    var state: TimerState {
        if !isActive { return .inactive }
        return isPaused ? .paused : .active
    }
}

// MARK: - Timer State Enum

enum TimerState {
    case inactive
    case active
    case paused
    
    var description: String {
        switch self {
        case .inactive: return "INACTIVE"
        case .active: return "ACTIVE"
        case .paused: return "PAUSED"
        }
    }
}

// MARK: - Timer Configuration

struct TimerConfiguration {
    let identifier: String
    let timeInterval: TimeInterval
    let repeats: Bool
    let delegate: TimerManagerDelegate?
    
    init(identifier: String, timeInterval: TimeInterval, repeats: Bool = true, delegate: TimerManagerDelegate? = nil) {
        self.identifier = identifier
        self.timeInterval = timeInterval
        self.repeats = repeats
        self.delegate = delegate
    }
    
    // Predefined configurations
    static func countdown(identifier: String, delegate: TimerManagerDelegate? = nil) -> TimerConfiguration {
        return TimerConfiguration(identifier: identifier, timeInterval: 1.0, delegate: delegate)
    }
    
    static func hint(identifier: String, interval: TimeInterval = 4.0, delegate: TimerManagerDelegate? = nil) -> TimerConfiguration {
        return TimerConfiguration(identifier: identifier, timeInterval: interval, delegate: delegate)
    }
    
    static func spawn(identifier: String, interval: TimeInterval = 2.0, delegate: TimerManagerDelegate? = nil) -> TimerConfiguration {
        return TimerConfiguration(identifier: identifier, timeInterval: interval, delegate: delegate)
    }
}

// MARK: - Timer Manager

class TimerManager {
    // MARK: - Singleton
    static let shared = TimerManager()
    
    // MARK: - Properties
    private var managedTimers: [String: ManagedTimer] = [:]
    private var isAppActive: Bool = true
    
    // MARK: - Initialization
    private init() {
        setupAppLifecycleObservers()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Public Timer Management Methods
    @discardableResult
    func createTimer(configuration: TimerConfiguration, target: AnyObject, selector: Selector) -> ManagedTimer? {
        guard managedTimers[configuration.identifier] == nil else {
            debugPrint("Timer '\(configuration.identifier)' already exists")
            return nil
        }
        
        let managedTimer = ManagedTimer(
            identifier: configuration.identifier,
            timeInterval: configuration.timeInterval,
            target: target,
            selector: selector,
            repeats: configuration.repeats,
            delegate: configuration.delegate
        )
        
        managedTimers[configuration.identifier] = managedTimer
        
        if isAppActive {
            managedTimer.start()
        }
        
        return managedTimer
    }
    
    // Legacy method for backward compatibility
    @discardableResult
    func createTimer(identifier: String, timeInterval: TimeInterval, target: AnyObject, selector: Selector, repeats: Bool = true, delegate: TimerManagerDelegate? = nil) -> ManagedTimer? {
        let config = TimerConfiguration(identifier: identifier, timeInterval: timeInterval, repeats: repeats, delegate: delegate)
        return createTimer(configuration: config, target: target, selector: selector)
    }
    
    func stopTimer(identifier: String) {
        guard let timer = managedTimers.removeValue(forKey: identifier) else { return }
        timer.stop()
    }
    
    func pauseTimer(identifier: String) {
        managedTimers[identifier]?.pause()
    }
    
    func resumeTimer(identifier: String) {
        guard isAppActive else { return }
        managedTimers[identifier]?.resume()
    }
    
    func stopAllTimers() {
        managedTimers.values.forEach { $0.stop() }
        managedTimers.removeAll()
    }
    
    // MARK: - Timer Query Methods
    func isTimerActive(identifier: String) -> Bool {
        return managedTimers[identifier]?.state == .active
    }
    
    func getTimerState(identifier: String) -> TimerState? {
        return managedTimers[identifier]?.state
    }
    
    var activeTimerCount: Int {
        return managedTimers.values.filter { $0.state == .active }.count
    }
    
    var totalTimerCount: Int {
        return managedTimers.count
    }
}

// MARK: - App Lifecycle Management

private extension TimerManager {
    func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc func appWillResignActive() {
        guard isAppActive else { return }
        isAppActive = false
        
        guard !managedTimers.isEmpty else { return }
        
        if managedTimers.count > 50 {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.managedTimers.values.forEach { $0.pause() }
            }
        } else {
            managedTimers.values.forEach { $0.pause() }
        }
    }
    
    @objc func appDidBecomeActive() {
        guard !isAppActive else { return }
        isAppActive = true
        
        guard !managedTimers.isEmpty else { return }
        
        if managedTimers.count > 50 {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                // Single iteration - check and resume in one pass
                self?.managedTimers.values.forEach { timer in
                    if timer.isActive { timer.resume() }
                }
            }
        } else {
            managedTimers.values.forEach { timer in
                if timer.isActive { timer.resume() }
            }
        }
    }
    
    func cleanup() {
        NotificationCenter.default.removeObserver(self)
        stopAllTimers()
    }
}

// MARK: - Convenience Methods

extension TimerManager {
    func createCountdownTimer(identifier: String, target: AnyObject, selector: Selector, delegate: TimerManagerDelegate? = nil) -> ManagedTimer? {
        return createTimer(configuration: .countdown(identifier: identifier, delegate: delegate), target: target, selector: selector)
    }
    
    func createHintTimer(identifier: String, target: AnyObject, selector: Selector, interval: TimeInterval = 4.0, delegate: TimerManagerDelegate? = nil) -> ManagedTimer? {
        return createTimer(configuration: .hint(identifier: identifier, interval: interval, delegate: delegate), target: target, selector: selector)
    }
    
    func createSpawnTimer(identifier: String, target: AnyObject, selector: Selector, interval: TimeInterval = 2.0, delegate: TimerManagerDelegate? = nil) -> ManagedTimer? {
        return createTimer(configuration: .spawn(identifier: identifier, interval: interval, delegate: delegate), target: target, selector: selector)
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension TimerManager {
    func debugListTimers() {
        print("TimerManager: Active timers (\(managedTimers.count) total):")
        for (identifier, timer) in managedTimers {
            print("  - \(identifier): \(timer.state.description)")
        }
    }
}
#endif 
