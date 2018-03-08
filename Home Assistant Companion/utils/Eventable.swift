//
//  Eventable.swift
//  Home Assistant Companion
//
//  Created by Josa Gesell on 29.03.18.
//  Copyright © 2018 Josa Gesell. All rights reserved.
//

import Foundation

class Eventable {
  
  var listeners = [String: [Int: () -> Void]]()
  
  var counter = 0;
  
  func on(_ key: String, handler: @escaping () -> Void) -> Int {
    let i = self.counter + 1
    self.counter = i
    
    guard self.listeners[key] != nil else {
      self.listeners[key] = [i: handler]
      return i
    }
    
    self.listeners[key]![i] = handler
    
    return i
  }
  
  func emit(_ key: String) {
    guard let listeners = self.listeners[key] else { return }
    
    listeners.forEach({ $1() })
  }
  
  func off(_ key: String, at position: Int) {
    self.listeners[key]?.removeValue(forKey: position)
  }
  
}
