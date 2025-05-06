//
//  TableViewCell.swift
//  LocalChat
//
//  Created by Maks Tsarevich on 5.12.23.
//

import UIKit
import SwipeCellKit

class TableViewCell: UITableViewCell {
    
    // - UI
    private let nameLabel = UILabel()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let messageView = UIView()
    private let dateLabel = UILabel()
    private var image = UIImageView()
    
    private let replyView = UIView()
    private let replyUser = UILabel()
    private let replyMessage = UILabel()
    
    // - Data
    var messageSender: MessageSender = .ourself
    
    private var sendOne = true
    private var getOne = true
    static var reply = false
    static var replyU: String?
    static var replyM: String?
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//    }
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        messageLabel.clipsToBounds = true
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        
        nameLabel.textColor = .lightGray
        nameLabel.font = UIFont.systemFont(ofSize: 10)
        
        clipsToBounds = true
        
        addSubview(messageView)
        messageView.addSubview(messageLabel)
        messageView.addSubview(timeLabel)
        addSubview(image)
        
        messageView.addSubview(replyView)
        replyView.isHidden = true
    }
    
    func getMessageView() -> UIView {
//        messageView.frame = getFrameMessage()
        return messageView
    }
    
    func getFrameMessage() -> CGRect {
        // Предположим, что messageView - это ваше представление, для которого вы хотите получить CGRect относительно экрана

        // Получаем текущую активную сцену
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            // Получаем CGRect относительно окна
            let frameInWindow = messageView.convert(messageView.bounds, to: window)

            // Если вам нужно получить CGRect относительно экрана, вы можете использовать UIScreen.main.bounds
            let frameInScreen = window.convert(frameInWindow, to: UIScreen.main.coordinateSpace)

            return frameInScreen
        }

        // Если не удалось получить сцену или окно, вернем CGRect.zero
        return CGRect.zero
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = .clear
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        timeLabel.font = UIFont.systemFont(ofSize: 10)
        messageLabel.textColor = .black
        
        let addWidth: CGFloat = messageSender == .ourself ? 60 : 50
        let addXTime = messageSender == .ourself ? 44 : 34
        
        image.frame = CGRect(x: 10, y: 0, width: 300, height: 300)
        image.contentMode = .scaleAspectFill
        
        if let replyUser = replyUser.text, let replyMessage = replyMessage.text {
            replyView.isHidden = false
            replyView.backgroundColor = .green
            replyView.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        }
        
        let size = messageLabel.sizeThatFits(CGSize(width: 2 * (bounds.size.width / 3), height: .greatestFiniteMagnitude))
        messageView.frame = CGRect(x: 10, y: 0, width: size.width + addWidth, height: TableViewCell.replyU != nil ? (size.height + 48) : size.height + 8)
        messageLabel.frame = CGRect(x: TableViewCell.replyU != nil ? 50 : 10, y: 0, width: messageView.bounds.width - 32, height: TableViewCell.replyU != nil ? messageView.bounds.height - 2 - 50 : messageView.bounds.height - 2)
        timeLabel.frame = CGRect(x: Int(messageView.bounds.width) - addXTime, y:  Int(messageView.bounds.height) - 12, width: 32, height: 10)
        timeLabel.text = getTime()
        messageView.layer.cornerRadius = 7
        image.layer.cornerRadius = 7
        
        if messageSender == .ourself {
            image.center = CGPoint(x: bounds.size.width - image.bounds.size.width/2.0 - 8, y: bounds.size.height/2.0)
            messageView.center = CGPoint(x: bounds.size.width - messageView.bounds.size.width/2.0 - 8, y: bounds.size.height/2.0)
            messageView.backgroundColor = UIColor(red: CGFloat(220) / 255.0,
                                                  green: CGFloat(248) / 255.0,
                                                  blue: CGFloat(197) / 255.0, alpha: 1)
            timeLabel.textColor = UIColor(red: CGFloat(79) / 255.0,
                                          green: CGFloat(174) / 255.0,
                                          blue: CGFloat(78) / 255.0,
                                          alpha: 1)
            image.roundCorners([.topLeft, .bottomLeft, .topRight], radius: 12)
            messageView.roundCorners([.topLeft, .bottomLeft, .topRight], radius: 12)
            
        } else {
            timeLabel.textColor = UIColor(red: CGFloat(104) / 255.0,
                                          green: CGFloat(108) / 255.0,
                                          blue: CGFloat(114) / 255.0,
                                          alpha: 0.75)
            nameLabel.sizeToFit()
            nameLabel.center = CGPoint(x: nameLabel.bounds.size.width / 2.0 + 16 + 4, y: nameLabel.bounds.size.height/2.0)
            messageView.center = CGPoint(x: messageView.bounds.size.width / 2.0 + 8, y: bounds.size.height/2.0)
            image.center = CGPoint(x: image.bounds.size.width / 2.0 + 8, y: bounds.size.height/2.0)
            messageView.backgroundColor = .white
            image.roundCorners([.topLeft, .topRight, .bottomRight], radius: 12)
            messageView.roundCorners([.topLeft, .topRight, .bottomRight], radius: 12)
        }
        TableViewCell.reply = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func apply(message: Message) {
        nameLabel.text = message.senderUsername
        messageSender = message.messageSender
        messageLabel.text = message.message
        image.image = message.image
        if let replyName = message.replyName, let replyMessage = message.replyMessage {
            TableViewCell.replyU = replyName
            TableViewCell.replyM = replyMessage
            self.replyUser.text = replyName
            self.replyMessage.text = replyMessage
        } else {
            TableViewCell.replyU = nil
            TableViewCell.replyM = nil
        }
       
        setNeedsLayout()
    }
    
    func hiddenInfo(_ isHidden: Bool) {
        nameLabel.isHidden = isHidden
        messageView.isHidden = isHidden
        messageLabel.isHidden = isHidden
    }
    
    class func height(for message: Message) -> CGFloat {
        let maxSize = CGSize(width: 2*(UIScreen.main.bounds.size.width/3), height: CGFloat.greatestFiniteMagnitude)
        let messageHeight = getHeight(forText: message.message, fontSize: 17, maxSize: maxSize)
        
        return TableViewCell.replyM != nil ? messageHeight + 16 + 42 : messageHeight + 16
    }
    
    private class func getHeight(forText text: String, fontSize: CGFloat, maxSize: CGSize) -> CGFloat {
        let font = UIFont(name: "Helvetica", size: fontSize)!
        let attrString = NSAttributedString(string: text, attributes:[NSAttributedString.Key.font: font,
                                                                      NSAttributedString.Key.foregroundColor: UIColor.white])
        let textHeight = attrString.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, context: nil).size.height
        
        return textHeight
    }
    
    func getDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        let result = formatter.string(from: date)
        return result
    }
    
    func getTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let result = formatter.string(from: date)
        return result
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
  func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    self.layer.mask = mask
  }
}
