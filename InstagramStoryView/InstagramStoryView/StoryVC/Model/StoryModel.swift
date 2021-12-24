//
//  StoryModel.swift
//  CCSIMobile
//
//  Created by mac on 25/11/21.
//  Copyright © 2021 Milan Savaliya. All rights reserved.
//
import Foundation

enum StoryType: String {
    case image
    case video
}

class StoryModel: NSObject {
    var title: String
    var story: [SnapsModle]

    init(title: String, story: [SnapsModle]) {
        self.title = title
        self.story = story
    }
}
