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
    
    //private var searchTextViewOffset = 0
    //private var searchTextViewStartPosition: UITextPosition!
    
    private var replaceRangeStartPosition: UITextPosition!
    //private var replaceRangeEndPosition: UITextPosition!
    private var textViewTextCount = 0
    
    private var searchTextStack = Stack<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ContactList.checkPermissions()
        
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
        
        replaceRangeStartPosition = searchTextView.position(from: searchTextView.beginningOfDocument, offset: 0)
        
    }
    
    /*
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "To:" {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    */

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.count == 0 {
            searchTextStack.popLast(range.length)
        } else {
            searchTextStack.push(text)
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        filteredContacts.removeAll()

        guard let searchRangeStartPosition = replaceRangeStartPosition,
            let searchRangeEngPosition = textView.position(from: searchRangeStartPosition, offset: textView.text.count - textViewTextCount) else {
            return
        }
        
        guard let searchTextRange = textView.textRange(from: searchRangeStartPosition, to: searchRangeEngPosition),
            let searchText = textView.text(in: searchTextRange) else {
                return
        }

        //textViewTextCount = textView.text.count
        //replaceRangeStartPosition = textView.position(from: textView.beginningOfDocument, offset: textViewTextCount)

        let inputTextComponents = searchText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: [" "])
        
        //let inputTextComponents = searchTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: [" "])
        
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
        
        let fullNameAttributedText = NSMutableAttributedString(string: "")
        let givenNameAttributedText = NSMutableAttributedString(string: contact.givenName)
        let middleNameAttributedText = NSMutableAttributedString(string: contact.middleName)
        let familyNameAttributedText = NSMutableAttributedString(string: contact.familyName)
        
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
        if !givenNameAttributedText.string.isEmpty {
            fullNameAttributedText.append(spaceAttributedString)
        }
        fullNameAttributedText.append(middleNameAttributedText)
        if !middleNameAttributedText.string.isEmpty {
            fullNameAttributedText.append(spaceAttributedString)
        }
        fullNameAttributedText.append(familyNameAttributedText)

        if !fullNameAttributedText.string.isEmpty {
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! ContactsTableViewCell
        guard let titleText = selectedCell.title.text else {
            return
        }
        
        guard let replaceRangeEndPosition = searchTextView.position(from: replaceRangeStartPosition, offset: searchTextView.text.count - textViewTextCount) else {
            return
        }
        
        guard let replaceRange = searchTextView.textRange(from: replaceRangeStartPosition, to: replaceRangeEndPosition) else {
            return
        }
        
        searchTextView.replace(replaceRange, withText: titleText + ", ")
        
        textViewTextCount = searchTextView.text.count
        replaceRangeStartPosition = searchTextView.position(from: searchTextView.beginningOfDocument, offset: textViewTextCount)

        
        
        //searchTextView.selectedRange = NSMakeRange(searchTextViewStartPosition, 0)
        
        //searchTextViewOffset = titleText.count
        
        /*
        guard let selectedTextRange = searchTextView.selectedTextRange else {
            return
        }
        */
        
        
        //_ = textView(searchTextView, shouldChangeTextIn: nsRange, replacementText: titleText)
        
        /*
        guard let replaceEndPosition = searchTextView.position(from: searchTextViewStartPosition, offset: searchTextView.text.count - previousTextViewTextCount) else {
            return
        }
        
        let replaceRange = searchTextView.textRange(from: searchTextViewStartPosition, to: replaceEndPosition)
        
        
        let location = searchTextView.offset(from: searchTextView.beginningOfDocument, to: selectedTextRange.start)
        let length = searchTextView.offset(from: selectedTextRange.start, to: selectedTextRange.end)
        let nsRange = NSMakeRange(location, length)
        
        _ = textView(searchTextView, shouldChangeTextIn: nsRange, replacementText: titleText)
        */
        /*
        guard let newPosition = searchTextView.position(from: searchTextViewStartPosition, offset: searchTextViewOffset) else {
            return
        }
        
        searchTextView.selectedTextRange = searchTextView.textRange(from: searchTextViewStartPosition, to: newPosition)
        */
        
        //searchTextViewStartPosition = newPosition
        
        
        
        /*
         let fullNameAttributedText = NSMutableAttributedString(string: selectedCell.title.text!)
         fullNameAttributedText.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.blue], range: NSRange(selectedCell.title.text!.range(of: selectedCell.title.text!)!, in: selectedCell.title.text!))
         
         let attributed = NSMutableAttributedString(string: "")
         attributed.append(fullNameAttributedText)
         
         searchTextView.attributedText = fullNameAttributedText
         */
        
        //searchTextView.text = selectedCell.title.text!
        
        //let position = CGPoint(x: searchTextView.textContainer.lineFragmentPadding, y: searchTextView.textContainerInset.top)
        
        //searchTextView.addButton(with: selectedCell.title.text!, tag: 0, to: position)
    }
}

