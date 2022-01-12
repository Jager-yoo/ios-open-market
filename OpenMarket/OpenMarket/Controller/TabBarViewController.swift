//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class TabBarViewController: UITabBarController {

    @IBOutlet private weak var segmentSwitch: UISegmentedControl!
    @IBOutlet private weak var hiddenTabBar: UITabBar!
    
    @IBAction func switchViewLayout(_ sender: UISegmentedControl) {
        // 이미 해당 화면에 있을 경우, 요청을 무시하는 로직을 넣지 않아도, 다시 호출되지 않는 듯?
        switch sender.selectedSegmentIndex {
        case 0:
            print("🧡 LIST 선택됨!")
            // 어떻게 해당 탭바 아이템이 클릭되는 효과를 줄 수 있을까?
        case 1:
            print("💚 GRID 선택됨!")
        default:
            fatalError()
        }
    }
    
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

