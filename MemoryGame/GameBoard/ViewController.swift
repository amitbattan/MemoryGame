//
//  ViewController.swift
//  Accedo
//
//  Created by Amit Kumar Battan on 22/05/17.
//  Copyright © 2017 Amit Kumar Battan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CardGameViewModelDelegate {

    //Configuration
    let cardPadding:CGFloat = 5.0
    let delayTime = 1.0
    let cardHeightWidthRatio:CGFloat = 190/152

    //UI property
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!

    var viewModel:CardGameViewModel = CardGameViewModel()
    var isAnimationForScoreBreak = true

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        viewModel.startGame()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Handle Orientation of game board
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    //MARK: - IBActions
    //Action on tap high scores
    @IBAction func highScoresControlAction(_ sender: UIControl?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ScoresViewController") as! ScoresViewController
        let scores = viewModel.getAllScores()
        let scoresViewModel = ScoresViewModel(scores: scores, currentScore: nil) //initilize ScoresViewModel
        vc.viewModel = scoresViewModel
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true, completion: nil)
    }
    
    //Action on start new game
    @IBAction func startNewGameBtnAction(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Start new game!", message: "Do you want to start new game?", preferredStyle: .alert)
        let startAction = UIAlertAction(title: "Start", style: .default) { (_) in
            //Start new game
            alertController.dismiss(animated: true)
            self.viewModel.startGame()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            //Cancel action
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(startAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - UICollectionView DataSource/Delgate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.totalCards
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as! CardCollectionViewCell
        //Set image card_bg to make it face down
        cell.configureCell(imageName: "card_bg")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        //return false if card already selected or has matched
        return !viewModel.isSelectedOrMatched(for: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell

        //Show card color
        let card = viewModel.card(at: indexPath.row)
        //chnage image to make it face up
        cell.configureCell(imageName: "colour\(card?.cardNo ?? "0")")
    
        //call cardSelect
        viewModel.cardSelect(at: indexPath.row)
        collectionView.deselectItem(at: indexPath, animated:true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //Set card width height
        let cardWidth: CGFloat = (collectionView.bounds.width  - ( cardPadding * 3 )) / 4.0
        let cardHeight = cardWidth * cardHeightWidthRatio // height in proportion to width
        return CGSize(width: cardWidth, height: cardHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        //padding between acrds
        return cardPadding
    }
    
    //MARK: - View Model Delegates
    //Card Match result
    func cardMatches(firstIndex:Int, secondIndex:Int, isMatch:Bool) {
        let firstCard = collectionView.cellForItem(at: IndexPath(row: firstIndex, section: 0)) as? CardCollectionViewCell
        let secondCard = collectionView.cellForItem(at: IndexPath(row: secondIndex, section: 0)) as? CardCollectionViewCell

        self.collectionView.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
            if isMatch {
                //Hide Card if it is a match
                firstCard?.hideCard()
                secondCard?.hideCard()
            } else {
                //Face down cards again if it is not a match
                firstCard?.configureCell(imageName: "card_bg")
                secondCard?.configureCell(imageName: "card_bg")
            }
            self.collectionView.isUserInteractionEnabled = true
        }
    }
    
    //Start new game result
    func loadNewGame() {
        collectionView.reloadData()
        isAnimationForScoreBreak = true
    }
    
    //Update score
    func updateScore(score:Int, highestScore:Int?) {
        scoreLabel.text = "\(score)"
        
        guard let highestScore = highestScore else {
            return
        }

        if score > 0 && isAnimationForScoreBreak == true && score == highestScore {
            //Animate high score label if high score breaks
            isAnimationForScoreBreak = false
            let oldTransform = self.highScoreLabel.transform
            self.highScoreLabel.transform = self.highScoreLabel.transform.scaledBy(x: 0.35, y: 0.35);
            
            UIView.animate(withDuration: 1.0, animations: {
                self.highScoreLabel.transform = self.highScoreLabel.transform.scaledBy(x: 5, y: 5);
                self.highScoreLabel.text = "\(highestScore)"
            }) { (_) in
                UIView.animate(withDuration: 1.0, animations: {
                    self.highScoreLabel.transform = oldTransform
                })
            }
        } else {
            highScoreLabel.text = "\(highestScore)"
        }

        if isAnimationForScoreBreak == false, score < highestScore {
            //If anytime score is less then highScore
           isAnimationForScoreBreak = true
        }

    }

    //Finish game
    func gameFinish(scroe:Scores) {
        //Show score list with current game detail
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ScoresViewController") as! ScoresViewController
        let scores = viewModel.getAllScores()
        let scoresViewModel = ScoresViewModel(scores: scores, currentScore: scroe) //initilize ScoresViewModel
        vc.viewModel = scoresViewModel
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true) {
            self.viewModel.startGame()
        }
    }

}
