//
//  PZXPopViewCellTableViewCell.swift
//  PZXPopViewDemo
//
//  Created by 彭祖鑫 on 2024/12/2.
//

import UIKit

class PZXPopViewCell: UITableViewCell {

    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = 24
        iconImageView.frame = CGRect(x: 15, y: (contentView.frame.height - imageSize) / 2, width: imageSize, height: imageSize)
        titleLabel.frame = CGRect(x: iconImageView.frame.maxX + 10, y: 0, width: contentView.frame.width - iconImageView.frame.maxX - 25, height: contentView.frame.height)
    }
}

