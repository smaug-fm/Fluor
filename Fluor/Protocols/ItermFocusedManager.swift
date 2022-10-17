import Foundation
import Cocoa

class ItermFocusedManager {
    static let shared = ItermFocusedManager()

    private static let itermBundleId = "com.googlecode.iterm2"

    private var isRunningObserver: ApplicationIsRunningObserver?
    private var gotFocusObserver: ApplicationWindowGotFocusObserver?
    private var callbacks: Array<(NSRunningApplication) -> Void> = []

    func addObserver(callback: @escaping (NSRunningApplication) -> Void) {
        callbacks.append(callback)

        if (isRunningObserver == nil) {
            isRunningObserver = ApplicationIsRunningObserver(bundleId: ItermFocusedManager.itermBundleId) { running, app in
                if (running) {
                    self.gotFocusObserver = ApplicationWindowGotFocusObserver(app: app!) {
                        self.callbacks.forEach { cb in
                            cb(app!)
                        }
                    }
                } else {
                    self.gotFocusObserver = nil
                }
            }
        }
    }

    func removeAllObservers() {
        callbacks.removeAll()
        gotFocusObserver = nil
    }
}
