//
//  SidebarViewController.swift
//  Tokoapp_D
//
//  Created by 梅子豪 on 2025/09/09.
//

import UIKit

// 修复：SidebarItem 现在只包含静态选项
enum SidebarItem: String, CaseIterable {
    case timetable = "バス時刻表"
    case schedule = "時間割"
    case calendar = "大学カレンダー"
    case myWaseda = "MyWaseda"
    case settings = "设置"
    case about = "About"

    var iconName: String {
        switch self {
        case .timetable: return "bus"
        case .schedule: return "text.book.closed"
        case .calendar: return "calendar"
        case .myWaseda: return "person.badge.shield.checkmark"
        case .settings: return "gear"
        case .about: return "info.circle"
        }
    }
}

class SidebarViewController: UITableViewController {
    
    // 移除 routes 属性，因为不再需要动态生成路线选项
    private let items = SidebarItem.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "メニュー"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.rawValue
        cell.imageView?.image = UIImage(systemName: item.iconName)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        NotificationCenter.default.post(name: .sidebarSelection, object: nil, userInfo: ["item": item.rawValue])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
