//
//  ViewController.swift
//  Project6-4MilestoneShoppingList
//
//  Created by Mikhail Zhuzhman on 25.05.2024.
//

import UIKit

class ViewController: UITableViewController {
//    var allItems = [String]()
    var addedItems = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startShopping))
        
        let firstButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForItem))
        let secondButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        navigationItem.rightBarButtonItems = [secondButton, firstButton]
        
        title = "Shopping List"
        
        startShopping()
    }
    
    @objc func startShopping() {
        addedItems.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath)
        cell.textLabel?.text = addedItems[indexPath.row]
        return cell
    }
    
    @objc func promptForItem() {
        let ac = UIAlertController(title: "Enter Shopping List Item", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "ADD", style: .default) {
            [weak self, weak ac] action in
            guard let listItem = ac?.textFields?[0].text else { return }
            self?.submit(listItem)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ listItem: String) {
        let lowerListItem = listItem.lowercased()

        let validations: [(String) -> (Bool, String, String)] = [isOriginal, isEmpty]
        validate(lowerListItem: lowerListItem, using: validations)
    }
    
    func isOriginal(word: String) -> (Bool, String, String) {
        return (!addedItems.contains(word.lowercased()), "Added Item", "You have already added this item to your list.")
    }
    
    func isEmpty(word: String) -> (Bool, String, String) {
        return (!(word.lowercased().count < 1), "Ups", "Empty Item.")
    }
    
    func validate(lowerListItem: String, using validations: [(String) -> (Bool, String, String)]) {
        for validation in validations {
            if !validation(lowerListItem).0 {
                showErrorMessage(errorTitle: validation(lowerListItem).1, errorMessage: validation(lowerListItem).2)
                return
            }
        }
//        addedItems.insert(lowerListItem, at: 0)
        addedItems.append(lowerListItem)
        
        if (addedItems.count - 1) > -1 {
            let indexPath = IndexPath(row: addedItems.count - 1, section: 0)
            //        tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
    func showErrorMessage(errorTitle: String, errorMessage: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func shareTapped() {
        let list = addedItems.joined(separator: "\n")
        
        let vc = UIActivityViewController(activityItems: [list], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

}

