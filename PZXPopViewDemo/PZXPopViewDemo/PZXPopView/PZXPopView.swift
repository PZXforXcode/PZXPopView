//
//  PZXPopView.swift
//  PZXPopViewDemo
//
//  Created by 彭祖鑫 on 2024/12/2.
//

import UIKit

class PZXPopView: UIView {

    private var items: [(image: UIImage?, title: String)] = []
    private let arrowView = UIView()
    private let tableView = UITableView()
    private var didSelectItem: ((Int) -> Void)?
    
    var offsetX: CGFloat = 0.0
    private let arrowWidth = 20.0
    private let radius = 8.0

    var arrowHeight: CGFloat = 10.0
    var rowHeight: CGFloat = 50.0
    var contentWidth: CGFloat = 200.0
    var alertBackgroundColor: UIColor?
    var textColor: UIColor?
    var popMaskViewBackgroundColor = UIColor.black.withAlphaComponent(0.5)
    
    // 新增属性，控制是否显示遮罩层
    var isShowMaskView: Bool = false
    
    // 遮罩层视图
    private var popMaskView: UIView?
    
    init(
        items: [(image: UIImage?, title: String)],
        didSelectItem: ((Int) -> Void)?
    ) {
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
        self.backgroundColor = .clear
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        
        arrowView.backgroundColor = alertBackgroundColor
        addSubview(arrowView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PZXPopViewCell.self, forCellReuseIdentifier: "PZXPopViewCell")
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = radius
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = false
        addSubview(tableView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let tableHeight = CGFloat(items.count) * rowHeight
        tableView.frame = CGRect(x: 0, y: arrowHeight, width: contentWidth, height: tableHeight)
        updateArrowPosition()
    }

    private func updateArrowPosition() {
        let arrowCenterX = contentWidth / 2 - offsetX
        arrowView.frame = CGRect(x: arrowCenterX - arrowWidth/2, y: 0, width: arrowWidth, height: arrowHeight)
        arrowView.layer.mask = arrowMaskLayer()
    }

    private func arrowMaskLayer() -> CAShapeLayer {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: arrowHeight))
        path.addLine(to: CGPoint(x: arrowWidth, y: arrowHeight))
        path.addLine(to: CGPoint(x: arrowWidth/2, y: 0))
        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        return shapeLayer
    }

    // 新增方法，添加遮罩层
    private func addMaskView(to targetSuperview: UIView) {
        popMaskView = UIView(frame: targetSuperview.bounds)
        popMaskView?.backgroundColor = popMaskViewBackgroundColor
        popMaskView?.isUserInteractionEnabled = true
        targetSuperview.addSubview(popMaskView!)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(maskViewTapped))
        popMaskView?.addGestureRecognizer(tapGesture)
    }

    // 遮罩层点击事件
    @objc private func maskViewTapped() {
//        hide()
        hide(animate: true)

    }

    // 显示弹窗
    func show(from button: UIButton, isWindow: Bool = false) {
        guard let superview = button.superview else { return }

        let maxOffsetX = (contentWidth / 2) - (arrowWidth / 2) - radius
        offsetX = min(max(-maxOffsetX, offsetX), maxOffsetX)

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

        if isShowMaskView {
            addMaskView(to: targetSuperview) // 添加遮罩层
        }

        targetSuperview.addSubview(self)

        let buttonFrame = button.convert(button.bounds, to: targetSuperview)
        let originY = buttonFrame.maxY + 5
        var originX = buttonFrame.midX - contentWidth / 2 + offsetX

        let screenWidth = UIScreen.main.bounds.width
        if originX < 0 { originX = 0 }
        if originX + contentWidth > screenWidth {
            originX = screenWidth - contentWidth
        }

        self.frame = CGRect(x: originX, y: originY, width: contentWidth, height: CGFloat(items.count) * rowHeight + arrowHeight)
        updateArrowPosition()
    }
    
    func show(from button: UIButton, selfVC:UIViewController) {

        let maxOffsetX = (contentWidth / 2) - (arrowWidth / 2) - radius
        offsetX = min(max(-maxOffsetX, offsetX), maxOffsetX)
        let targetSuperview: UIView
        targetSuperview = selfVC.view

        if isShowMaskView {
            addMaskView(to: targetSuperview) // 添加遮罩层
        }
        targetSuperview.addSubview(self)

        let buttonFrame = button.convert(button.bounds, to: targetSuperview)
        let originY = buttonFrame.maxY + 5
        var originX = buttonFrame.midX - contentWidth / 2 + offsetX

        let screenWidth = UIScreen.main.bounds.width
        if originX < 0 { originX = 0 }
        if originX + contentWidth > screenWidth {
            originX = screenWidth - contentWidth
        }

        self.frame = CGRect(x: originX, y: originY, width: contentWidth, height: CGFloat(items.count) * rowHeight + arrowHeight)
        updateArrowPosition()
    }

    func hide(animate: Bool = false) {
        if animate {
            // 使用动画来隐藏弹窗和遮罩层
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0.0
                self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                self.removeFromSuperview()
                self.popMaskView?.removeFromSuperview() // 移除遮罩层
                // 恢复初始状态
                self.alpha = 1.0
                self.transform = .identity
            }
        } else {
            // 无动画，直接移除弹窗和遮罩层
            self.removeFromSuperview()
            popMaskView?.removeFromSuperview()
            // 无动画时也确保恢复初始状态
            self.alpha = 1.0
            self.transform = .identity
        }
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
        hide(animate: true)
    }
}
