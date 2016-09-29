//
//  ViewController.swift
//  proj_8
//
//  Created by dh on 9/28/16.
//  Copyright © 2016 dhfromkorea. All rights reserved.
//

import UIKit
import GameKit

class ViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var cluesLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var currentAnswer: UITextField!
    
    @IBAction func submitTapped(_ sender: AnyObject) {
        guard let foundAt = solutions.index(of: currentAnswer.text!) else {
            let ac = UIAlertController(title: "oops, wrong!", message: "would you try again?", preferredStyle: .alert)
            let action = UIAlertAction(title: "try again", style: .default, handler: clearTapped)
            ac.addAction(action)
            present(ac, animated: true)
            return
        }
        
        var clues = cluesLabel.text!.components(separatedBy: "\n")
        clues[foundAt] = currentAnswer.text!
        cluesLabel.text = clues.joined(separator: "\n")
        
        var answers = answersLabel.text!.components(separatedBy: "\n")
        answers[foundAt] = ""
        answersLabel.text = answers.joined(separator: "\n")
        
        score += 1
        
        currentAnswer.text = ""
        activatedButtons.removeAll()
        
        
        if score % 7 == 0 {
            let ac = UIAlertController(title: "Level \(level) Completed!", message: "Ready for the next level?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
            present(ac, animated: true)
        }
    }
    
    @IBAction func clearTapped(_ sender: AnyObject) {
        for btn in activatedButtons {
            btn.isHidden = false
        }
        currentAnswer.text = ""
        activatedButtons.removeAll()
    }
    
    var letterButtons = [UIButton]()
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var level = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for sv in view.subviews where sv.tag == 1001 {
            let btn = sv as! UIButton
            letterButtons.append(btn)
            btn.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
        }
        loadLevel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: game functions
    func letterTapped(btn: UIButton) {
        currentAnswer.text = currentAnswer.text! + btn.titleLabel!.text!
        activatedButtons.append(btn)
        btn.isHidden = true
    }
    
    func loadLevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        guard let filePath = Bundle.main.path(forResource: "level\(level)", ofType: "txt"),
              let levelData = try? String(contentsOfFile: filePath) else {
                print("leveldata...")
                return
        }

        var lines = levelData.components(separatedBy: "\n")
        lines = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: lines) as! [String]
        
        for (i, line) in lines.enumerated() {
            let parts = line.components(separatedBy: ": ")
            let answer = parts[0]
            let clue = parts[1]
            
            clueString += "\(i + 1). \(clue)\n"
            
            let solutionWord = answer.replacingOccurrences(of: "|", with: "")
            solutions.append(solutionWord)
            solutionString += "\(solutionWord.characters.count) letters\n"
            
            let bits = answer.components(separatedBy: "|")
            letterBits += bits
        }
        
        cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
        letterBits = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: letterBits) as! [String]
        if letterBits.count == letterButtons.count {
            print("setting title for letterbits")
            for i in 0 ..< letterBits.count {
                letterButtons[i].setTitle(letterBits[i], for: .normal)
            }
        }
    }
    
    func levelUp(action: UIAlertAction) {
        level += 1
        // clear any data
        solutions.removeAll(keepingCapacity: true)
        
        loadLevel()
        
        for btn in letterButtons {
            btn.isHidden = false
        }
    }
}

