//
//  ViewController.swift
//  Project2
//
//  Created by Mikhail Zhuzhman on 12.05.2024.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var questionMax = 3
    var questionCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show Score", style: .done, target: self, action: #selector(scoreAlert))
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
        button1.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        button2.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        button3.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
//        askQuestion(action: nil)
        askQuestion()
    }
    
    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        if questionCount == questionMax {
            gameReset()
        }
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        title = "Questions: \(questionCount)\\\(questionMax) | " + countries[correctAnswer].uppercased() + " | Your score is: \(score)"
    }

    
    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        var additionalText = ""
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        } else {
            title = "Wrong"
            additionalText = "Wrong! That’s the flag of \(countries[sender.tag].uppercased())\n\n"
            score -= 1
        }
        
        questionCount += 1
        
        if questionCount == questionMax {
            title = "Game Over!"
        }
        
        let ac = UIAlertController(title: title, message: additionalText + ((questionCount == questionMax) ? "Your FINAL score is \(score)" : "Your score is \(score)"), preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: ((questionCount == questionMax) ? "Reset Game" : "Continue"), style: ((questionCount == questionMax) ? .default : .cancel), handler: askQuestion))
        
        present(ac, animated: true)
//        scoreAlert(additionalText: additionalText, title: title)
    }
    
    func gameReset(action: UIAlertAction! = nil) {
        score = 0
        correctAnswer = 0
        questionCount = 0
        askQuestion()
    }
    
//    @objc func shareTapped() {
//        let vc = UIActivityViewController(activityItems: [image, selectedImage.0 ?? "Image"], applicationActivities: [])
//        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
//        present(vc, animated: true)
//    }
    
    @objc func scoreAlert() {
        let ac = UIAlertController(title: "Your score is", message: "\(score)", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Close", style: .default))
        ac.addAction(UIAlertAction(title: "Restart", style: .destructive, handler: gameReset))
        
        present(ac, animated: true)
    }
}

