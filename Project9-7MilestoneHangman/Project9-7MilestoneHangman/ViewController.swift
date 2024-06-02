//
//  ViewController.swift
//  Project9-7MilestoneHangman
//
//  Created by Mikhail Zhuzhman on 01.06.2024.
//

import UIKit

class ViewController: UIViewController {
    var resetButton: UIButton!
    var scoreLabel: UILabel!
    var imageContainerView: UIView!
    var imageView: UIImageView!
    var image: UIImage!
    var currentAnswer: UITextField!
    var buttonsView: UIView!
    var letterButtons = [UIButton]()
    var buttonsLeft = 0
    var answerWord = String()
    var lettersForInput = [String]()
    var alphabet = [String]()
    var pressedButtons = [UIButton]()
    
    var loadedWords = ["god", "war", "unbreakable", "done"]
//    var loadedWords = [String]()
    
    let defaultHangScore = 8
    var hangScore = 8 {
        didSet {
            loadImage()
        }
    }
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func loadView() {
        setupMainView()
        setupButtons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSelector(inBackground: #selector(startGame), with: nil)
//        startGame()
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        
        if !findLetter(buttonTitle) {
            hangScore -= 1
            if hangScore == 0 {
                score -= 1
                for (index, word) in answerWord.enumerated() {
                    lettersForInput[index] = String(word)
                }
                showMessage("gameOver")
            }
        }
        currentAnswer.placeholder = lettersForInput.joined(separator: " ")
        pressedButtons.append(sender)
        sender.isHidden = true
    }
    
    @objc func startGame() {
        loadAlphabet()
        loadImage()
        loadWords()
    }
    
    func restartGame(action: UIAlertAction) {
        hangScore = defaultHangScore
        lettersForInput.removeAll()
        for button in pressedButtons {
            button.isHidden = false
        }
        pressedButtons.removeAll()
        loadedWords.shuffle()
        answerWord = loadedWords[0]
        for _ in answerWord {
            lettersForInput.append("_")
        }
        currentAnswer.placeholder = lettersForInput.joined(separator: " ")
    }
    
    @objc func restartGameFromButton() {
        restartGame(action: UIAlertAction(title: "OK", style: .default, handler: restartGame))
    }
    
    func loadWords() {
        if let wordsFileURL = Bundle.main.url(forResource: "words", withExtension: "txt") {
            if let fileContents = try? String(contentsOf: wordsFileURL) {
                loadedWords = fileContents.components(separatedBy: "\n")
                loadedWords.shuffle()
                
                answerWord = loadedWords[0]
                for _ in answerWord {
                    lettersForInput.append("_")
                }
            }
        }
        DispatchQueue.main.async {
            self.currentAnswer.placeholder = self.lettersForInput.joined(separator: " ")
        }
    }
    
    func loadImage() {
        if let image = UIImage(named: "\(hangScore).jpg") {
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        } else {
            print("Error: Could not find the image file \(hangScore).png")
            return
        }
    }
    
    func loadAlphabet() {
        alphabet = (97...122).map({String(UnicodeScalar($0))});//.shuffled()
        //        print(alphabet.count == letterButtons.count - 4)
        if alphabet.count == letterButtons.count - 4 {
            for i in 0..<letterButtons.count {
                if (0...23 ~= i) {
                    DispatchQueue.main.async {
                        self.letterButtons[i].setTitle(self.alphabet[i], for: .normal)
                    }
                } else if (26...27 ~= i) {
                    DispatchQueue.main.async {
                        self.letterButtons[i].setTitle(self.alphabet[i - 2], for: .normal)
                    }
                }
            }
        }
    }
    
    func setupMainView() {
        view = UIView()
        resetButton = UIButton(type: .system)
        scoreLabel = UILabel()
        imageContainerView = UIView()
        imageView = UIImageView()
        buttonsView = UIView()
        
        view.backgroundColor = .white
        
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("Reload", for: .normal)
        let resetImage = UIImage(systemName: "arrow.clockwise.circle.fill")
        resetButton.setImage(resetImage, for: .normal)
        resetButton.imageView?.contentMode = .scaleAspectFit
//        resetButton.tintColor = .systemBlue
        resetButton.addTarget(self, action: #selector(restartGameFromButton), for: .touchUpInside)
        view.addSubview(resetButton)
        
        
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.text = "Score: 0"
//        scoreLabel.backgroundColor = .cyan
        view.addSubview(scoreLabel)
        
        
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
//        imageContainerView.backgroundColor = .red
        view.addSubview(imageContainerView)
        
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.placeholder = "Tap letters to guess"
//        currentAnswer.backgroundColor = .black
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 36)
        currentAnswer.isUserInteractionEnabled = false
        view.addSubview(currentAnswer)
        
//        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
//        buttonsView.backgroundColor = .green
        view.addSubview(buttonsView)
        
        NSLayoutConstraint.activate([
            resetButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            resetButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            imageContainerView.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20),
            imageContainerView.topAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 20),
            imageContainerView.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor),
            imageContainerView.heightAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.heightAnchor, multiplier: 0.4),
            imageContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageContainerView.bottomAnchor.constraint(equalTo: currentAnswer.topAnchor, constant: -20),
            
            imageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            
            currentAnswer.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 20),
            currentAnswer.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor),
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            buttonsView.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor),
            buttonsView.heightAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.heightAnchor, multiplier: 0.4),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor, constant: 20),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])
    }
    
    func setupButtons() {
        let rows: CGFloat = 5
        let columns: CGFloat = 6
        let buttonSpacing: CGFloat = 10
        
        for row in 0..<Int(rows) {
            for column in 0..<Int(columns) {
                let index = row * Int(columns) + column
                let letterButton = UIButton(type: .system)
                
                letterButton.translatesAutoresizingMaskIntoConstraints = false
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                letterButton.setTitle("\(index)", for: .normal)
                

                buttonsView.addSubview(letterButton)
                
                letterButton.heightAnchor.constraint(lessThanOrEqualTo: buttonsView.safeAreaLayoutGuide.heightAnchor, multiplier: (1/rows), constant: -buttonSpacing).isActive = true
                letterButton.widthAnchor.constraint(lessThanOrEqualTo: buttonsView.safeAreaLayoutGuide.widthAnchor, multiplier: (1/columns), constant: -buttonSpacing).isActive = true
                
                if row == 0 {
                    letterButton.topAnchor.constraint(equalTo: buttonsView.safeAreaLayoutGuide.topAnchor, constant: buttonSpacing).isActive = true
                } else {
                    let previous = letterButtons[(row - 1) * Int(columns) + column]
                    letterButton.topAnchor.constraint(equalTo: previous.safeAreaLayoutGuide.bottomAnchor, constant: buttonSpacing).isActive = true
                }
                
                if column == 0 {
                    letterButton.leadingAnchor.constraint(equalTo: buttonsView.safeAreaLayoutGuide.leadingAnchor, constant: buttonSpacing).isActive = true
                } else {
                    let previous = letterButtons[row * Int(columns) + (column - 1)]
                    letterButton.leadingAnchor.constraint(equalTo: previous.safeAreaLayoutGuide.trailingAnchor, constant: buttonSpacing).isActive = true
                }
                
                if row == Int(rows) - 1 {
                    letterButton.bottomAnchor.constraint(equalTo: buttonsView.safeAreaLayoutGuide.bottomAnchor, constant: -buttonSpacing).isActive = true
                }
                
                if column == Int(columns) - 1 {
                    letterButton.trailingAnchor.constraint(equalTo: buttonsView.safeAreaLayoutGuide.trailingAnchor, constant: -buttonSpacing).isActive = true
                }
                
                if (row != 0 && column != 0) {
                    let previous = letterButtons[row * Int(columns) + (column - 1)]
                    letterButton.heightAnchor.constraint(equalTo: previous.heightAnchor).isActive = true
                    letterButton.widthAnchor.constraint(equalTo: previous.widthAnchor).isActive = true
                }
                
                letterButton.layer.cornerRadius = 10
                letterButton.layer.borderWidth = 1
                letterButton.layer.borderColor = UIColor.lightGray.cgColor
                
                if row == 4 && (column > 3 || column < 2) {
                    letterButton.isHidden = true
                    buttonsLeft -= 1
                }
                
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                letterButtons.append(letterButton)
                buttonsLeft += 1
            }
        }
    }
    
    func showMessage(_ result: String) {
        var title: String
        var message: String
        if result == "win" {
            title = "Great!"
            message = "\nGreat game.\n\nYou've survived.\n\nIt was \"\(answerWord)\""
        } else if result == "gameOver" {
            title = "Sorry 😕"
            message = "\nGame over.\n\nYou are dead.\n\nIt was \"\(answerWord)\""
        } else {
            title = "Sorry 😕"
            message = "\nGame over.\n\nYou are dead."
        }
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: restartGame))
        present(ac, animated: true)
    }
    
    func findLetter(_ buttonTitle: String) -> Bool {
        var result = false
        print(hangScore)
        for (index, letter) in answerWord.enumerated() {
            if letter == Character(buttonTitle) {
                lettersForInput[index] = buttonTitle
                result = true
            }
        }
        
        if (lettersForInput.firstIndex(of: "_") == nil) {
            print(lettersForInput)
            score += 1
            showMessage("win")
        }
        return result
    }
}
