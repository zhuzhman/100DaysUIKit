//
//  GameScene.swift
//  Project11
//
//  Created by Mikhail Zhuzhman on 08.06.2024.
//

import SpriteKit
import UIKit
import GameplayKit
import Foundation

private var hasHitObstaclePreviouslyKey: UInt8 = 0

extension SKNode {
    var hasHitObstaclePreviously: Bool {
        get {
            return objc_getAssociatedObject(self, &hasHitObstaclePreviouslyKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &hasHitObstaclePreviouslyKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            print("I did it")
        }
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var viewController: UIViewController!
    
    var editLabel: SKLabelNode!
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                clearScreen()
                makeEditScreen()
                editLabel.text = "Done"
            } else {
                removeControls()
                makeDefaultScreen()
                editLabel.text = "Edit"
            }
        }
    }
    
    var shortGameLabel: SKLabelNode!
    var shortGameMode: Bool = false {
        didSet {
            if shortGameMode {
                clearScreen()
                makeShortGameScreen()
                shortGameLabel.text = "Exit Game"
                restartGame()
            } else {
                clearScreen()
                resetInitialValues()
                shortGameLabel.text = "Short Game"
                makeDefaultScreen()
            }
        }
    }
    
    var restartLabel: SKLabelNode!
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let maxLevel = 10
    var levelLabel: SKLabelNode!
    var level = 0 {
        didSet {
            levelLabel.text = "Level: \(level)"
        }
    }
    
    var limitLabel: SKLabelNode!
    var ballsLimit = 5 {
        didSet {
            if !shortGameMode {
                limitLabel.text = "Balls Left: ♾️"
            } else {
                if ballsLimit == -1 {
                    showAlert()
                } else {
                    limitLabel.text = "Balls Left: \(ballsLimit)"
                }
            }
        }
    }
    
    var demolitionLabel: SKLabelNode!
    var demolitionMode: Bool = false {
        didSet {
            if demolitionMode {
                demolitionLabel.text = "Solid"
            } else {
                demolitionLabel.text = "Demolition!"
            }
        }
    }
    
    var hardModeLabel: SKLabelNode!
    var hardMode: Bool = false {
        didSet {
            if hardMode {
                hardModeLabel.text = "Easy"
            } else {
                hardModeLabel.text = "Hard!"
            }
        }
    }
    
    var recordBackgroundNode: SKSpriteNode!
    var recordListLabel: SKLabelNode!
    var clearRecordsLabel: SKLabelNode!
    var returnToGameLabel: SKLabelNode!
    
    var showRecordsLabel: SKLabelNode!
    var showRecords: Bool = false {
        didSet {
            if showRecords {
                clearScreen()
                makeRecordsScreen()
                showRecordsLabel.text = "Records"
            } else {
                showRecordsLabel.text = "Records"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        makeInitScreen()
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        shortGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        restartLabel = SKLabelNode(fontNamed: "Chalkduster")
        hardModeLabel = SKLabelNode(fontNamed: "Chalkduster")
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        levelLabel = SKLabelNode(fontNamed: "Chalkduster")
        demolitionLabel = SKLabelNode(fontNamed: "Chalkduster")
        limitLabel = SKLabelNode(fontNamed: "Chalkduster")
        showRecordsLabel = SKLabelNode(fontNamed: "Chalkduster")
        
        recordBackgroundNode = SKSpriteNode(color: SKColor.systemMint.withAlphaComponent(0.6), size: CGSize(width: 896 - 140, height: 414 - 180))
        
        recordListLabel = SKLabelNode(fontNamed: "Chalkduster")
        clearRecordsLabel = SKLabelNode(fontNamed: "Chalkduster")
        returnToGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        
        prepareLabels()

//        makeInitScreen()
        makeDefaultScreen()
//        makeEditScreen()
//        makeShortGameScreen()
//        makeRecordsScreen()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let object = nodes(at: location)
        
        if object.contains(editLabel) {
            editingMode.toggle()
        } else if object.contains(demolitionLabel) {
            demolitionMode.toggle()
        } else if object.contains(shortGameLabel) {
            shortGameMode.toggle()
        } else if object.contains(restartLabel) {
            restartGame()
        } else if object.contains(hardModeLabel) {
            hardMode.toggle()
        } else if object.contains(showRecordsLabel) {
            showRecords = true
        } else if object.contains(clearRecordsLabel) {
            clearRecords()
        } else if object.contains(returnToGameLabel) {
            returnToGame()
        } else {
            if editingMode {
                makeObstacle(at: location)
            } else {
                makeBall(at: location)
            }
        }
    }

    func clearScreen() {
        self.removeAllChildren()
        makeInitScreen()
    }
    
    func makeInitScreen() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 896/2, y: 414/2)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: (0 + 896 / 8), y: 0), isGood: true)
        makeSlot(at: CGPoint(x: (896 / 4 + 896 / 8), y: 0), isGood: false)
        makeSlot(at: CGPoint(x: (896 / 2 + 896 / 8), y: 0), isGood: true)
        makeSlot(at: CGPoint(x: (896 * 3 / 4 + 896 / 8), y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 896 / 4, y: 0))
        makeBouncer(at: CGPoint(x: 896 / 2, y: 0))
        makeBouncer(at: CGPoint(x: 896 * 3 / 4, y: 0))
        makeBouncer(at: CGPoint(x: 896, y: 0))
    }
    
    func prepareLabels() {
        makeLeftLabel(name: editLabel, text: "Edit", position: CGPoint(x: 40, y: 414 - 30))
        makeLeftLabel(name: shortGameLabel, text: "Short Game", position: CGPoint(x: 40, y: 414 - 62))
//        makeLeftLabel(name: restartLabel, text: "Restart", position: CGPoint(x: 40, y: 414 - 94))
        makeLeftLabel(name: restartLabel, text: "Restart", position: CGPoint(x: 40, y: 414 - 30))
        makeLeftLabel(name: hardModeLabel, text: "Hard!", position: CGPoint(x: 40, y: 414 - 94))
        
        makeRightLabel(name: scoreLabel, text: "Score: 0", position: CGPoint(x: 896 - 56, y: 414 - 30))
        makeRightLabel(name: levelLabel, text: "Level: \(level)", position: CGPoint(x: 896 - 56, y: 414 - 30 - 32))
        makeRightLabel(name: demolitionLabel, text: "Demolition!", position: CGPoint(x: 896 - 56, y: 414 - 30 - 32))
        makeRightLabel(name: limitLabel, text: "Balls Left: ♾️", position: CGPoint(x: 896 - 56, y: 414 - 30 - 32 - 32))
        makeRightLabel(name: showRecordsLabel, text: "Records", position: CGPoint(x: 896 - 56, y: 414 - 30 - 32 - 32))
        
        recordBackgroundNode.position = CGPoint(x: 896 / 2, y: 414 / 2 + 40)
        recordListName(recordBackgroundNode)
        
        makeRecordLabel(name: recordListLabel, text: "There are no records yet:(", position: CGPoint(x: 896/2, y: 414-100 + 52))
        makeRecordLabel(name: clearRecordsLabel, text: "Clear Records", position: CGPoint(x:896/4, y: 414/2 - 50))
        makeRecordLabel(name: returnToGameLabel, text: "Back to Game", position: CGPoint(x: 896 * 3 / 4, y: 414/2 - 50))
    }
    
    func makeLeftLabel(name label: SKLabelNode, text: String, position: CGPoint) {
        label.text = text
        label.horizontalAlignmentMode = .left
        label.position = position
    }
    
    func makeRightLabel(name label: SKLabelNode, text: String, position: CGPoint) {
        label.text = text
        label.horizontalAlignmentMode = .right
        label.position = position
    }
    
    func makeRecordLabel(name label: SKLabelNode, text: String, position: CGPoint) {
        label.text = text
        recordListName(label)
        label.position = position
    }
    
    func recordListName(_ node: SKNode) {
        node.name = "recordList"
    }
    
    func removeControls() {
        editLabel.removeFromParent()
        shortGameLabel.removeFromParent()
        restartLabel.removeFromParent()
        hardModeLabel.removeFromParent()
        showRecordsLabel.removeFromParent()
        
        scoreLabel.removeFromParent()
        levelLabel.removeFromParent()
        demolitionLabel.removeFromParent()
        limitLabel.removeFromParent()
        
        recordBackgroundNode.removeFromParent()
        
        recordListLabel.removeFromParent()
        clearRecordsLabel.removeFromParent()
        returnToGameLabel.removeFromParent()
    }
    
    func makeDefaultScreen() {
        addChild(editLabel)
        addChild(shortGameLabel)
        
        addChild(scoreLabel)
        addChild(demolitionLabel)
        addChild(showRecordsLabel)
    }
    
    func makeEditScreen() {
        addChild(editLabel)
    }
    
    func makeShortGameScreen() {
        addChild(shortGameLabel)
        addChild(restartLabel)
        addChild(hardModeLabel)
        
        addChild(scoreLabel)
        addChild(levelLabel)
        addChild(limitLabel)
    }
    
    func makeRecordsScreen() {
        addChild(recordBackgroundNode)
        showRecordsList(userRecords: getSortedRecords())
        addChild(recordListLabel)
        addChild(returnToGameLabel)
        addChild(clearRecordsLabel)
    }
    
    func showRecordsList(userRecords: [UserRecord]?) {
        var tempTextToFill = ""
        guard let userRecords = userRecords else { return }
        if !userRecords.isEmpty {
            tempTextToFill = "Record List:"
            for (index, record) in userRecords.enumerated() {
                if index > 10 { break }
                showRecordLabel(index: index, record: record)
            }
        } else {
            tempTextToFill = "There are no records yet:("
        }
        recordListLabel.text = tempTextToFill
    }

    
    func makeBall(at location: CGPoint) {
        let balls = ["ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballRed", "ballYellow"]
//        balls.shuffle()
        
//        let ball = SKSpriteNode(imageNamed: "ballRed")
//        let ball = SKSpriteNode(imageNamed: balls[0])
//        let ball = SKSpriteNode(imageNamed: balls[Int.random(in: 0..<balls.count)])
        let ball = SKSpriteNode(imageNamed: balls.randomElement() ?? "ballBlue")
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
        ball.physicsBody?.restitution = 0.4
        ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
        ball.position = CGPoint(x: location.x, y: 400)
        ball.name = "ball"
        addChild(ball)
        ballsLimit -= 1
        if ballsLimit == -1 {
            ball.removeFromParent()
        }
    }
    
    func makeObstacle(at location: CGPoint) {
        let size = CGSize(width: Int.random(in: 16...128), height: 16)
        let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
        box.zRotation = CGFloat.random(in: 0...3)
        box.position = location
        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody?.isDynamic = false
        box.name = "obstacle"
        addChild(box)
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        if let sparkParticles = SKEmitterNode(fileNamed: "SparkParticles") {
            sparkParticles.position = bouncer.position
            addChild(sparkParticles)
        }
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodA = contact.bodyA.node else { return }
        guard let nodB = contact.bodyB.node else { return }
        
        if contact.bodyA.node?.name == "ball" {
            collision(between: nodA, object: nodB)
        } else if contact.bodyB.node?.name == "ball" {
            collision(between: nodB, object: nodA)
        }
    }
    
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball)
            if shortGameMode {
                if ball.hasHitObstaclePreviously {
                    ballsLimit += 1
                }
                if isClearFromObstacles() {
//                    levelUP()
                    ballsLimit = 5
                    level += 1
                    clearParticles()
                    shortGame(level)
                } else {
                    score += 1
                }
            } else {
                score += 1
            }
        } else if object.name == "bad" {
            clearParticles()
            destroy(ball)
            if shortGameMode {
                if isClearFromObstacles() {
//                    levelUP()
                    ballsLimit = 5
                    level += 1
                    clearParticles()
                    shortGame(level)
                } else {
                    score -= 1
                }
            } else {
                score -= 1
            }
        } else if object.name == "obstacle" && (shortGameMode || demolitionMode) {
            if shortGameMode && !hardMode {
                ball.hasHitObstaclePreviously = true
            }
            destroy(object)
        }
    }
    
    func destroy(_ object: SKNode) {
//        clearParticles()
        if object.name == "ball" {
            if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
                fireParticles.position = object.position
                fireParticles.name = "particles"
                addChild(fireParticles)
            }
        } else {
            if let fireParticles = SKEmitterNode(fileNamed: "MagicParticles") {
                fireParticles.position = object.position
                fireParticles.name = "particles"
                addChild(fireParticles)
            }
        }
        object.removeFromParent()
    }
   
    
    func shortGame(_ level: Int = 0) {
        for _ in 0...(4 + level) {
            makeObstacle(at: CGPoint(x: CGFloat.random(in: 20...(895 - 20)), y: CGFloat.random(in: (414 / 3)...(414 - 414 / 3))))
        }
    }
    
    func clearObstacles() {
        for child in self.children {
            if child.name == "obstacle" {
                child.removeFromParent()
            }
        }
    }    
    
    func clearParticles() {
        for child in self.children {
            if child.name == "particles" {
                child.removeFromParent()
            }
        }
    }
    
    func isClearFromObstacles() -> Bool {
        for child in self.children {
            if child.name == "obstacle" {
                return false
            }
        }
        return true
    }
    
    func restartGame() {
        clearParticles()
        clearObstacles()
        resetInitialValues()
        shortGame()
    }
    
    func resetInitialValues() {
        ballsLimit = 5
        level = 0
        score = 0
    }
    
    func showAlert() {
        let ac = UIAlertController(title: "Save your Record!", message: "Please enter your name. If you leave it blank, a random animal will be used.", preferredStyle: .alert)
        ac.addTextField { textField in
            textField.placeholder = "Enter your name"
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            let textField = ac.textFields![0]
            let userInput = textField.text ?? ""
            
            if userInput.isEmpty {
                self?.handleUserInput(self?.getRandomAnimalEmoji() ?? "")
            } else {
                self?.handleUserInput(userInput)
            }
            
            self?.clearScreen()
            self?.makeRecordsScreen()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.clearScreen()
            self?.makeShortGameScreen()
            self?.restartGame()
        }
        
        ac.addAction(okAction)
        ac.addAction(cancelAction)
        
        if let viewController = view?.window?.rootViewController {
            viewController.present(ac, animated: true)
        }
    }
    
    func getRandomAnimalEmoji() -> String {
        return ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔", "🐧", "🐦", "🐤", "🐣"].randomElement() ?? "🐸"
    }
    
    func handleUserInput(_ input: String) {
        print("User input: \(input)")
//        if let encoded = try? JSONEncoder().encode([UserRecord(nickname: input, record: score)])
        let newRecord = UserRecord(nickname: input, record: score, level: level)
        addNewRecord(newRecord)
    }
    
    func addNewRecord(_ record: UserRecord) {
        var records = [UserRecord]()
        
        if let data = UserDefaults.standard.data(forKey: "userRecords"),
           let savedRecords = try? JSONDecoder().decode([UserRecord].self, from: data) {
            records = savedRecords
        }
        records.append(record)
        records.sort()
        let sortedTenRecords = records.prefix(10).sorted()
        // Save updated records to UserDefaults
        if let encoded = try? JSONEncoder().encode(sortedTenRecords) {
            UserDefaults.standard.set(encoded, forKey: "userRecords")
        }
    }
    
    func getSortedRecords() -> [UserRecord]? {
        if let data = UserDefaults.standard.data(forKey: "userRecords"), let records = try? JSONDecoder().decode([UserRecord].self, from: data) {
            return records.sorted()
        }
        return nil
    }

    
    func showRecordLabel(index: Int, record: UserRecord) {
        print("label \(index)\t" + record.nickname + "\t" + "\(record.record)")
        
        let label = SKLabelNode(fontNamed: "Chalkduster")
        if index < 5 {
            makeLeftLabel(name: label, text: "\(index + 1)\t" + record.nickname + "\t" + "\(record.record)" + "\t" + "\(record.level)", position: CGPoint(x: 896 / 6, y: 414 - 100 - 32 * index))
            label.horizontalAlignmentMode = .left
        } else if index < 10 {
            makeLeftLabel(name: label, text: "\(index + 1)\t" + record.nickname + "\t" + "\(record.record)" + "\t" + "\(record.level)", position: CGPoint(x: 896 * 2 / 3, y: 414 - 100 - 32 * (index % 5)))
            label.horizontalAlignmentMode = .left
        }
        recordListName(label)
        self.addChild(label)
    }
    
    func clearRecords() {
        let ac = UIAlertController(title: "Are you sure?", message: "All records will be lost", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            let records = [UserRecord]()
            if let encoded = try? JSONEncoder().encode(records) {
                UserDefaults.standard.set(encoded, forKey: "userRecords")
            }
            
            self?.clearScreen()
            self?.makeRecordsScreen()
        })
        
        if let vc = view?.window?.rootViewController {
            vc.present(ac, animated: true)
        }
    }
    
    func returnToGame() {
        clearScreen()
        makeDefaultScreen()
        shortGameMode = false
        showRecords = false
        resetInitialValues()
    }
}
