//
//  State.swift
//  Home Assistant Companion
//
//  Created by Josa Gesell on 08.03.18.
//  Copyright © 2018 Josa Gesell. All rights reserved.
//

import Foundation

class Entity: CustomStringConvertible {
  var entityId: String
  var state: State
  
  init(entityId: String) {
    self.entityId = entityId
    self.state = State(for: entityId, state: "Unknown")
  }

  var description: String {
    return "(\(entityId)[\(state)"
  }
}
