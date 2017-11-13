//
//  ViewController.swift
//  ContactsSearch
//
//  Created by Zhe Cui on 11/11/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    @IBOutlet weak var searchTextView: UITextView!
    @IBOutlet weak var contactsTableView: UITableView!
    
    private var contacts: [Contact] = []
    private var filteredContacts: [Contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        
        contactsTableView.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "contactsTableViewCell")
        
        searchTextView.delegate = self
        
        //searchTextView.text = "To: "
        //searchTextView.textColor = UIColor.lightGray
        
        ContactList.getPhoneNumbersAndEmails() { contacts in
            self.contacts = contacts
            print(self.contacts)
        }

        
        searchTextView.becomeFirstResponder()
    }
    
    /*
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "To:" {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    */
    
    func textViewDidChange(_ textView: UITextView) {
        /*
        if textView.text.isEmpty {
            textView.text = "To:"
            searchTextView.textColor = UIColor.lightGray
            
            return
        }
        */
        
        filteredContacts.removeAll()
        
        let inputTextComponents = searchTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: [" "])
        
        for contact in contacts {
            var foundContact = contact
            var matchingComponentCount = 0
            
            for component in inputTextComponents {
                var isMatching = false
                
                if let range = contact.givenName.range(of: component, options: [.caseInsensitive, .anchored]) {
                    foundContact.isGivenNameMatched = true
                    foundContact.givenNameMatchingRange = range
                    isMatching =  true
                }
                
                if let range = contact.middleName.range(of: component, options: [.caseInsensitive, .anchored]) {
                    foundContact.isMiddleNameMatched = true
                    foundContact.middleNameMatchingRange = range
                    isMatching =  true
                }

                if let range = contact.familyName.range(of: component, options: [.caseInsensitive, .anchored]) {
                    foundContact.isFamilyNameMatched = true
                    foundContact.familyNameMatchingRange = range
                    isMatching =  true
                }

                if let range = contact.contentValue.range(of: component, options: [.caseInsensitive]) {
                    foundContact.isContentValueMatched = true
                    foundContact.contentValueMatchingRange = range
                    isMatching =  true
                }
                
                if isMatching {
                    matchingComponentCount += 1
                }

            }
            
            if matchingComponentCount == inputTextComponents.count {
                filteredContacts.append(foundContact)
            }
            
        }
        
        contactsTableView.reloadData()
        
    }
    
    // TableView DataSource and Delegate functions
    
    private func configureCell(_ cell: ContactsTableViewCell, _ indexPath: IndexPath) {
        let contact = filteredContacts[indexPath.row]
        
        let givenNameAttributedText = NSMutableAttributedString(string: contact.givenName)
        let middleNameAttributedText = NSMutableAttributedString(string: contact.middleName)
        let familyNameAttributedText = NSMutableAttributedString(string: contact.familyName)
        
        let fullNameAttributedText = NSMutableAttributedString(string: "")
        
        let contentValueAttributedText = NSMutableAttributedString(string: contact.contentValue)
        let spaceAttributedString = NSAttributedString(string: " ")
        
        if contact.isGivenNameMatched {
            givenNameAttributedText.addAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: cell.title.font.pointSize)], range: NSRange(contact.givenNameMatchingRange!, in: contact.givenName))
        }
        
        if contact.isMiddleNameMatched {
            middleNameAttributedText.addAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: cell.title.font.pointSize)], range: NSRange(contact.middleNameMatchingRange!, in: contact.middleName))
        }
        
        if contact.isFamilyNameMatched {
            familyNameAttributedText.addAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: cell.title.font.pointSize)], range: NSRange(contact.familyNameMatchingRange!, in: contact.familyName))
        }
        
        if contact.isContentValueMatched {
            contentValueAttributedText.addAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: cell.content.font.pointSize)], range: NSRange(contact.contentValueMatchingRange!, in: contact.contentValue))
        }
        
        fullNameAttributedText.append(givenNameAttributedText)
        fullNameAttributedText.append(spaceAttributedString)
        fullNameAttributedText.append(middleNameAttributedText)
        fullNameAttributedText.append(spaceAttributedString)
        fullNameAttributedText.append(familyNameAttributedText)

        if fullNameAttributedText.string != "  " {
            cell.title.attributedText = fullNameAttributedText
            cell.content.attributedText = contentValueAttributedText
        } else {
            cell.title.attributedText = contentValueAttributedText
            cell.content.attributedText = contentValueAttributedText
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactsTableViewCell", for: indexPath) as! ContactsTableViewCell
        
        configureCell(cell, indexPath)
        
        return cell
    }
}

