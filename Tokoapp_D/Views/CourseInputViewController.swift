//
//  CourseInputViewController.swift
//  Tokoapp_D
//
//  Created by 梅子豪 on 2025/09/18.
//

import UIKit

class CourseInputViewController: UIViewController {

    var course: Course?
    var onSave: ((Course) -> Void)?
    
    private let nameField = UITextField()
    private let locationField = UITextField()
    private let teacherField = UITextField()
    private let notesTextView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "コース情報"

        setupViews()

        if let course = course {
            nameField.text = course.name
            locationField.text = course.location
            teacherField.text = course.teacher
            notesTextView.text = course.notes
        }
    }

    private func setupViews() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // 辅助函数，创建标签和输入框的组合视图
        let createLabeledField = { (label: String, field: UITextField) -> UIStackView in
            let labelView = UILabel()
            labelView.text = label
            labelView.font = UIFont.systemFont(ofSize: 15)
            
            field.borderStyle = .roundedRect
            field.placeholder = ""
            field.backgroundColor = .systemBackground
            field.clearButtonMode = .whileEditing
            field.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            let hStack = UIStackView(arrangedSubviews: [labelView, field])
            hStack.axis = .horizontal
            hStack.spacing = 8
            hStack.alignment = .center
            labelView.widthAnchor.constraint(equalToConstant: 60).isActive = true
            return hStack
        }
        
        let createLabeledTextView = { (label: String, textView: UITextView) -> UIStackView in
            let labelView = UILabel()
            labelView.text = label
            labelView.font = UIFont.systemFont(ofSize: 15)
            
            textView.layer.cornerRadius = 5
            textView.layer.borderColor = UIColor.lightGray.cgColor
            textView.layer.borderWidth = 0.5
            textView.backgroundColor = .systemBackground
            textView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
            let hStack = UIStackView(arrangedSubviews: [labelView, textView])
            hStack.axis = .horizontal
            hStack.spacing = 8
            hStack.alignment = .top
            labelView.widthAnchor.constraint(equalToConstant: 60).isActive = true
            return hStack
        }

        let nameStack = createLabeledField("講義", nameField)
        let locationStack = createLabeledField("教室", locationField)
        let teacherStack = createLabeledField("教授", teacherField)
        let notesStack = createLabeledTextView("メモ", notesTextView)

        stackView.addArrangedSubview(nameStack)
        stackView.addArrangedSubview(locationStack)
        stackView.addArrangedSubview(teacherStack)
        stackView.addArrangedSubview(notesStack)
        
        view.addSubview(stackView)
        
        let horizontalPadding: CGFloat = 20
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: horizontalPadding),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding)
        ])

        let saveButton = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(saveTapped))
        let cancelButton = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem = saveButton
        navigationItem.rightBarButtonItem = cancelButton
    }

    @objc private func saveTapped() {
        let newCourse = Course(
            name: nameField.text ?? "",
            location: locationField.text ?? "",
            teacher: teacherField.text ?? "",
            notes: notesTextView.text ?? ""
        )
        onSave?(newCourse)
        dismiss(animated: true, completion: nil)
    }

    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
}
