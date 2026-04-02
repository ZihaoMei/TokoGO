//
//  DetailedTimetableViewController.swift
//  Tokoapp_D
//
//  Created by 梅子豪 on 2025/09/16.
//

import UIKit

class DetailedTimetableViewController: UITableViewController {
    
    let route: BusRoute
    let timetableType: BusTimetableType
    
    private struct DetailedItem {
        let date: Date
        let timeText: String
        let place: String
        var isExpired: Bool
        var isNext: Bool
    }
    
    private var allParsedItems: [DetailedItem] = []
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
        title = timetableType.title
        tableView.rowHeight = 60
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.register(BusCell.self, forCellReuseIdentifier: BusCell.identifier)
        
        parseAllBuses()
        scrollToNextBus()
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func parseAllBuses() {
        let now = Date()
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let times = route.timetables[timetableType.rawValue], !times.isEmpty else {
            allParsedItems = []
            return
        }
        
        var parsedItems: [DetailedItem] = []
        for entry in times {
            let parts = entry.split(separator: " ")
            guard let timePart = parts.first else { continue }
            
            let timeString = String(timePart.split(separator: "~").first ?? timePart)
            
            guard let t = formatter.date(from: timeString) else { continue }
            
            var comps = calendar.dateComponents([.year, .month, .day], from: now)
            comps.hour = calendar.component(.hour, from: t)
            comps.minute = calendar.component(.minute, from: t)
            let fullDate = calendar.date(from: comps) ?? t

            let place = parts.count > 1 ? String(parts[1]) : ""
            parsedItems.append(DetailedItem(date: fullDate, timeText: timeString, place: place, isExpired: fullDate <= now, isNext: false))
        }
        
        allParsedItems = parsedItems.sorted { $0.date < $1.date }
        
        // 标记下一个班次
        if let firstFutureIndex = allParsedItems.firstIndex(where: { !$0.isExpired }) {
            allParsedItems[firstFutureIndex].isNext = true
        } else if !allParsedItems.isEmpty {
            allParsedItems[allParsedItems.count - 1].isNext = true
        }
    }
    
    private func scrollToNextBus() {
        if let nextBusIndex = allParsedItems.firstIndex(where: { $0.isNext }) {
            let indexPath = IndexPath(row: nextBusIndex, section: 0)
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    @objc private func timerTick() {
        let now = Date()
        
        // 更新过期状态
        for i in 0..<allParsedItems.count {
            if allParsedItems[i].date <= now {
                allParsedItems[i].isExpired = true
            }
        }
        
        // 检查下一个班次是否需要更新
        if let nextBusIndex = allParsedItems.firstIndex(where: { $0.isNext }),
           allParsedItems[nextBusIndex].isExpired {
            
            // 找到新的下一个班次并刷新
            if let newNextBusIndex = allParsedItems.firstIndex(where: { !$0.isExpired }) {
                allParsedItems[nextBusIndex].isNext = false
                allParsedItems[newNextBusIndex].isNext = true
                tableView.reloadData()
                scrollToNextBus()
            }
        }
        
        updateVisibleCellsCountdown()
    }
    
    private func updateVisibleCellsCountdown() {
        guard let indexPaths = tableView.indexPathsForVisibleRows else { return }
        for ip in indexPaths {
            if ip.row < allParsedItems.count {
                let item = allParsedItems[ip.row]
                if let cell = tableView.cellForRow(at: ip) as? BusCell {
                    let countdown = formatCountdown(until: item.date)
                    cell.updateCountdown(countdown, isNext: item.isNext)
                }
            }
        }
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
        return allParsedItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BusCell.identifier, for: indexPath) as? BusCell else {
            return UITableViewCell()
        }
        
        let item = allParsedItems[indexPath.row]
        let countdown = formatCountdown(until: item.date)
        
        cell.configure(timeText: item.timeText, placeText: item.place, countdownText: countdown, isNext: item.isNext, isExpired: item.isExpired)
        return cell
    }
}
