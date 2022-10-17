import Cocoa
import Foundation

final class ApplicationIsRunningObserver {
    private var isRunning: Bool = false
    private var app: NSRunningApplication? = nil
    private var timer: Timer?

    init(bundleId: String, callback: @escaping (Bool, NSRunningApplication?) -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            let running = NSWorkspace.shared.runningApplications.contains { app in
                if (app.bundleIdentifier == bundleId) {
                    self.app = app
                    return true
                } else {
                    self.app = nil
                    return false
                }
            }
            if (self.isRunning != running) {
                callback(running, self.app)
                self.isRunning = running
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
}
