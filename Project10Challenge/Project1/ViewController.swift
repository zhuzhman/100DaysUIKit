//
//  ViewController.swift
//  Project1
//
//  Created by Mikhail Zhuzhman on 11.05.2024.
//

import UIKit

class ViewController: UICollectionViewController {
    var pictures = [String]()
    var rows = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
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

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return pictures.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
//        cell.textLabel?.text = pictures.sorted()[indexPath.row] /* "Picture \(indexPath.row + 1) of \(rows)" */
//        return cell
//    }
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
//            vc.selectedImage = (pictures[indexPath.row], "Picture \(indexPath.row + 1) of \(rows)") /*pictures[indexPath.row]*/
//            navigationController?.pushViewController(vc, animated: true)
//        }
//    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Detail", for: indexPath) as? DetailCell else {
            fatalError("Unable to dequeue PersonCell.")
        }
        
        cell.ImageView.image = UIImage(named: pictures.sorted()[indexPath.item])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = (pictures[indexPath.row], "Picture \(indexPath.item + 1) of \(rows)")
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func shareTapped() {
        let vc = UIActivityViewController(activityItems: ["Look at this App I've made!"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}

