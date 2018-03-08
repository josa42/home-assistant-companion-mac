//
//  State.swift
//  Home Assistant Companion
//
//  Created by Josa Gesell on 08.03.18.
//  Copyright © 2018 Josa Gesell. All rights reserved.
//

import Foundation

class State: CustomStringConvertible {
  var attributes: [String: Any]
   var entityId: String
  var state: String

  //  "last_changed" = "2018-03-08T10:08:54.913023+00:00";
  //  "last_updated" = "2018-03-08T10:08:54.913023+00:00";
  
  init(for entityId: String, state: String) {
    self.entityId = entityId
    self.state = state
    self.attributes = [:]
  }
  
  init?(json: [String: Any]) {
    guard
      let entityId = json["entity_id"] as? String,
      let attributes = json["attributes"] as? [String: Any],
      let state = json["state"] as? String
    else {
      return nil
    }
    
    self.entityId = entityId
    self.attributes = attributes
    self.state = state
  }
  
  var description: String {
    return "(\(state))"
  }
  
  var name: String {
    get {
      if let name = attributes["friendly_name"] as? String {
        return name
      }
      
      let regex = try! NSRegularExpression(pattern: "^[^.]+\\.")
      let range = NSMakeRange(0, entityId.count)
      return regex.stringByReplacingMatches(in: entityId, options: [], range: range, withTemplate: "")
    }
  }
  
  var visible: Bool {
    get {
      if let hidden = attributes["hidden"] as? Bool {
        return !hidden
      }
      return true
    }
  }
  
  var order: Int {
    get {
      if let order = attributes["order"] as? Int {
        return order
      }
      return 0
    }
  }
  
  var active: Bool {
    get {
      // print("state: \(state)")
      return state == "on"
    }
  }
  
  var type: String {
    get {
      let regex = try! NSRegularExpression(pattern: "\\..*$")
      let range = NSMakeRange(0, entityId.count)
      return regex.stringByReplacingMatches(in: entityId, options: [], range: range, withTemplate: "")
    }
  }
  
  var items: [String] {
    get {
      if let items = attributes["entity_id"] as? [String] {
        return items
      }
      return []
    }
  }
}
