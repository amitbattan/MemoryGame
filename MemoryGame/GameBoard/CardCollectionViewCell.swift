//
//  CardCollectionViewCell.swift
//  Accedo
//
//  Created by Amit Kumar Battan on 23/05/17.
//  Copyright © 2017 Amit Kumar Battan. All rights reserved.
//

import Foundation
import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cardImageView: UIImageView!

    func configureCell(imageName:String) {
        self.cardImageView.isHidden = false
        
        //Flip animation
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        UIView.transition(with: cardImageView, duration: 0.3, options: transitionOptions, animations: {
            //set image
            self.cardImageView.image = UIImage(named: imageName)
        })
    }

    func hideCard() {
        //Flip animation
        let transitionOptions: UIViewAnimationOptions = [.transitionCrossDissolve, .showHideTransitionViews]
        UIView.transition(with: cardImageView, duration: 0.3, options: transitionOptions, animations: {
            //hide image
            self.cardImageView.isHidden = true
        })
    }    
    
}
