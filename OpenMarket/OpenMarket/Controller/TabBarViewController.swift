//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class TabBarViewController: UITabBarController {

    @IBOutlet weak var segmentSwitch: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpSegmentSwitch()
    }
    
    private func setUpSegmentSwitch() {
        // segmentSwitch.selectedSegmentIndex = .zero
        // segmentSwitch.sizeToFit()
        segmentSwitch.layer.borderColor = UIColor.systemBlue.cgColor
        segmentSwitch.layer.borderWidth = 1
        segmentSwitch.selectedSegmentTintColor = .systemBlue
        segmentSwitch.backgroundColor = .white
        segmentSwitch.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        segmentSwitch.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }

}

