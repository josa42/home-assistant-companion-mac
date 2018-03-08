//
//  Disposable.swift
//  Home Assistant Companion
//
//  Created by Josa Gesell on 29.03.18.
//  Copyright © 2018 Josa Gesell. All rights reserved.
//

import Foundation

class Disposable {
  let dispose: () -> ()
  init(_ dispose: @escaping () -> ()) {
    self.dispose = dispose
  }
}
