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
    var givenName: String = ""
    var isGivenNameMatched = false
    var givenNameMatchingRange: Range<String.Index>?
    
    var middleName: String = ""
    var isMiddleNameMatched = false
    var middleNameMatchingRange: Range<String.Index>?
    
    var familyName: String = ""
    var isFamilyNameMatched = false
    var familyNameMatchingRange: Range<String.Index>?
    
    var contentValue: String = ""
    var isContentValueMatched = false
    var contentValueMatchingRange: Range<String.Index>?
    
    var contentType: ContactContent! // Phone number or email address
    var contentLabel: String? // "Home" or "Office"
}

class ContactList {
    
    static func getPhoneNumbersAndEmails(completion: @escaping ([Contact]) -> ()) {
        
        getAllContacts() { (contacts) in
            var phoneNumbersAndEmails: [Contact] = []
            
            contacts.forEach { (contact) in
                var myContact = Contact()

                myContact.givenName = contact.givenName
                myContact.middleName = contact.middleName
                myContact.familyName = contact.familyName

                if contact.isKeyAvailable(CNContactEmailAddressesKey) {
                    contact.emailAddresses.forEach({ (email) in
                        myContact.contentValue = String(email.value)
                        myContact.contentType = .email
                        myContact.contentLabel = email.label

                        phoneNumbersAndEmails.append(myContact)
                    })
                }
                
                if contact.isKeyAvailable(CNContactPhoneNumbersKey) {
                    contact.phoneNumbers.forEach({ (phoneNumber) in
                        myContact.contentValue = phoneNumber.value.stringValue
                        myContact.contentType = .phoneNumber
                        myContact.contentLabel = phoneNumber.label

                        phoneNumbersAndEmails.append(myContact)
                    })
                }
                
            }

            completion(phoneNumbersAndEmails)
        }
    }
    
    private static func getAllContacts(completion: @escaping ([CNContact]) -> Void) {
        
        let store = CNContactStore()
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactMiddleNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor
        ]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        var unifiedContacts: [CNContact] = []
        
        do {
            try store.enumerateContacts(with: fetchRequest) { (contact, _) in
                unifiedContacts.append(contact)
            }
        } catch {
            print(error)
        }
        
        DispatchQueue.main.async {
            completion(unifiedContacts)
        }
    }
    
}
