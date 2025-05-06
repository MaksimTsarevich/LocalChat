//
//  ChatsCollectionViewCell.swift
//  LocalChat
//
//  Created by Maks Tsarevich on 20.03.24.
//

import UIKit

class ChatsCollectionViewCell: UICollectionViewCell {
 
    // - UI
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameDiscriptionLabel: UILabel!
    
    func setupCell(_ model: ProfileModel) {
        nameLabel.text = model.login
        nameDiscriptionLabel.text = model.login.first?.uppercased()
    }
}
