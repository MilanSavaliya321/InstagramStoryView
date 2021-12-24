//
//  SnapsModle.swift
//  CCSIMobile
//
//  Created by mac on 01/12/21.
//  Copyright © 2021 Milan Savaliya. All rights reserved.
//
import Foundation

class SnapsModle: NSObject {
    var title: String
    var type: String
    var url: String

    init(title: String, type: String, url: String) {
        self.title = title
        self.type = type
        self.url = url
    }
}
