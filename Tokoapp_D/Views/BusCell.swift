//
//  BusCell.swift
//  Tokoapp_D
//
//  Created by 梅子豪 on 2025/09/15.
//

import UIKit
class BusCell: UITableViewCell {
    static let identifier = "BusCell"
    private let container: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.layer.masksToBounds = false
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .secondarySystemBackground
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 4
        return v
    }()
    private let iconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "bus"))
        iv.tintColor = .systemBlue
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let timeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let placeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let countdownLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        l.textColor = .systemRed
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .right
        return l
    }()
    private var isHighlightedNext: Bool = false
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(container)
        container.addSubview(iconView)
        container.addSubview(timeLabel)
        container.addSubview(placeLabel)
        container.addSubview(countdownLabel)
        
        NSLayoutConstraint.activate([
            
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            
            timeLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            timeLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),

            placeLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            placeLabel.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 8),
            
            countdownLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            countdownLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            countdownLabel.leadingAnchor.constraint(greaterThanOrEqualTo: timeLabel.trailingAnchor, constant: 8)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(timeText: String, placeText: String, countdownText: String, isNext: Bool, isExpired: Bool) {
        timeLabel.text = timeText
        placeLabel.text = placeText
        countdownLabel.text = countdownText
        setNextHighlight(isNext)
        
        if isExpired {
            timeLabel.textColor = .secondaryLabel
            placeLabel.textColor = .tertiaryLabel
        } else {
            timeLabel.textColor = .label
            placeLabel.textColor = .secondaryLabel
        }
    }
    func updateCountdown(_ countdownText: String, isNext: Bool) {
        countdownLabel.text = countdownText
        setNextHighlight(isNext)
    }
    private func setNextHighlight(_ next: Bool) {
        guard next != isHighlightedNext else { return }
        isHighlightedNext = next
        if next {
            container.backgroundColor = UIColor.systemRed.withAlphaComponent(0.16)
        } else {
            container.backgroundColor = .secondarySystemBackground
        }
    }
}
