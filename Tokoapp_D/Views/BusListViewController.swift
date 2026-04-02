//
//  BusListViewController.swift
//  Tokoapp_D
//
//  Created by 梅子豪 on 2025/09/09.
//

import UIKit

class BusListViewController: UITableViewController {
    
    let route: BusRoute
    let timetableType: BusTimetableType
    
    private struct UpcomingItem {
        let date: Date
        let timeText: String
        let place: String
        var isExpired: Bool
        var isNext: Bool
    }
    
    private var allParsedItems: [UpcomingItem] = []
    private var upcoming: [UpcomingItem] = []
    private var timer: Timer?

    init(route: BusRoute, timetableType: BusTimetableType) {
        self.route = route
        self.timetableType = timetableType
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 60
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        
        tableView.tableFooterView = UIView()
        
        tableView.register(BusCell.self, forCellReuseIdentifier: BusCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EmptyCell")
        
        parseAllBuses()
        updateDisplayList()
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Data Parsing and Updates
    
    private func parseAllBuses() {
        let now = Date()
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let timetable = route.timetables[timetableType.rawValue] else {
            allParsedItems = []
            return
        }
        
        allParsedItems = timetable.compactMap { timeString in
            let components = timeString.split(separator: " ")
            guard let timePart = components.first else { return nil }
            let placePart = components.dropFirst().joined(separator: " ")
            
            let timeComponents = timePart.split(separator: ":").compactMap { Int($0) }
            guard timeComponents.count == 2, let hour = timeComponents.first, let minute = timeComponents.last else { return nil }
            
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            guard let busDate = calendar.date(from: dateComponents) else { return nil }
            
            return UpcomingItem(date: busDate, timeText: String(timePart), place: placePart, isExpired: busDate < now, isNext: false)
        }.sorted { $0.date < $1.date }
    }
    
    private func updateDisplayList() {
        let now = Date()
        
        guard !allParsedItems.isEmpty else {
            upcoming = []
            tableView.reloadData()
            return
        }
        
        // 找到第一个未来的班次
        guard let nextBusIndex = allParsedItems.firstIndex(where: { $0.date > now }) else {
            // 如果所有班次都已过期，显示最后4个班次
            upcoming = Array(allParsedItems.suffix(4))
            if let lastIndex = upcoming.indices.last {
                upcoming[lastIndex].isNext = true
            }
            tableView.reloadData()
            return
        }
        
        // 重置所有班次的 isNext 状态
        for i in allParsedItems.indices {
            allParsedItems[i].isNext = false
            allParsedItems[i].isExpired = (allParsedItems[i].date <= now)
        }
        
        // 标记下一个班次
        allParsedItems[nextBusIndex].isNext = true
        
        var tempUpcoming: [UpcomingItem] = []
        
        // 添加前一个已过期班次
        if nextBusIndex > 0 {
            tempUpcoming.append(allParsedItems[nextBusIndex - 1])
        }
        
        // 添加下一个班次和其后的两个班次
        for i in nextBusIndex..<min(nextBusIndex + 3, allParsedItems.count) {
            tempUpcoming.append(allParsedItems[i])
        }
        
        upcoming = tempUpcoming
        tableView.reloadData()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    @objc private func timerTick() {
        updateDisplayList()
    }
    
    private func formatCountdown(until date: Date) -> String {
        let interval = max(0, Int(date.timeIntervalSinceNow))
        let h = interval / 3600
        let m = (interval % 3600) / 60
        let s = interval % 60
        
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
    
    // MARK: - TableView DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return upcoming.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BusCell.identifier, for: indexPath) as? BusCell else {
            return UITableViewCell()
        }
        
        let item = upcoming[indexPath.row]
        let countdown = formatCountdown(until: item.date)
        
        cell.configure(timeText: item.timeText, placeText: item.place, countdownText: countdown, isNext: item.isNext, isExpired: item.isExpired)
        
        return cell
    }
    
    // MARK: - TableView Header
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .secondarySystemGroupedBackground
        
        let label = UILabel()
        label.text = route.name
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = DetailedTimetableViewController(route: route, timetableType: timetableType)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
