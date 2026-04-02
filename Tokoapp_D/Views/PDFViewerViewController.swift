//
//  ViewController.swift
//  Tokoapp_D
//
//  Created by 梅子豪 on 2025/09/09.
//

import UIKit
import PDFKit

class PDFViewerViewController: UIViewController {
    
    private let pdfView = PDFView()
    
    init(pdfFileName: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.title = pdfFileName
        
        guard let url = Bundle.main.url(forResource: "早稲田大学2025年カレンダー", withExtension: "pdf") else {
            print("❌ PDF file not found: 早稲田大学2025年カレンダー.pdf")
            return
        }
        
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(pdfView)
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        pdfView.autoScales = true
        
        // 移除返回按钮，改用菜单按钮
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "メニュー", style: .plain, target: self, action: #selector(menuTapped))
    }
    
    @objc private func menuTapped() {
        NotificationCenter.default.post(name: .toggleSidebar, object: nil)
    }
}
