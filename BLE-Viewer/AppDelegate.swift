//
//  AppDelegate.swift
//  BLE-Viewer
//
//  Created by Alexander Heinrich on 24.09.19.
//  Copyright © 2019 Alexander Heinrich. All rights reserved.
//

import Cocoa
//#if canImport(SwiftUI)
//import SwiftUI
//#endif

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
        styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
        backing: .buffered, defer: false)
        
        if #available(macOS 10.15, *) {
            
            
            window.center()
            window.setFrameAutosaveName("Main Window")
            window.makeKeyAndOrderFront(nil)
//            window.contentView = NSHostingView(rootView: ContentView())
        }else {
            let vc = NSStoryboard(name: "Main", bundle: nil).instantiateInitialController() as! NSViewController
            
            window.contentViewController = vc
        }
        
        
    }
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

