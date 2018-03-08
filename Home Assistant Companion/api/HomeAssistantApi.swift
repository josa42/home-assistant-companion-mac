//
//  HomeAssistantApi.swift
//  Home Assistant Companion
//
//  Created by Josa Gesell on 08.03.18.
//  Copyright © 2018 Josa Gesell. All rights reserved.
//

import Foundation
import Starscream

//class Eventable {
//
//  var listeners = [String: [Int: () -> Void]]()
//
//  var counter = 0;
//
//  func on(_ key: String, handler: @escaping () -> Void) -> Int {
//    let i = self.counter + 1
//    self.counter = i
//
//    guard self.listeners[key] != nil else {
//      self.listeners[key] = [i: handler]
//      return i
//    }
//
//    self.listeners[key]![i] = handler
//
//    return i
//  }
//
//  func emit(_ key: String) {
//    guard let listeners = self.listeners[key] else { return }
//
//    listeners.forEach({ $1() })
//  }
//
//  func off(_ key: String, at position: Int) {
//    self.listeners[key]?.removeValue(forKey: position)
//  }
//
//}


class HomeAssistantApi: WebSocketDelegate {
  var socket: WebSocket!
  
  var states = [String: State]()
  
  var idCount: Int = 0
  var handlerCount: Int = 0;
  
  var handlersForEntity = [String: [Int: (State) -> Void]]()
  var handlersForType = [String: [Int: ([String: State]) -> Void]]()
  var callbacks = [Int: (Dictionary<String, Any>) -> Void]()
  
  init() {
    let pref = PreferenceManager.shared
    
    print("pref.host: \(pref.host)")
    
    print("HomeAssistantApi: Init")
    socket = WebSocket(url: URL(string: "ws://\(pref.host)/api/websocket?es5")!)
    socket.delegate = self
    socket.connect()
    
//    socket.write(string: "{ \"id\": 18, \"type\": \"subscribe_events\", \"event_type\": \"state_changed\" }")
  }
  
  // MARK: api
  
  func send(message command: Dictionary<String, Any>) {
    let jsonData = try! JSONSerialization.data(withJSONObject: command, options: .init(rawValue: 0))
    // {
      // Check if everything went well
      // print(String(data: jsonData, encoding: .utf8)!)
      socket.write(string: String(data: jsonData, encoding: .utf8)!)
      
      // Do something cool with the new JSON data
    // }
  }
  
  func send(command: Dictionary<String, Any>, callback: @escaping (Dictionary<String, Any>) -> Void) {
    var message = command
    self.idCount += 1
    
    message["id"] = self.idCount
    callbacks[self.idCount] = callback
    
    send(message: message)
  }
  
  func onStateChange(forEntity entityId: String, handler: @escaping (State) -> Void) -> Disposable {
    var handlers = self.handlersForEntity[entityId] ?? [Int: (State) -> Void]()
    let idx = getHandlerIndex()
    handlers[idx] = handler
    self.handlersForEntity[entityId] = handlers
    
    return Disposable({
      handlers.removeValue(forKey: idx)
      print("dispose: \(entityId) : \(handlers.count) \(handlers[idx])")
    })
  }
  
  func onStateChange(forType type: String, handler: @escaping ([String: State]) -> Void) -> Disposable {
    var handlers = self.handlersForType[type] ?? [Int: ([String: State]) -> Void]()
    let idx = getHandlerIndex()
    
    handlers[idx] = handler
    self.handlersForType[type] = handlers
    
    return Disposable({
      handlers.removeValue(forKey: idx) })
      print("dispose: \(type) : \(handlers.count)")
  }
  
  func getState(for key: String) -> State? {
    return states[key]
  }
  
  func getStates(for type: String) -> [String: State] {
    return states.filter { $0.key.hasPrefix("\(type).") }
  }
  
  private func emitStateChange(for entityId: String, to state: State) {
    
    let type = state.type
    states[entityId] = state
    
    if let handlers = self.handlersForEntity[entityId] {
      for (idx, handler) in handlers {
        print("calls \(idx) for \(entityId)")
        handler(state)
      }
    }
    
    if let handlers = self.handlersForType[type] {
      let states = getStates(for: type)
      for (_, handler) in handlers {
        handler(states)
      }
    }
  }
  
  // MARK: Handler
  
  func handleAuthRequired(with dict: Dictionary<String, Any>) {
    let pref = PreferenceManager.shared
    
    send(message: [
      "type": "auth",
      "api_password": pref.password
    ])
  }
  
  func handleAuthSuccess() {
    send(command: [
      "type": "subscribe_events",
      "event_type": "state_changed"
    ]) { result in
      // print("\(result)")
    }
    
    send(command: [
      "type": "get_states"
    ]) { response in
      // print("\(response)")
      if let states = response["result"] as? [[String: Any]] {
        // print("get_states: => \(result)")
        for stateJson in states {
          if let entityId = stateJson["entity_id"] as? String {
            self.emitStateChange(for: entityId, to: State(json: stateJson)!)
          }
        }
        // emitStateChangeFor(entity: event.entityId, to: event.newState)
      }
    }
  }
  
  func handleEvent(with dict: [String: Any]) {
    // print("handleEvent()")
    // print("=> \(dict)")
    if let eventJson = dict["event"] as? [String: Any] {
      if let type = eventJson["event_type"] as? String {
        // print("=> type \(type)")
        switch type {
        case "state_changed":
          if let event = StateChangeEvent(json: eventJson["data"] as! [String: Any]) {
            emitStateChange(for: event.entityId, to: event.newState)
          }
          
          // print("\(event!)")
        default:
          print("Unknown event: \(type)")
          print("=> \(dict)")
        }
      }
    }
  }
  
  func handleResult(with dict: [String: Any]) {
   if let id = dict["id"] as? Int,
      let callback = callbacks.removeValue(forKey: id) {
        callback(dict)
    }
  }
  
  // MARK: WebSocketDelegate
  
  func websocketDidConnect(socket: WebSocketClient) {
    print("websocket is connected")
  }
  
  func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    print("websocket is disconnected: \(String(describing: error?.localizedDescription))")
    socket.connect()
  }
  
  func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    let json = try? JSONSerialization.jsonObject(with: text.data(using: .utf8)!, options: [])
    if let dictionary = json as? [String: Any] {
      if let type = dictionary["type"] as? String {
        switch type {
        case "auth_required":
          handleAuthRequired(with: dictionary)
        case "auth_ok":
          handleAuthSuccess()
        case "auth_invalid":
          print("Authentication: Error")
          print("\(dictionary)")
        case "event":
          handleEvent(with: dictionary)
        case "result":
          handleResult(with: dictionary)
        default:
          print("Unknown type: \(type)")
          print("=> \(dictionary)")
        }
      }
    }

  }
  
  func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
    // print("got some data: \(data.count)")
  }
  
  func getHandlerIndex() -> Int {
    let idx = handlerCount + 1
    handlerCount = idx
    
    return idx
  }
  
//  func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
//    print("Got pong! Maybe some data: \(String(describing: data?.count))")
//  }
  
  
}
