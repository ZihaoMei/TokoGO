//
//  ScheduleViewController.swift
//  Tokoapp_D
//
//  Created by 梅子豪 on 2025/09/17.
//

import UIKit

class ScheduleViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let timeSlots = ["1時限\n8:50～10:30", "2時限\n10:40～12:20", "3時限\n13:10～14:50", "4時限\n15:05～16:45", "5時限\n17:00～18:40", "6時限\n18:55～20:35"]
    private let weekdays = ["時限/曜日", "月曜", "火曜", "水曜", "木曜", "金曜", "土曜"]
    
    private var courses: [[Course?]] = Array(repeating: Array(repeating: nil, count: 6), count: 6)
    
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "時間割"
        view.backgroundColor = .systemGroupedBackground
        setupCollectionView()
        
        loadCourses()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "メニュー", style: .plain, target: self, action: #selector(menuTapped))
    }
    
    @objc private func menuTapped() {
        NotificationCenter.default.post(name: .toggleSidebar, object: nil)
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 8
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ScheduleCell.self, forCellWithReuseIdentifier: ScheduleCell.identifier)
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }
    
    private func loadCourses() {
        if let savedData = UserDefaults.standard.data(forKey: "savedCourses"),
           let decodedCourses = try? JSONDecoder().decode([[Course?]].self, from: savedData) {
            courses = decodedCourses
        }
    }
    
    private func saveCourses() {
        if let encoded = try? JSONEncoder().encode(courses) {
            UserDefaults.standard.set(encoded, forKey: "savedCourses")
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weekdays.count * (timeSlots.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScheduleCell.identifier, for: indexPath) as! ScheduleCell
        
        let row = indexPath.item / weekdays.count
        let col = indexPath.item % weekdays.count
        
        // Header cells
        if row == 0 || col == 0 {
            let isTimeHeader = (col == 0) && (row > 0)
            let text = (row == 0) ? weekdays[col] : timeSlots[row - 1]
            cell.configure(with: text, location: nil, isHeader: true, isTimeHeader: isTimeHeader)
        } else {
            // Course cells
            let course = courses[row - 1][col - 1]
            cell.configure(with: course?.name, location: course?.location, isHeader: false, isTimeHeader: false)
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.bounds.width - 16
        let col = indexPath.item % weekdays.count
        let row = indexPath.item / weekdays.count

        let firstColWidth: CGFloat = 80
        let otherColWidth = (totalWidth - firstColWidth - CGFloat(weekdays.count - 2) * 4) / CGFloat(weekdays.count - 1)
        
        let itemWidth = (col == 0) ? firstColWidth : otherColWidth
        let itemHeight: CGFloat = (row == 0) ? 40 : 100
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.item / weekdays.count
        let col = indexPath.item % weekdays.count
        
        if row > 0 && col > 0 {
            let inputVC = CourseInputViewController()
            inputVC.course = courses[row - 1][col - 1]
            inputVC.onSave = { [weak self] newCourse in
                self?.courses[row - 1][col - 1] = newCourse
                self?.saveCourses()
                self?.collectionView.reloadItems(at: [indexPath])
            }
            
            let nav = UINavigationController(rootViewController: inputVC)
            present(nav, animated: true, completion: nil)
        }
    }
}
