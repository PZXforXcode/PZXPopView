//
//  PZXPopView.swift
//  PZXPopViewDemo
//
//  Created by 彭祖鑫 on 2024/12/2.
//

import UIKit

import UIKit

class PZXPopView: UIView {

    private var items: [(image: UIImage?, title: String)] = []
    private var arrowHeight: CGFloat = 10.0
    private var rowHeight: CGFloat = 50.0
    private var contentWidth: CGFloat = 200.0

    private let arrowView = UIView()
    private let tableView = UITableView()
    private var didSelectItem: ((Int) -> Void)?
    
    
    var offsetX: CGFloat = 0.0 // 新增偏移量属性，默认为 0

    var alertBackgroundColor: UIColor?
    var textColor: UIColor?

    // 初始化方法
    init(items: [(image: UIImage?, title: String)], didSelectItem: ((Int) -> Void)?) {
        super.init(frame: .zero)
        alertBackgroundColor = .red
        textColor = .white

        self.items = items
        self.didSelectItem = didSelectItem
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // 设置背景颜色和阴影
        self.backgroundColor = .clear
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4

        // 配置箭头
        arrowView.backgroundColor = alertBackgroundColor
        addSubview(arrowView)

        // 配置表格
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PZXPopViewCell.self, forCellReuseIdentifier: "PZXPopViewCell")
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 8
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = false
        addSubview(tableView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let tableHeight = CGFloat(items.count) * rowHeight
        tableView.frame = CGRect(x: 0, y: arrowHeight, width: contentWidth, height: tableHeight)
    }

    private func arrowMaskLayer() -> CAShapeLayer {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: arrowHeight))
        path.addLine(to: CGPoint(x: 20, y: arrowHeight))
        path.addLine(to: CGPoint(x: 10, y: 0))
        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        return shapeLayer
    }

    func show(from button: UIButton, isWindow: Bool = false) {
        guard let superview = button.superview else { return }

        let targetSuperview: UIView
        if isWindow {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                targetSuperview = keyWindow
            } else {
                targetSuperview = superview
            }
        } else {
            targetSuperview = superview
        }

        targetSuperview.addSubview(self)

        let buttonFrame = button.convert(button.bounds, to: targetSuperview)
        let originY = buttonFrame.maxY + 5

        // 计算弹窗的X坐标，应用偏移量
        var originX = buttonFrame.midX - contentWidth / 2 + offsetX

        // 确保弹窗不会超出屏幕
        let screenWidth = UIScreen.main.bounds.width
        if originX < 0 { originX = 0 }
        if originX + contentWidth > screenWidth {
            originX = screenWidth - contentWidth
        }

        self.frame = CGRect(x: originX, y: originY, width: contentWidth, height: CGFloat(items.count) * rowHeight + arrowHeight)

        // 动态设置箭头的位置
        let arrowCenterX = buttonFrame.midX - originX // 箭头相对于弹窗的位置
        arrowView.frame = CGRect(x: arrowCenterX - 10, y: 0, width: 20, height: arrowHeight) // 20是箭头宽度的一半
        arrowView.layer.mask = arrowMaskLayer() // 更新箭头的形状
    }



    func hide() {
        self.removeFromSuperview()
    }
}

extension PZXPopView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PZXPopViewCell", for: indexPath) as? PZXPopViewCell else {
             return UITableViewCell()
         }
         let item = items[indexPath.row]
        cell.selectionStyle = .none
        cell.backgroundColor = alertBackgroundColor
         cell.iconImageView.image = item.image
        cell.titleLabel.textColor = textColor
         cell.titleLabel.text = item.title
         return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectItem?(indexPath.row)
        hide()
    }
}

