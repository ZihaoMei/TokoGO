//
//  RootViewController.swift
//  Tokoapp_D
//
//  Created by 梅子豪 on 2025/09/15.
//

import UIKit

class RootViewController: UIViewController {

    private let sidebarVC = SidebarViewController()
    private let timetableVC: BusTimetablePageViewController
    
    private lazy var contentNav: UINavigationController = {
        return UINavigationController()
    }()

    private var sidebarLeading: NSLayoutConstraint!
    private var sidebarWidth: CGFloat { view.bounds.width * 0.72 }
    private var isOpen = false

    private let overlayView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let allRoutes: [BusRoute]

    init(routes: [BusRoute]) {
        self.allRoutes = routes
        self.timetableVC = BusTimetablePageViewController(routes: routes)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        addChild(contentNav)
        view.addSubview(contentNav.view)
        contentNav.didMove(toParent: self)
        contentNav.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentNav.view.topAnchor.constraint(equalTo: view.topAnchor),
            contentNav.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentNav.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentNav.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(overlayView)
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        let tap = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        overlayView.addGestureRecognizer(tap)

        addChild(sidebarVC)
        view.addSubview(sidebarVC.view)
        sidebarVC.didMove(toParent: self)
        sidebarVC.view.translatesAutoresizingMaskIntoConstraints = false
        sidebarLeading = sidebarVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -sidebarWidth)
        NSLayoutConstraint.activate([
            sidebarLeading,
            sidebarVC.view.widthAnchor.constraint(equalToConstant: sidebarWidth),
            sidebarVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            sidebarVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(toggleSidebar), name: .toggleSidebar, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSidebarSelection(_:)), name: .sidebarSelection, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceRotate), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        contentNav.setViewControllers([timetableVC], animated: false)
    }
    
    @objc private func overlayTapped() {
        if isOpen { toggleSidebar() }
    }
    
    @objc func toggleSidebar() {
        let w = view.bounds.width * 0.72
        sidebarLeading.constant = isOpen ? -w : 0
        overlayView.isHidden = false
        UIView.animate(withDuration: 0.28, delay: 0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
            self.overlayView.backgroundColor = UIColor.black.withAlphaComponent(self.isOpen ? 0.0 : 0.35)
        } completion: { _ in
            if self.isOpen { self.overlayView.isHidden = true }
            self.isOpen.toggle()
        }
    }
    
    @objc private func handleSidebarSelection(_ note: Notification) {
        if let info = note.userInfo, let raw = info["item"] as? String {
            if self.isOpen { toggleSidebar() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) { [weak self] in
                guard let self = self else { return }
                
                var newVC: UIViewController
                
                switch raw {
                case SidebarItem.timetable.rawValue:
                    newVC = self.timetableVC
                case SidebarItem.schedule.rawValue:
                    newVC = ScheduleViewController()
                case SidebarItem.calendar.rawValue:
                    newVC = PDFViewerViewController(pdfFileName: "早稲田大学2025年カレンダー")
                case SidebarItem.myWaseda.rawValue:
                    if let url = URL(string: "https://my.waseda.jp") {
                        UIApplication.shared.open(url)
                    }
                    return
                case SidebarItem.settings.rawValue:
                    newVC = PlaceholderViewController(title: "设置")
                case SidebarItem.about.rawValue:
                    newVC = PlaceholderViewController(title: "About")
                default:
                    return
                }
                
                self.contentNav.setViewControllers([newVC], animated: false)
                
                // 为所有新页面添加菜单按钮
                if newVC != self.timetableVC {
                    newVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "メニュー", style: .plain, target: self, action: #selector(self.toggleSidebar))
                }
            }
        }
    }
    
    @objc private func onDeviceRotate() {
        let w = view.bounds.width * 0.72
        sidebarLeading.constant = isOpen ? 0 : -w
        overlayView.isHidden = !isOpen
        if isOpen { overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.35) }
        view.layoutIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
