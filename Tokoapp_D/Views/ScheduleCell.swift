//
//  ScheduleCell.swift
//  Tokoapp_D
//
//  Created by 梅子豪 on 2025/09/17.
//

import UIKit

class ScheduleCell: UICollectionViewCell {
    static let identifier = "ScheduleCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 11)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(locationLabel)
        
        contentView.addSubview(stackView)
        
        let padding: CGFloat = 4
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with text: String?, location: String?, isHeader: Bool, isTimeHeader: Bool) {
        if isHeader {
            locationLabel.text = nil
            contentView.backgroundColor = .secondarySystemGroupedBackground
            contentView.layer.borderWidth = 0
            
            if isTimeHeader {
                let parts = text?.components(separatedBy: "\n")
                if let mainText = parts?.first, let subText = parts?.last {
                    let attributedString = NSMutableAttributedString(string: mainText, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .bold)])
                    let smallFont = UIFont.systemFont(ofSize: 10)
                    attributedString.append(NSAttributedString(string: "\n" + subText, attributes: [.font: smallFont]))
                    nameLabel.attributedText = attributedString
                } else {
                    nameLabel.text = text
                }
            } else {
                nameLabel.font = .boldSystemFont(ofSize: 14)
                nameLabel.text = text
            }
        } else {
            nameLabel.text = text
            locationLabel.text = location
            contentView.backgroundColor = .systemBackground
            contentView.layer.borderWidth = 0.5
            nameLabel.font = .systemFont(ofSize: 13, weight: .semibold)
            locationLabel.font = .systemFont(ofSize: 11)
        }
    }
}
