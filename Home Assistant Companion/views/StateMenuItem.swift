//
//  LightMenuItem.swift
//  Home Assistant Companion
//
//  Created by Josa Gesell on 08.03.18.
//  Copyright © 2018 Josa Gesell. All rights reserved.
//

import Cocoa

class StateMenuItem: NSMenuItem {
  
  var entityId: String
  var api: HomeAssistantApi
  
  var dispoable: Disposable?
  
  var type: String {
    get {
      let regex = try! NSRegularExpression(pattern: "\\..*$")
      let range = NSMakeRange(0, entityId.count)
      return regex.stringByReplacingMatches(in: entityId, options: [], range: range, withTemplate: "")
    }
  }
  
  init(forEntity entityId: String, at api: HomeAssistantApi) {
    print("init: \(entityId)")
    
    self.entityId = entityId
    self.api = api
    
    super.init(title: "", action: #selector(action(sender:)), keyEquivalent: "")
    
    self.target = self
    
    if let entityState = api.getState(for: entityId) {
      self.state = entityState.active ? .on : .off
      self.title = entityState.name
    }
    
    dispoable = api.onStateChange(forEntity: entityId, handler: { entityState in
      print("onStateChange: \(entityId) -> \(entityState.active)")
      self.state = entityState.active ? .on : .off
      self.title = entityState.name
    })
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func disconnect() {
    print("disconnect")
    dispoable?.dispose()
    dispoable = nil
  }
  
  deinit {
    print("deinit")
    disconnect()
  }
  
  @objc func action(sender: NSMenuItem) {
    api.send(command: [
      "type": "call_service",
      "domain": type,
      "service": "toggle",
      "service_data": ["entity_id": entityId]
    ]) { _ in }
  }
  
  
}
