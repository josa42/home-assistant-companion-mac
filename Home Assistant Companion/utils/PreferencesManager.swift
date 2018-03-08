//
//  PreferencesManager.swift
//  Home Assistant Companion
//
//  Created by Josa Gesell on 08.03.18.
//  Copyright © 2018 Josa Gesell. All rights reserved.
//

import Foundation

class PreferenceManager {
  
  static let shared = PreferenceManager()
  
//  private init() {
//    registerFactoryDefaults()
//  }
  
  let userDefaults = UserDefaults.standard
  
  var host: String {
    get {
      return userDefaults.string(forKey: "host") ?? "192.168.2.5"
    }
    set {
      userDefaults.set(newValue, forKey: "host")
    }
  }
  
  var password: String {
    get {
      return userDefaults.string(forKey: "password") ?? "WuKfeBcNjYMHNGBzXxFftJfM63ruJALZ6qYiTQH8RpoGvoBnX8BVuBVucoFbLgbV"
    }
    set {
      userDefaults.set(newValue, forKey: "password")
    }
  }
  
//  private let initializedKey = "Initialized"
  
//  var startAtLogin: Bool {
//    get {
//      return userDefaults.bool(forKey: "startAtLoginKey")
//    }
//
//    set {
//      userDefaults.set(newValue, forKey: "startAtLoginKey")
//    }
//  }
  
//  private func registerFactoryDefaults() {
//    let factoryDefaults = [
//      initializedKey: NSNumber(value: false),
//    ]
//
//    userDefaults.register(defaults: factoryDefaults)
//  }
//
//  func synchronize() {
//    userDefaults.synchronize()
//  }
//
//  func reset() {
//    userDefaults.removeObject(forKey: initializedKey)
//    synchronize()
//  }
}
