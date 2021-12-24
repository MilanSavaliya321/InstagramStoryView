//
//  Extension.swift
//  InstagramStoryView
//
//  Created by Milan Savaliya on 24/12/21.
//

import UIKit

extension Collection {
    func get(at index: Index) -> Iterator.Element? {
        return self.indices.contains(index) ? self[index] : nil
    }
}

extension UIView {
    
    func addSubViewWithAutolayout(subView: UIView) {
        addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        subView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        subView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        subView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        subView.layoutIfNeeded()
        self.layoutIfNeeded()
    }
    
}
