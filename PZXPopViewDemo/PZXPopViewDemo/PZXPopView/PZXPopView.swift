//
//  PZXPopView.swift
//  PZXPopViewDemo
//
//  Created by 彭祖鑫 on 2024/12/2.
//

import UIKit

class PZXPopView: UIView {

    // 存储弹窗中显示的项，每个项包含一个可选的图片和标题
    private var items: [(image: UIImage?, title: String)] = []
    
    // 箭头视图和表格视图
    private let arrowView = UIView()
    private let tableView = UITableView()
    
    // 选中某一项时的回调
    private var didSelectItem: ((Int) -> Void)?
    
    // 弹窗的偏移量，默认0.0
    var offsetX: CGFloat = 0.0
    private let arrowWidth = 20.0
    private let radius = 8.0

    // 弹窗的其他配置参数
    var arrowHeight: CGFloat = 10.0     // 箭头的高度
    var rowHeight: CGFloat = 50.0       // 每行的高度
    var contentWidth: CGFloat = 200.0   // 弹窗的宽度，外部可以自定义
    var alertBackgroundColor: UIColor?  // 弹窗的背景颜色
    var textColor: UIColor?             // 字体的颜色

    // 初始化方法，接收数据源和选中项时的回调
    init(
        items: [(image: UIImage?, title: String)],
        didSelectItem: ((Int) -> Void)?
    ) {
        super.init(frame: .zero)
        alertBackgroundColor = .red      // 默认背景颜色为红色
        textColor = .white               // 默认文字颜色为白色

        self.items = items               // 设置数据源
        self.didSelectItem = didSelectItem // 设置回调
        setupView()                      // 调用视图配置方法
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 配置视图
    private func setupView() {
        // 设置背景颜色透明并添加阴影效果
        self.backgroundColor = .clear
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        
        // 配置箭头视图
        arrowView.backgroundColor = alertBackgroundColor
        addSubview(arrowView)

        // 配置表格视图
        tableView.delegate = self
        tableView.dataSource = self
        tableView
            .register(
                PZXPopViewCell.self,
                forCellReuseIdentifier: "PZXPopViewCell"
            )
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = radius
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = false // 禁用滚动，确保弹窗内容在一个视图中显示
        addSubview(tableView)
    }

    // 布局子视图
    override func layoutSubviews() {
        super.layoutSubviews()

        // 根据数据项的数量动态计算表格的高度
        let tableHeight = CGFloat(items.count) * rowHeight
        tableView.frame = CGRect(
            x: 0,
            y: arrowHeight,
            width: contentWidth,
            height: tableHeight
        )
        
        // 动态更新箭头的位置
        updateArrowPosition()
    }

    // 更新箭头的形状和位置
    private func updateArrowPosition() {
        let arrowCenterX = contentWidth / 2 - offsetX // 箭头的中心X位置根据偏移量调整
        arrowView.frame = CGRect(
            x: arrowCenterX - arrowWidth/2,
            y: 0,
            width: arrowWidth,
            height: arrowHeight
        ) // 20是箭头宽度的一半
        arrowView.layer.mask = arrowMaskLayer() // 更新箭头的形状
    }

    // 创建箭头的遮罩层（形状）
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

    // 从按钮展示弹窗
    func show(from button: UIButton, isWindow: Bool = false) {
        guard let superview = button.superview else { return }

        //防止offsetX 设置的太大 到导致箭头 到view 之外了
        let maxOffsetX = (contentWidth / 2) - (arrowWidth / 2) - radius // 10 是箭头宽度的一半 8是圆角距离
        offsetX = min(max(-maxOffsetX, offsetX), maxOffsetX)
        
        // 确定弹窗应该添加到的父视图（是否是 window）
        let targetSuperview: UIView
        if isWindow {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(
                where: { $0.isKeyWindow
                }) {
                targetSuperview = keyWindow
            } else {
                targetSuperview = superview
            }
        } else {
            targetSuperview = superview
        }

        targetSuperview.addSubview(self) // 将弹窗添加到目标父视图

        // 将按钮的 frame 转换到父视图的坐标系
        let buttonFrame = button.convert(button.bounds, to: targetSuperview)
        let originY = buttonFrame.maxY + 5 // 弹窗的 Y 坐标，按钮下方偏移 5

        // 计算弹窗的 X 坐标，应用偏移量
        var originX = buttonFrame.midX - contentWidth / 2 + offsetX

        // 确保弹窗不会超出屏幕
        let screenWidth = UIScreen.main.bounds.width
        if originX < 0 { originX = 0 }
        if originX + contentWidth > screenWidth {
            originX = screenWidth - contentWidth
        }

        // 设置弹窗的位置和大小
        self.frame = CGRect(
            x: originX,
            y: originY,
            width: contentWidth,
            height: CGFloat(items.count) * rowHeight + arrowHeight
        )

        // 更新箭头位置
        updateArrowPosition()
    }

    // 隐藏弹窗
    func hide() {
        self.removeFromSuperview() // 从父视图中移除弹窗
    }
}

extension PZXPopView: UITableViewDelegate, UITableViewDataSource {
    // 表格视图的行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    // 配置每个单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PZXPopViewCell", for: indexPath) as? PZXPopViewCell else {
            return UITableViewCell() // 返回默认单元格
        }
        let item = items[indexPath.row]
        cell.selectionStyle = .none // 设置无选中效果
        cell.backgroundColor = alertBackgroundColor // 设置背景颜色
        cell.iconImageView.image = item.image // 设置图片
        cell.titleLabel.textColor = textColor // 设置文字颜色
        cell.titleLabel.text = item.title // 设置标题文本
        return cell
    }

    // 设置每行的高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }

    // 处理单元格点击事件
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        didSelectItem?(indexPath.row) // 调用选中项的回调
        hide() // 隐藏弹窗
    }
}
