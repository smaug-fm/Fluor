import Foundation

class ApplicationWindowFocusManager {
    static let shared = ApplicationWindowFocusManager()

    private var observers: [String: (ApplicationIsRunningObserver, WindowFocusedObserver?, Array<(Bool, pid_t) -> Void>)] = [:]

    func addObserver(bundleId: String, callback: @escaping (Bool, pid_t) -> Void) {
        var tuple = observers[bundleId]
        if (tuple == nil) {
            observers[bundleId] = (ApplicationIsRunningObserver(bundleId: bundleId) { running, pid in
                if (running) {
                    print("\(bundleId) is running")
                    self.observers[bundleId]!.1 = WindowFocusedObserver(pid: pid!) { focused in
                        print("\(bundleId) window \(focused ? "got" : "lost") focus")
                        self.observers[bundleId]!.2.forEach { cb in
                            cb(focused, pid!)
                        }
                    }
                } else {
                    print("\(bundleId) is stopped")
                    self.observers[bundleId]!.1 = nil
                }
            }, nil, [callback])
        } else {
            tuple!.2.append(callback)
        }
    }

    func removeObserver(bundleId: String) {
        observers[bundleId] = nil;
    }
}
