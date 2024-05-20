//
//  ViewController.swift
//  Project4
//
//  Created by Mikhail Zhuzhman on 18.05.2024.
//

import UIKit

class ViewController: UITableViewController {
    var files = [String]()
//    var websites = ["apple.com", "hackingwithswift.com"]
    var websites = [String]()
    var rows = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        title = "Simple Browser"
        
        for item in items {
            if item.hasPrefix("websites.json") {
                files.append(item)
            }
        }
        
        if files.count == 1 {
            if let fileUrl = Bundle.main.url(forResource: files[0], withExtension: nil) {
                do {
                    let data = try Data(contentsOf: fileUrl)
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    if let jsonDict = jsonObject as? [String: Any],
                       let websitesArray = jsonDict["websites"] as? [String] {
                        websites += websitesArray
                    }
                } catch {
                    print("Error decoding JSON:", error)
                }
            } else {
                print("Expected JSON file not found in bundle")
            }
        } else {
            print(files.count < 1 ? "There is no JSON files in the bundle" : "There are more then one JSON file in bundle. Sorry, cannot choose.")
            title = "Error, there are no websites to load"
        }

        if files.count == 1 {            
            print(websites.sorted())
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Websites", for: indexPath)
        cell.textLabel?.text = websites.sorted()[indexPath.row] /* "Picture \(indexPath.row + 1) of \(rows)" */
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Website") as? WebViewController {
            vc.selectedWebsite = (websites[indexPath.row], "Picture \(indexPath.row + 1) of \(rows)") /*pictures[indexPath.row]*/
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showAlert() {
        let ac = UIAlertController(title: "URL is not allowed", message: "The site you are trying to reach is not allowed.", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Close", style: .default))
        
        present(ac, animated: true)
    }
}

