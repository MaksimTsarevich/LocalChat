//
//  TableViewHeader.swift
//  LocalChat
//
//  Created by Maks Tsarevich on 15.12.23.
//

import UIKit

class TableViewHeader: UITableViewHeaderFooterView {
    
    let title = UILabel()
    let view = UIView()
    
    // - Blur
    lazy var blurredView: UIView = {
        let containerView = UIView()
        let blurEffect = UIBlurEffect(style: .light)
        let customBlurEffectView = CustomBlurView(effect: blurEffect, intensity: 0.2)
        customBlurEffectView.frame = self.view.bounds
        let dimmedView = UIView()
        dimmedView.backgroundColor = .black.withAlphaComponent(0.2)
        dimmedView.frame = self.view.bounds
        containerView.addSubview(customBlurEffectView)
        containerView.addSubview(dimmedView)
        return containerView
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(view)
        view.addSubview(title)
//        addSubview(title)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        title.font = UIFont.systemFont(ofSize: 10)
        let size = title.sizeThatFits(CGSize(width: 2 * (bounds.size.width / 3), height: .greatestFiniteMagnitude))
        view.frame = CGRect(x: (contentView.frame.width / 2) - (25), y: 10, width: 50, height: 20)
        view.addSubview(blurredView)
        view.sendSubviewToBack(blurredView)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        
        title.frame = CGRect(x: 5, y: 0, width: view.frame.width - 10, height: view.frame.height)
        title.textColor = UIColor.white
        title.textAlignment = .center
//        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        
    }
    
    func apply() {
        title.text = "Today"
        setNeedsLayout()
    }
}
