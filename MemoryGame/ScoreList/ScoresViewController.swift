//
//  ScoresViewController.swift
//  Accedo
//
//  Created by Amit Kumar Battan on 25/05/17.
//  Copyright © 2017 Amit Kumar Battan. All rights reserved.
//

import Foundation
import UIKit

//Class responsible for showing list of scores
class ScoresViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    //UI property
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var validationErrorLabel: UILabel!
    @IBOutlet weak var playeNameTF: UITextField!
    @IBOutlet weak var currentGameView: UIView!
    @IBOutlet weak var currentGameViewHeight: NSLayoutConstraint!

    var viewModel:ScoresViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //Add close button in nav bar
        let barButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.done, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = barButtonItem

        if let currentGameScoreIndex = viewModel.currentGameScoreIndex {
            //If view controller open after game over, show player name edit option and score detail
            currentGameViewHeight.constant = 150
            let scoreInfo = viewModel.getCurrentGameScoreInfo()
            let playerName = scoreInfo.playerName ?? ""
            let score = scoreInfo.playerScore ?? 0

            playeNameTF.text = playerName
            infoLabel.text = "You have score \(score) and your ranking is \(currentGameScoreIndex + 1)"
            tableView.scrollToRow(at: IndexPath(row: currentGameScoreIndex, section: 0), at: UITableViewScrollPosition.top, animated: true)
            playeNameTF.becomeFirstResponder()
        } else {
            //If view controller open to show score list only, hide current game score details
            currentGameViewHeight.constant = 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backButtonTapped () {
        navigationController?.dismiss(animated: true)
    }
    
    //MARK: - UITextFieldDelegate Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let playerName = textField.text, let error = viewModel.updatePlayerName(playeName: playerName) {
            validationErrorLabel.text = error
            textField.becomeFirstResponder()
        } else {
            validationErrorLabel.text = ""
            textField.resignFirstResponder()
            UIView.animate(withDuration: 2.0) {
                self.currentGameViewHeight.constant = 0
            }
            tableView.reloadData()
        }
    }
    
    //MARK: - UITableView DataSource/Delgate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalRecords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreCell", for: indexPath) 
        let scoreInfo = viewModel.getScoreInfo(at: indexPath.row)
        let playerName = scoreInfo.playerName ?? ""
        cell.textLabel?.text = "\(indexPath.row+1).\t\(playerName)"
        cell.detailTextLabel?.text = "\(scoreInfo.playerScore ?? 0)"
        
        if let currentGameScoreIndex = viewModel.currentGameScoreIndex, indexPath.row == currentGameScoreIndex {
            //UI for current game score
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        } else {
            //UI for other game score
            cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        }
        
        return cell
    }
    
    //Hide header for group tableview
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}
