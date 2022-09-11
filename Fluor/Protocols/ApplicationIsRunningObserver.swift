import Cocoa
import Foundation

final class ApplicationIsRunningObserver {
    private var isRunning: Bool = false
    private var bundleId: String
    private var pid: pid_t? = nil
    private var timer: Timer?

    init(bundleId: String, callback: @escaping (Bool, pid_t?) -> Void) {
        self.bundleId = bundleId;
        listenForApplicationRunningState(callback: callback)
    }

    private func listenForApplicationRunningState(callback: @escaping (Bool, pid_t?) -> Void) {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            let running = NSWorkspace.shared.runningApplications.contains { app in
                if (app.bundleIdentifier == self.bundleId) {
                    self.pid = app.processIdentifier
                    return true
                } else {
                    self.pid = nil
                    return false
                }
            }
            if (self.isRunning != running) {
                callback(running, self.pid)
                self.isRunning = running
            }
        }
    }

    deinit {
        if (timer != nil) {
            timer?.invalidate()
        }
    }
}
