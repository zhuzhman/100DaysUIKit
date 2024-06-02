//
//  ViewController.swift
//  Project10
//
//  Created by Mikhail Zhuzhman on 02.06.2024.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var people = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addNewPersonFromCamera))
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell.")
        }
        
        let person = people[indexPath.item]
        
        cell.name.text = person.name
        
        let path = getDocumentDirectory().appendingPathComponent(person.image)
        cell.ImageView.image = UIImage(contentsOfFile: path.path)
        
        cell.ImageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.ImageView.layer.borderWidth = 2
        cell.ImageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName, imagePath: imagePath)
        people.append(person)
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        //        let ac = UIAlertController(title: "Rename Person", message: nil, preferredStyle: .alert)
        //        ac.addTextField()
        //
        //        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
        //            guard let newName = ac?.textFields?[0].text else { return }
        //            person.name = newName
        //            self?.collectionView.reloadData()
        //
        //        })
        //
        //        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        //        present(ac, animated: true)
        renameOrDelete(person, indexPath: indexPath)
    }
    
    func renameOrDelete(_ person: Person, indexPath: IndexPath) {
        let ac = UIAlertController(title: "Rename or Delete Person", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
            self?.renamePerson(person)
        })
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deletePerson(person, indexPath: indexPath)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func renamePerson(_ person: Person) {
        let ac = UIAlertController(title: "Rename Person", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            person.name = newName
            self?.collectionView.reloadData()
            
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func deletePerson(_ person: Person, indexPath: IndexPath) {
        removeImage(person: person)
        people.remove(at: indexPath.row)
        collectionView.reloadData()
    }
    
    func removeImage(person: Person) {
        let fileManager = FileManager.default

        do {
            if fileManager.fileExists(atPath: person.imagePath.path) {
                try fileManager.removeItem(at: person.imagePath)
                print("Image deleted successfully.")
            } else {
                print("File does not exist.")
            }
        } catch {
            print("Error deleting image: \(error)")
        }
    }
    
    @objc func addNewPersonFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Camera Not Available", message: "This device does not have a camera.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}

