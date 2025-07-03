//
//  ContactDetailViewModel.swift
//  iOS Contacts App Clone
//
//  Created by Zohra Guliyeva on 7/4/25.
//

import Foundation

final class ContactDetailViewModel {
    let contact: ContactUsers
    
    init(contact: ContactUsers) {
        self.contact = contact
    }
    
    var fullName: String {
        contact.fullName
    }
    
    var imageData: Data? {
        contact.imageData
    }
    
    var phoneNumbers: [String] {
        contact.phoneNumbers
    }
    
    var emailAddresses: [String] {
        contact.emailAddresses
    }
}
