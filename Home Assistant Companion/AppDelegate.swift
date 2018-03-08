//
//  AppDelegate.swift
//  Home Assistant Companion
//
//  Created by Josa Gesell on 08.03.18.
//  Copyright © 2018 Josa Gesell. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  var api: HomeAssistantApi!
  
  var item: NSStatusItem!
  
  var preferencesView: PreferencesViewController!
  var preferencesWindow: NSWindowController?
  
  var groupItems: [NSMenuItem] = []

  @IBOutlet weak var window: NSWindow!

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    api = HomeAssistantApi()
    item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    let menu = NSMenu()
    
    item?.menu = menu
    
    let icon = NSImage(named: NSImage.Name(rawValue: "menu-icon"))
    
    icon?.isTemplate = true
    item?.image = icon
    
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Preferences", action: #selector(self.showPreferences), keyEquivalent: ""))
    
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(self.quitMe), keyEquivalent: ""))
    
    _ = api.onStateChange(forType: "group") { states in
      
      print("onStateChange: group")
      
      self.groupItems.forEach({ groupItem in
        
        let items = groupItem.submenu?.items as! [StateMenuItem]
        items.forEach({ subItem in subItem.disconnect() })
        
        
        self.item.menu?.removeItem(groupItem)
        if let idx = self.groupItems.index(where: { $0 == groupItem }) {
          self.groupItems.remove(at: idx)
        }
      })

      
      states.values
        .filter({ $0.visible && $0.items.contains(where: { $0.hasPrefix("light.") || $0.hasPrefix("switch.") }) })
        .sorted(by: { $0.order > $1.order })
        .forEach({ state in
          let groupItem = NSMenuItem(title: state.name, action: nil, keyEquivalent: "")
          
          groupItem.submenu = NSMenu()
          
          self.item?.menu?.insertItem(groupItem, at: 0)
          self.groupItems.append(groupItem)
          
          state.items.filter({ $0.hasPrefix("light.") || $0.hasPrefix("switch.") }).forEach({ entityId in
            groupItem.submenu?.addItem(StateMenuItem(forEntity: entityId, at: self.api))
          })
        })
      
//      self.groupItems.forEach({ item in
//        item.menu?.removeItem(item)
//        if let idx = self.groupItems.index(where: { $0 == item }) {
//          self.groupItems.remove(at: idx)
//        }
//      })
    }
  }
  
  @objc func quitMe() {
    NSApplication.shared.terminate(self)
  }
  
  @objc func showPreferences() {
    NSApp.activate(ignoringOtherApps: true)
    preferences.window?.makeKeyAndOrderFront(self)
    preferences.showWindow(self)
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
  
  var preferences: NSWindowController {
    
    if preferencesView == nil {
      preferencesView = PreferencesViewController.init(nibName: NSNib.Name("PreferencesView"), bundle: nil)
    }
    
    if preferencesWindow == nil {
      let window = NSWindow(contentViewController: preferencesView)
      window.title = "Preferences"
      window.styleMask = [ .titled, .closable ]
      preferencesWindow = NSWindowController(window: window)
    }
    
    return preferencesWindow!
  }


}

