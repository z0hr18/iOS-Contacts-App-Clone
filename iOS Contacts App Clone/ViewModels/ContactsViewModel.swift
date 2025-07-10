//
//  ContactsViewModel.swift
//  iOS Contacts App Clone
//
//  Created by Zohra Guliyeva on 7/3/25.
//

import Foundation
import Contacts

final class ContactsViewModel {
    // All contacts
    private(set) var contacts: [ContactUsers] = []
    // For sections
    private(set) var sectionTitles: [String] = []
    private(set) var sectionedContacts: [[ContactUsers]] = []
    
    private let contactStore = CNContactStore()
    
    private(set) var filteredSectionTitles: [String] = []
    private(set) var filteredSectionedContacts: [[ContactUsers]] = []
    private var isFiltering = false
    
    // Permission and result
    func requestPermissionAndFetchContacts(completion: @escaping (Bool) -> Void) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .notDetermined:
            contactStore.requestAccess(for: .contacts) { [weak self] granted, _ in
                if granted {
                    self?.fetchContacts {
                        DispatchQueue.main.async { completion(true) }
                    }
                } else {
                    DispatchQueue.main.async { completion(false) }
                }
            }
        case .authorized, .limited:
            fetchContacts {
                DispatchQueue.main.async { completion(true) }
            }
        default:
            DispatchQueue.main.async { completion(false) }
        }
    }
    
    func fetchContacts(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let keys: [CNKeyDescriptor] = [
                CNContactIdentifierKey as CNKeyDescriptor,
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactImageDataKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor
            ]
            var models: [ContactUsers] = []
            let request = CNContactFetchRequest(keysToFetch: keys)
            do {
                try self.contactStore.enumerateContacts(with: request) { contact, _ in
                    let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
                    let phones = contact.phoneNumbers.map { $0.value.stringValue }
                    let emails = contact.emailAddresses.map { $0.value as String }
                    let model = ContactUsers(
                        identifier: contact.identifier,
                        fullName: fullName,
                        imageData: contact.imageData,
                        phoneNumbers: phones,
                        emailAddresses: emails
                    )
                    models.append(model)
                }
                self.contacts = models
                self.makeSections()
            } catch {
                print("Unable to load contacts: \(error)")
            }
            DispatchQueue.main.async { completion() }
        }
    }
    
    // Alphabetical section structure
    private func makeSections() {
        let grouped: [String: [ContactUsers]] = Dictionary(grouping: contacts) { contact in
            let trimmedName = contact.fullName.trimmingCharacters(in: .whitespaces)
            if trimmedName.isEmpty {
                return "#"
            }
            guard let first = trimmedName.first else { return "#" }
            let letter = String(first).uppercased()
            return letter.rangeOfCharacter(from: .letters) != nil ? letter : "#"
        }
        // # always last section
        let sortedKeys = grouped.keys.sorted {
            if $0 == "#" { return false }
            if $1 == "#" { return true }
            return $0 < $1
        }
        sectionTitles = sortedKeys
        sectionedContacts = sortedKeys.map { grouped[$0]!.sorted { $0.fullName < $1.fullName } }
    }
    
    // Search filter
    func filterContacts(query: String?) {
        guard let query = query, !query.isEmpty else {
            isFiltering = false
            filteredSectionTitles = sectionTitles
            filteredSectionedContacts = sectionedContacts
            return
        }
        
        isFiltering = true
        var tempSectionTitles: [String] = []
        var tempSectionedContacts: [[ContactUsers]] = []
        
        for (i, section) in sectionedContacts.enumerated() {
            let filtered = section.filter {
                $0.fullName.lowercased().contains(query.lowercased())
            }
            if !filtered.isEmpty {
                tempSectionTitles.append(sectionTitles[i])
                tempSectionedContacts.append(filtered)
            }
        }
        filteredSectionTitles = tempSectionTitles
        filteredSectionedContacts = tempSectionedContacts
    }
    
    func numberOfSections() -> Int {
        isFiltering ? filteredSectionTitles.count : sectionTitles.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        isFiltering ? filteredSectionedContacts[section].count : sectionedContacts[section].count
    }
    
    func titleForHeader(in section: Int) -> String? {
        isFiltering ? filteredSectionTitles[section] : sectionTitles[section]
    }
    
    func contact(at indexPath: IndexPath) -> ContactUsers {
        isFiltering ? filteredSectionedContacts[indexPath.section][indexPath.row] : sectionedContacts[indexPath.section][indexPath.row]
    }
}
