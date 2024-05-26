//
//  ViewController.swift
//  Project7
//
//  Created by Mikhail Zhuzhman on 26.05.2024.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let urlString: String
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
//            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        }
        
        downloadData(from: urlString)
        title = "White House Petitions"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showFilter))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
    }
    
    @objc func showCredits() {
        let ac = UIAlertController(title: "Credits", message: "The data comes from the We The People API of the Whitehouse\n\nhttps://api.whitehouse.gov/", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    
    @objc func showFilter() {
        let ac = UIAlertController(title: "Filter Petitions", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let applyAction = UIAlertAction(title: "Apply", style: .default) { [weak self, weak ac] action in
            guard let filter = ac?.textFields?[0].text else { return }
            self?.applyFilter(filter)
        }
        let resetAction = UIAlertAction(title: "Reset Filter", style: .destructive) { [weak self] action in
            self?.resetFilter()
        }
        
        ac.addAction(applyAction)
        ac.addAction(resetAction)
        present(ac, animated: true)
    }
    
    func resetFilter() {
        filteredPetitions = petitions
        tableView.reloadData()
    }
    
    func applyFilter(_ filter: String) {
        let lowerFilter = filter.lowercased()
        
        let validations: [(String) -> (Bool, String, String)] = [isEmpty]
        if isValid(lowerFilter: lowerFilter, using: validations) {
            filteredPetitions = petitions.filter({ ($0.title.lowercased().contains(lowerFilter))||($0.body.lowercased().contains(lowerFilter)) })
            tableView.reloadData()
        }
    }
    
    func isEmpty(word: String) -> (Bool, String, String) {
        return (!(word.lowercased().count < 1), "Ups", "Empty Filter.")
    }
    
    func isValid(lowerFilter: String, using validations: [(String) -> (Bool, String, String)]) -> Bool {
        for validation in validations {
            if !validation(lowerFilter).0 {
                showErrorMessage(errorTitle: validation(lowerFilter).1, errorMessage: validation(lowerFilter).2)
                return false
            }
        }
        return true
    }
    
    func downloadData(from fromURL: String) {
        guard let url = URL(string: fromURL) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                parse(json: data)
            } catch let error {
                print(error)
                showErrorMessage(errorTitle: "Loading error", errorMessage: "There was a problem loading the feed; please chack your connection and try again")
            }
        }
    }
        
    func showErrorMessage(errorTitle: String, errorMessage: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            filteredPetitions = jsonPetitions.results
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filteredPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = filteredPetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

}

