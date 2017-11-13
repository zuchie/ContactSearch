//
//  Contacts.swift
//  ContactsSearch
//
//  Created by Zhe Cui on 11/11/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import Contacts

enum ContactContent {
    case phoneNumber
    case email
}

struct Contact {
    var name: String?
    var contentLabel: String? // "Home" or "Office"
    var contentValue: String?
    var contentType: ContactContent? // Phone number or email address
}

class ContactList {
    
    static func getPhoneNumbersAndEmails(_ matchingName: String, completion: @escaping ([Contact]) -> ()) {
        
        getContact(matchingName) { (contacts) in
            var phoneNumbersAndEmails: [Contact] = []
            
            contacts.forEach { (contact) in
                let fullName = CNContactFormatter.string(from: contact, style: .fullName)
                
                if contact.isKeyAvailable(CNContactEmailAddressesKey) {
                    contact.emailAddresses.forEach({ (email) in
                        phoneNumbersAndEmails.append(Contact(name: fullName ?? String(email.value), contentLabel: email.label, contentValue: String(email.value), contentType: .email))
                    })
                }
                if contact.isKeyAvailable(CNContactPhoneNumbersKey) {
                    contact.phoneNumbers.forEach({ (phoneNumber) in
                        phoneNumbersAndEmails.append(Contact(name: fullName ?? phoneNumber.value.stringValue, contentLabel: phoneNumber.label, contentValue: phoneNumber.value.stringValue, contentType: .phoneNumber))
                    })
                }
                
            }

            completion(phoneNumbersAndEmails)
        }
    }
    
    private static func getContact(_ matchingName: String, completion: @escaping ([CNContact]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let predicate = CNContact.predicateForContacts(matchingName: matchingName)
            let keysToFetch: [CNKeyDescriptor] = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor]
            let store = CNContactStore()
            
            var unifiedContacts: [CNContact] = []
            do {
                unifiedContacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            } catch {
                print(error)
            }
            
            DispatchQueue.main.async {
                completion(unifiedContacts)
            }
        }
    }
    
}
