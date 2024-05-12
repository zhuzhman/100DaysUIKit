//
//  ViewController.swift
//  Project1
//
//  Created by Mikhail Zhuzhman on 11.05.2024.
//

import UIKit

class ViewController: UITableViewController {
    var pictures = [String]()
    var rows = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                pictures.append(item)
            }
        }
        rows = pictures.count
        print(pictures.sorted())
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures.sorted()[indexPath.row] /* "Picture \(indexPath.row + 1) of \(rows)" */
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = (pictures[indexPath.row], "Picture \(indexPath.row + 1) of \(rows)") /*pictures[indexPath.row]*/
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

