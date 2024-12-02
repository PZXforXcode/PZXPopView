//
//  ViewController.swift
//  PZXPopViewDemo
//
//  Created by 彭祖鑫 on 2024/12/2.
//

import UIKit

class ViewController: UIViewController {

    private let popButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("菜单", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        return button
    }()

    private var popView: PZXPopView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan

        // 配置按钮
        popButton.frame = CGRect(x: view.frame.width - 160, y: 100, width: 60, height: 40)
        popButton.addTarget(self, action: #selector(showPopView), for: .touchUpInside)
        view.addSubview(popButton)
        
        let items = [
            (UIImage(systemName: "star"), "收藏"),
            (UIImage(systemName: "square.and.arrow.up"), "分享"),
            (UIImage(systemName: "trash"), "删除")
        ]
        
         popView = PZXPopView(items: items) { index in
            print("选择了第 \(index) 项")
        }
        popView?.contentWidth = 140 
    }

    @objc private func showPopView() {
        
        popView?.offsetX = 100
        popView?.show(from: popButton)

    }
}


