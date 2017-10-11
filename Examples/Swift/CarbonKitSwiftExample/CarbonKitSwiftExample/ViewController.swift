//
//  ViewController.swift
//  CarbonKitSwiftExample
//
//  Created by Ermal Kaleci on 06/10/2017.
//  Copyright © 2017 Ermal Kaleci. All rights reserved.
//

import UIKit
import CarbonKit

class ViewController: UIViewController, CarbonTabSwipeNavigationDelegate {

    func generateImage(for view: UIView) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }

    var iconWithTextImage: UIImage {
        let button = UIButton()
        let icon = UIImage(named: "home")
        button.setImage(icon, for: .normal)
        button.setTitle("Home", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 10)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        button.sizeToFit()
        return generateImage(for: button) ?? UIImage()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tabSwipe = CarbonTabSwipeNavigation(items: [iconWithTextImage, "HELLO WORLD", "Tab", "Another One", iconWithTextImage], delegate: self)
        tabSwipe.setTabExtraWidth(40)
        tabSwipe.insert(intoRootViewController: self)

    }

    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        guard let storyboard = storyboard else { return UIViewController() }
        if index == 0 {
            return storyboard.instantiateViewController(withIdentifier: "FirstViewController")
        }
        return storyboard.instantiateViewController(withIdentifier: "SecondTableViewController")
    }

}

