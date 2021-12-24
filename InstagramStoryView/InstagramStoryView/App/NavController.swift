//
//  NavigationController.swift
//  InstagramStoryView
//
//  Created by Milan Savaliya on 24/12/21.
//

import UIKit

struct AppColor {

    static let Border        = UIColor(named: "Border")!
    static let Theme        = UIColor(named: "Theme")!
    static let Navigation    = UIColor(named: "Navigation")!
}

class NavigationController: UINavigationController {

	override func viewDidLoad() {

		super.viewDidLoad()

		setNavigationBar()
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {

		return .default
	}

	func setNavigationBar() {

		let compactAppearance = UINavigationBarAppearance()
		compactAppearance.configureWithTransparentBackground()
		compactAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
		compactAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
		compactAppearance.backgroundColor = .systemBackground

		navigationBar.isTranslucent = true
		navigationBar.standardAppearance = compactAppearance
		navigationBar.compactAppearance = compactAppearance
		navigationBar.scrollEdgeAppearance = compactAppearance
		navigationBar.tintColor = AppColor.Theme
		navigationBar.layoutIfNeeded()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func setBackground(color: UIColor) {

		self.navigationBar.standardAppearance.backgroundColor = color
		self.navigationBar.compactAppearance?.backgroundColor = color
		self.navigationBar.scrollEdgeAppearance?.backgroundColor = color
	}
}
