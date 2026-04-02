//
//  BusRoutesContainerViewController.swift
//  Tokoapp_D
//
//  Created by 梅子豪 on 2025/09/16.
//

import UIKit

class BusRoutesContainerViewController: UIViewController {

    let timetableType: BusTimetableType
    private let routes: [BusRoute]

    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    init(routes: [BusRoute], timetableType: BusTimetableType) {
        self.routes = routes
        self.timetableType = timetableType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)

        // 调整约束，让 StackView 从安全区域开始布局
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        setupBusListControllers()
    }

    private func setupBusListControllers() {
        // 交换 BusListView 的创建顺序
        let reversedRoutes = routes.reversed()
        for route in reversedRoutes {
            let vc = BusListViewController(route: route, timetableType: timetableType)
            addChild(vc)
            stackView.addArrangedSubview(vc.view)
            vc.didMove(toParent: self)
        }
    }
}
