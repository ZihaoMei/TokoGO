//
//  BusTimetablePageViewController.swift
//  Tokoapp_D
//
//  Created by 梅子豪 on 2025/09/09.
//

import UIKit

class BusTimetablePageViewController: UIPageViewController {
    
    private let routes: [BusRoute]
    private lazy var controllers: [BusRoutesContainerViewController] = {
        let allTimetableTypes = BusTimetableType.allCases
        return allTimetableTypes.map { type in
            BusRoutesContainerViewController(routes: routes, timetableType: type)
        }
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: BusTimetableType.allCases.map { $0.title })
        sc.selectedSegmentIndex = BusTimetableType.allCases.firstIndex(of: .todayType()) ?? 0
        sc.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return sc
    }()
    
    init(routes: [BusRoute]) {
        self.routes = routes
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "メニュー", style: .plain, target: self, action: #selector(menuTapped))
        navigationItem.titleView = segmentedControl
        
        if let initialController = controllers.first(where: { $0.timetableType == .todayType() }) {
            setViewControllers([initialController], direction: .forward, animated: false)
        }
    }
    
    @objc private func menuTapped() {
        NotificationCenter.default.post(name: .toggleSidebar, object: nil)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let newIndex = sender.selectedSegmentIndex
        guard let currentVC = viewControllers?.first as? BusRoutesContainerViewController,
              let currentIndex = controllers.firstIndex(of: currentVC),
              newIndex != currentIndex else {
            return
        }
        
        let direction: UIPageViewController.NavigationDirection = newIndex > currentIndex ? .forward : .reverse
        setViewControllers([controllers[newIndex]], direction: direction, animated: true, completion: nil)
    }
}

// MARK: - UIPageViewControllerDataSource & Delegate
extension BusTimetablePageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let containerVC = viewController as? BusRoutesContainerViewController,
              let currentIndex = controllers.firstIndex(of: containerVC),
              currentIndex > 0 else {
            return nil
        }
        return controllers[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let containerVC = viewController as? BusRoutesContainerViewController,
              let currentIndex = controllers.firstIndex(of: containerVC),
              currentIndex < controllers.count - 1 else {
            return nil
        }
        return controllers[currentIndex + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if completed, let visible = viewControllers?.first, let containerVC = visible as? BusRoutesContainerViewController, let index = BusTimetableType.allCases.firstIndex(of: containerVC.timetableType) {
            segmentedControl.selectedSegmentIndex = index
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return controllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return controllers.firstIndex(where: { $0.timetableType == .todayType() }) ?? 0
    }
}
