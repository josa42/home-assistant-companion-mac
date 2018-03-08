//
//  StateChangeEvent.swift
//  Home Assistant Companion
//
//  Created by Josa Gesell on 08.03.18.
//  Copyright © 2018 Josa Gesell. All rights reserved.
//

import Foundation

class StateChangeEvent: CustomStringConvertible {
  
  var entityId: String
  var oldState: State
  var newState: State
  
  init?(json: [String: Any]) {
    guard let entityId = json["entity_id"] as? String,
      let oldState = State(json: json["old_state"] as! [String: Any]),
      let newState = State(json: json["new_state"] as! [String: Any])
      else {
        return nil
    }
    
    self.entityId = entityId
    
    self.oldState = oldState
    self.newState = newState
    
//    State
    
//    var meals: Set<Meal> = []
//    for string in mealsJSON {
//      guard let meal = Meal(rawValue: string) else {
//        return nil
//      }
//      
//      meals.insert(meal)
//    }
//    
//    self.name = name
//    self.coordinates = (latitude, longitude)
//    self.meals = meals
  }
  var description: String {
    return "(\(entityId): [\(oldState) => \(newState)])"
  }
}
