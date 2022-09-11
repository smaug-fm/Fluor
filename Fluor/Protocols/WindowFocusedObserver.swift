import Cocoa
import Foundation

final class WindowFocusedObserver {
    private var callback: (Bool) -> Void
    private var focused: Bool = false
    private var pid: pid_t

    private var axObserver: AXObserver?
    private var axSystem = AXUIElementCreateSystemWide()
    private var axApp: AXUIElement
    private var timer: Timer?

    private func updateFocused(focused: Bool) {
        self.focused = focused
        self.callback(focused)
    }

    init(pid: pid_t, callback: @escaping (Bool) -> Void) {
        self.pid = pid;
        self.callback = callback
        self.axApp = AXUIElementCreateApplication(pid)

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            let focused = self.getIsFocusedNow()
            if (focused != self.focused) {
                self.updateFocused(focused: focused)
            }
        }
        if AXObserverCreate(
                pid,
                { (observer, element, notification, userData) in
                    let mySelf = Unmanaged<WindowFocusedObserver>.fromOpaque(userData!).takeUnretainedValue()
                    mySelf.updateFocused(focused: true)
                }, &axObserver) == .success {
            if AXObserverAddNotification(
                    axObserver!,
                    axApp,
                    kAXFocusedWindowChangedNotification as CFString,
                    UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())) == .success {
                CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(axObserver!), .defaultMode)
            }
        }
    }

    private func getIsFocusedNow() -> Bool {
        var cfValue: CFTypeRef?
        AXUIElementCopyAttributeValue(axSystem, kAXFocusedApplicationAttribute as CFString, &cfValue)
        if let cfValue = cfValue, CFGetTypeID(cfValue) == AXUIElementGetTypeID() {
            var pid: pid_t = 0;
            AXUIElementGetPid(cfValue as! AXUIElement, &pid);
            return pid == self.pid
        }
        return false
    }

    deinit {
        if (axObserver != nil) {
            AXObserverRemoveNotification(
                    axObserver!,
                    axApp,
                    kAXFocusedWindowChangedNotification as CFString)
        }
        if (timer != nil) {
            timer?.invalidate()
        }
    }
}

