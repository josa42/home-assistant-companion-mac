//
//  PreferencesViewController.swift
//  Home Assistant Companion
//
//  Created by Josa Gesell on 08.03.18.
//  Copyright © 2018 Josa Gesell. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

  @IBOutlet weak var hostField: NSTextField!
  
  @IBOutlet weak var passwordField: NSSecureTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let pref = PreferenceManager.shared
    hostField.stringValue = pref.host
    passwordField.stringValue = pref.password
  }
  
  override func controlTextDidChange(_ notification: Notification) {
    if let textField = notification.object as? NSTextField {
      print(textField.stringValue)
      //do what you need here
      
      let pref = PreferenceManager.shared
      if textField == hostField {
        pref.host = textField.stringValue
      }
      
      if textField == passwordField {
        pref.password = textField.stringValue
      }
    }
  }
    
}
