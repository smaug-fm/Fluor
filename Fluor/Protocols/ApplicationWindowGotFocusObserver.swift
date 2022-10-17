import Cocoa
import Foundation

final class ApplicationWindowGotFocusObserver {
    private var callback: () -> Void

    private var axObserver: AXObserver?
//    private let axSystem = AXUIElementCreateSystemWide()
    private let axApp: AXUIElement
    public let app: NSRunningApplication

    init(app: NSRunningApplication, callback: @escaping () -> Void) {
        self.callback = callback
        self.app = app
        axApp = AXUIElementCreateApplication(app.processIdentifier)

        if AXObserverCreate(
                app.processIdentifier,
                { (observer, element, notification, userData) in
                    let mySelf = Unmanaged<ApplicationWindowGotFocusObserver>.fromOpaque(userData!).takeUnretainedValue()
                    mySelf.callback()
                }, &axObserver) == .success {
            if AXObserverAddNotification(
                    axObserver!,
                    axApp,
                    kAXFocusedUIElementChangedNotification as CFString,
                    UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
            ) == .success {
                CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(axObserver!), .defaultMode)
            }
        }
    }

    deinit {
        if (axObserver != nil) {
            AXObserverRemoveNotification(
                    axObserver!,
                    axApp,
                    kAXFocusedUIElementChangedNotification as CFString
            )
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(axObserver!), .defaultMode)
        }
    }
}

