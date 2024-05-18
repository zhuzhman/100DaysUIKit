//
//  ViewController.swift
//  Project3-1MilestoneShareFlag
//
//  Created by Mikhail Zhuzhman on 13.05.2024.
//

import UIKit

class ViewController: UITableViewController {
    var files = [String]()
    //    var flags = ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
    var flags = [String]()
    var rows = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Share Flag"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("flags.json") {
                files.append(item)
            }
        }
        
        if files.count == 1 {
            if let fileUrl = Bundle.main.url(forResource: files[0], withExtension: nil) {
                do {
                    let data = try Data(contentsOf: fileUrl)
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    if let jsonDict = jsonObject as? [String: Any],
                       let flagsArray = jsonDict["flags"] as? [String] {
                        flags += flagsArray
                    }
                } catch {
                    print("Error decoding JSON:", error)
                }
            } else {
                print("JSON file not found in bundle")
            }
        } else {
            print("There are more then one JSON file in bundle. Sorry, cannot choose.")
        }
        
        rows = flags.count
        print(flags.sorted())
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flags.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Flag", for: indexPath)
        cell.textLabel?.text = flags.sorted()[indexPath.row].uppercased() /* "Picture \(indexPath.row + 1) of \(rows)" */
        cell.imageView?.image = UIImage(named: flags.sorted()[indexPath.row])
        cell.imageView?.layer.borderWidth = 1
        cell.imageView?.layer.borderColor = UIColor.lightGray.cgColor
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 100, right: 10)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Flag") as? FlagViewController {
            vc.selectedFlag = (flags[indexPath.row], "Flag of \(flags[indexPath.row].uppercased())") /*(flags[indexPath.row], "Flag \(indexPath.row + 1) of \(rows)")*/ /*flags[indexPath.row]*/
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
