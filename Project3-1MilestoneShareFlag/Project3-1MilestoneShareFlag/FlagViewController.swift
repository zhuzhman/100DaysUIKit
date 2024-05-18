//
//  FlagViewController.swift
//  Project3-1MilestoneShareFlag
//
//  Created by Mikhail Zhuzhman on 14.05.2024.
//

import UIKit

class FlagViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var flag: UIButton!
    
    var selectedFlag: (String?, String?)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedFlag.1
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        if let imageToLoad = selectedFlag.0 {
            imageView.image = UIImage(named: imageToLoad)
        }
        
        imageView.backgroundColor = .red
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        
//        flag.setImage(UIImage(named: selectedFlag.0 ?? ""), for: .normal)
//        flag.setImage(imageView.image, for: .normal)
//        flag.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        flag.layer.borderWidth = 1
        flag.layer.borderColor = UIColor.lightGray.cgColor
        flag.layer.cornerRadius = 8
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    @objc func shareTapped() {
        guard let image = UIImage(named: selectedFlag.0 ?? "")?.jpegData(compressionQuality: 0.8) else {
            print("No Image found")
            return
        }
        
        let vc = UIActivityViewController(activityItems: [image, selectedFlag.0?.uppercased() ?? "Image"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    @IBAction func pressFlag(_ sender: Any) {
        shareTapped()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
