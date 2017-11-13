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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        
        contactsTableView.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "contactsTableViewCell")
        
        searchTextView.delegate = self
        
        //searchTextView.text = "To: "
        //searchTextView.textColor = UIColor.lightGray
        
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
        
        let inputText = searchTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        ContactList.getPhoneNumbersAndEmails(inputText) { contacts in
            self.contacts = contacts
            
            self.contactsTableView.reloadData()
        }
        
        /*
         // Scroll table to top. Otherwise search results might be overlapped by search bar.
         if tableView.contentOffset != CGPoint.zero {
         tableView.setContentOffset(CGPoint.zero, animated: false)
         }
         */
    }
    
    // TableView DataSource and Delegate functions
    
    private func configureCell(_ cell: ContactsTableViewCell, _ indexPath: IndexPath) {
        cell.title.text = contacts[indexPath.row].name ?? "Unknown Name"
        cell.content.text = contacts[indexPath.row].contentValue ?? "Unknown Value"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactsTableViewCell", for: indexPath) as! ContactsTableViewCell
        
        configureCell(cell, indexPath)
        
        return cell
    }
}

