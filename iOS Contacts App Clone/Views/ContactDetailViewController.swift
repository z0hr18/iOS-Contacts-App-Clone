//
//  ContactDetailViewController.swift
//  iOS Contacts App Clone
//
//  Created by Zohra Guliyeva on 7/3/25.
//

import UIKit

final class ContactDetailViewController: UIViewController {
    private let viewModel: ContactDetailViewModel
    
    // UI
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 60
        image.layer.masksToBounds = true
        image.backgroundColor = .secondarySystemBackground
        return image
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        return label
    }()
    
    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    init(viewModel: ContactDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        configureData()
    }
    
    // UI configutation
    private func setupUI() {
        [imageView,
         nameLabel,
         phoneLabel,
         emailLabel].forEach(view.addSubview)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalToConstant: 120),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            phoneLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            phoneLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            phoneLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            emailLabel.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 12),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    // Data to UI
    private func configureData() {
        nameLabel.text = viewModel.fullName
        phoneLabel.text = viewModel.phoneNumbers.first ?? "No phone"
        emailLabel.text = viewModel.emailAddresses.first ?? "No email"
        
        if let imageData = viewModel.imageData, let image = UIImage(data: imageData) {
            imageView.image = image
        } else {
            imageView.image = UIImage(systemName: "person.crop.circle.fill")
        }
    }
}

