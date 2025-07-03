//
//  ContactsViewController.swift
//  iOS Contacts App Clone
//
//  Created by Zohra Guliyeva on 7/3/25.
//

import UIKit
import Contacts

final class ContactsViewController: UIViewController {
    private let viewModel = ContactsViewModel()
    
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search"
        search.autocapitalizationType = .none
        search.autocorrectionType = .no
        search.returnKeyType = .done
        return search
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "ContactCell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contacts"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
        
        setupTableView()
        setupSearchBar()
        askPermissionAndLoad()
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        tableView.tableHeaderView = searchBar
        searchBar.sizeToFit()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func askPermissionAndLoad() {
        viewModel.requestPermissionAndFetchContacts { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.tableView.reloadData()
                } else {
                    self?.showSettingsPrompt()
                }
            }
        }
    }
    
    private func showSettingsPrompt() {
        let alert = UIAlertController(
            title: "Permission required",
            message: "Access to contacts is blocked. Go to settings and allow it.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - TableView DataSource
extension ContactsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows(in: section)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.titleForHeader(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = viewModel.contact(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") ??
        UITableViewCell(style: .subtitle, reuseIdentifier: "ContactCell")
        
        let displayName = contact.fullName.trimmingCharacters(in: .whitespaces)
        if displayName.isEmpty, let firstPhone = contact.phoneNumbers.first {
            cell.textLabel?.text = firstPhone
            cell.detailTextLabel?.text = nil
        } else {
            cell.textLabel?.text = displayName
            cell.detailTextLabel?.text = contact.phoneNumbers.first
        }

        let size = CGSize(width: 28, height: 28)
        var finalImage: UIImage?

        if let imageData = contact.imageData, let image = UIImage(data: imageData) {
            // Manually resize
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            image.draw(in: CGRect(origin: .zero, size: size))
            finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        } else if let icon = UIImage(systemName: "person.crop.circle") {
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            icon.draw(in: CGRect(origin: .zero, size: size))
            finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }

        cell.imageView?.image = finalImage
        cell.imageView?.layer.cornerRadius = 14 // half size for full circle
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.contentMode = .scaleAspectFill

        return cell
    }

}
// MARK: - SearchBar and TableView Delegate
extension ContactsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterContacts(query: searchText)
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        viewModel.filterContacts(query: nil)
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
}

extension ContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = viewModel.contact(at: indexPath)
        let detailVM = ContactDetailViewModel(contact: contact)
        let detailVC = ContactDetailViewController(viewModel: detailVM)
        navigationController?.pushViewController(detailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

