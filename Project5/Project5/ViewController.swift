//
//  ViewController.swift
//  Project5
//
//  Created by Mikhail Zhuzhman on 22.05.2024.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
//        let errorTitle: String
//        let errorMessage: String
        
        let validations: [(String) -> (Bool, String, String)] = [isPossible, isOriginal, isReal, isShort, isTheSame]
        validate(lowerAnswer: lowerAnswer, using: validations)
        /*
        if !isPossible(word: lowerAnswer).0 {
            let result = isPossible(word: lowerAnswer)
            showErrorMessage(errorTitle: result.1, errorMessage: result.2)
            return
        }
        
        if !isOriginal(word: lowerAnswer).0 {
            let result = isOriginal(word: lowerAnswer)
            showErrorMessage(errorTitle: result.1, errorMessage: result.2)
            return
        }
        
        if !isReal(word: lowerAnswer).0 {
            let result = isReal(word: lowerAnswer)
            showErrorMessage(errorTitle: result.1, errorMessage: result.2)
            return
        }
        
        if !isShort(word: lowerAnswer).0 {
            let result = isShort(word: lowerAnswer)
            showErrorMessage(errorTitle: result.1, errorMessage: result.2)
            return
        }
        
        if !isTheSame(word: lowerAnswer).0 {
            let result = isTheSame(word: lowerAnswer)
            showErrorMessage(errorTitle: result.1, errorMessage: result.2)
            return
        }
        */
//        if isPossible(word: lowerAnswer) {
//            if isOriginal(word: lowerAnswer) {
//                if isReal(word: lowerAnswer) {
//                    usedWords.insert(answer, at: 0)
//                    
//                    let indexPath = IndexPath(row: 0, section: 0)
//                    tableView.insertRows(at: [indexPath], with: .automatic)
//                    
//                    return
//                } else {
//                    errorTitle = "Word not recognized"
//                    errorMessage = "You can't just make them up, you know!"
//                }
//            } else {
//                errorTitle = "Word already used"
//                errorMessage = "Be more original!"
//            }
//        } else {
//            guard let title = title else { return }
//            errorTitle = "Word not possible"
//            errorMessage = "You can't spell that word from \(title.lowercased())."
//        }
//        showErrorMessage(errorTitle: errorTitle, errorMessage: errorMessage)
    }
    
    func isPossible(word: String) -> (Bool, String, String) {
        guard let possibleError = title?.lowercased() else { return (false, "Critical", "Critical") }
        guard var tempWord = title?.lowercased() else { return (false, "Critical", "Critical") }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return (false, "Word not possible", "You can't spell that word from \(possibleError.lowercased()).")
            }
        }
        
        return (true, "True", "")
    }
    
    func isOriginal(word: String) -> (Bool, String, String) {
        return (!usedWords.contains(word.lowercased()), "Original Word", "You cannot use words that were already used.")
    }
    
    func isReal(word: String) -> (Bool, String, String) {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return (misspelledRange.location == NSNotFound, "Word not recognized", "You can't just make them up, you know!")
    }
    
    func isShort(word: String) -> (Bool, String, String) {
        return (word.count > 3, "Too Short", "The target word should be more then 3 letters.")
    }
    
    func isTheSame(word: String) -> (Bool, String, String) {
        return (word != title, "The Same as Original", "The target word should be differrent from the original one.")
    }
    
    func validate(lowerAnswer: String, using validations: [(String) -> (Bool, String, String)]) {
        for validation in validations {
            if !validation(lowerAnswer).0 {
                showErrorMessage(errorTitle: validation(lowerAnswer).1, errorMessage: validation(lowerAnswer).2)
                return
            }
        }
        usedWords.insert(lowerAnswer, at: 0)
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func showErrorMessage(errorTitle: String, errorMessage: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

