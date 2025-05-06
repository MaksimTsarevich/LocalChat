//
//  SecondViewController.swift
//  LocalChat
//
//  Created by Maks Tsarevich on 5.12.23.
//

import UIKit
//import TLPhotoPicker
import Photos

class SecondViewController: UIViewController, TableDataSourceDelegate, ResendViewControllerDelegate {
    
    func replyMessage(_ message: Message) {
        replyView.transform = CGAffineTransform(translationX: 0, y: -(keyboardHeight + bottomView.bounds.height - 40))
        replyUser = message.senderUsername
        replyMessage = message.message
        replyUserLabel.text = "Reply to \(message.senderUsername)"
        replyMessageLabel.text = message.message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.replyView.isHidden = false
        }
//        tableView.scrollToRow(at: IndexPath(row: dataSource.getMessagesLast(), section: 0), at: .bottom, animated: true)
        reply = true
    }
    
    func copyMessage(_ message: Message) {
        print("cop")
    }
    
    func editMessage(_ message: Message) {
        print("edit")
    }
    
    func pinMessage(_ message: Message) {
        print("pin")
    }
    
    func forwardMessage(_ message: Message) {
        print("forward")
    }
    
    func deleteMessage(_ message: Message) {
        print("delete")
    }
    
    func selectMessage(_ message: Message) {
        print("seelct")
    }
    
    func resendMessageFrame(_ rect: CGRect, message: Message) {
        let vc = UIStoryboard(name: "Resend", bundle: nil).instantiateInitialViewController() as! ResendViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.messageView.frame = rect
        vc.message = message
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func updateMessages(_ messages: [Message]) {
//        let window = UIApplication.shared.windows.first
//        let topPadding = window?.safeAreaInsets.top ?? 0
        self.messages = messages
        var cellHeights: CGFloat = 30
        for i in 0..<messages.count {
            if let height = messages[i].heightCell {
                cellHeights += height
            }
        }
        var newY = heightTable - cellHeights
        var height = cellHeights
        if keyboardHeight > 0 {
             newY = heightTable - cellHeights - keyboardHeight + 20
            if reply {
                newY -= replyView.bounds.height
            }
        }
        
        if height < heightTable - 91 {
//            tableView.isScrollEnabled = false
            if height > bottomView.frame.minY - 91 {
                tableView.isScrollEnabled = true
                height = bottomView.frame.minY - 91
            }
            newHeightTable = height
            UIView.transition(with: tableView, duration: 0.3) { [weak self] in
                guard let sSelf = self else { return }
                sSelf.tableView.frame = CGRect(x: 0, y: newY < 91 ? 91 : newY, width: UIScreen.main.bounds.width, height: CGFloat(sSelf.reply ? height - sSelf.replyView.bounds.height : height))
            }
        } else {
            UIView.transition(with: tableView, duration: 0.3) { [weak self] in
                guard let sSelf = self else { return }
                sSelf.tableView.frame = CGRect(x: 0, y: 91, width: UIScreen.main.bounds.width, height: sSelf.reply ? sSelf.heightTable - 91 - sSelf.keyboardHeight + 20 - sSelf.replyView.bounds.height : sSelf.heightTable - 91 - sSelf.keyboardHeight + 20)
            }
            tableView.isScrollEnabled = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView.alpha = 1
        }
    }
    
    
    // - UI
    private let imageView = UIImageView()
    private let bottomView = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton()
    private let tableView = UITableView()
    private let flipButton = UIButton()
    private let micButton = UIButton()
    
    private let replyView = UIView()
    private let replyUserLabel = UILabel()
    private let replyMessageLabel = UILabel()
    private let replyButton = UIButton()
    
    // - DataSource
    private var dataSource: TableDataSource!
    
    // - Data
    var username = "User"
    let name = "Admin"
//    let chatRoom = ChatRoom()
    var webSocketTask: URLSessionWebSocketTask?
    var messages: [Message] = []
    var heightTable: CGFloat = 0
    var newHeightTable: CGFloat = 0
    var keyboardHeight: CGFloat = 0
    var photos = [PHAsset]()
    var mic = true
    var reply = false
    var replyUser = ""
    var replyMessage = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        chatRoom.delegate = self
//        chatRoom.setupNetworkCommunication()
//        chatRoom.joinChat(username: username)
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.937, green: 0.937, blue: 0.937, alpha: 1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webSocketTask?.cancel()
//        chatRoom.stopChatSession()
    }
    
    func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let sSelf = self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        if let message = sSelf.checkMessage(text) {
                            DispatchQueue.main.async {
                                sSelf.dataSource.insertNewMessageCell(message)
                            }
                        }
                    }
                case .string(let text):
                    if let message = sSelf.checkMessage(text) {
                        DispatchQueue.main.async {
                            sSelf.dataSource.insertNewMessageCell(message)
                        }
                    }
                @unknown default:
                    print("Unknown message type received")
                }
                // Продолжаем ожидание новых сообщений
                sSelf.receiveMessage()
            case .failure(let error):
                print("Error receiving message: \(error)")
            }
        }
    }
    
    func sendMessageApi(_ message: String) {
        let data = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(data) { [weak self] error in
            guard let sSelf = self else { return }
            if let error = error {
                print("Error sending message: \(error)")
            } else {
                print("Message sent successfully")
            }
        }
    }
    
    func checkMessage(_ message: String) -> Message? {
        var mess = message
        if let range = mess.range(of: "User: ") {
            mess.removeSubrange(range)
        }
        let components = mess.components(separatedBy: ": ")
        if components.count == 2 {
            let name = components[0]
            let message = components[1]
            let messageSender: MessageSender = (self.name == name) ? .ourself : .someoneElse
            let model = Message(message: message, messageSender: messageSender, username: name, image: nil)
            print("\(message) + \(name) + \(messageSender)")
            return model
        } else {
            print("Строка не содержит имя и сообщение в нужном формате.")
            return nil
        }
    }
}

extension SecondViewController: ChatRoomDelegate {
    func received(message: Message) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dataSource.insertNewMessageCell(message)
        }
    }
}

// MARK: -
// MARK: - Configure

private extension SecondViewController {
    
    func configure() {
        configureURL()
        configureBottomView()
        configureDataSource()
        subscribeToKeyboardNotification()
        addAction()
    }
    
    func configureURL() {
        webSocketTask = URLSession.shared.webSocketTask(with: URL(string: "ws://localhost:6969/ws?room=\(username)")!)
        configureChat()
    }
    
    func configureChat() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.webSocketTask?.resume()
            self?.receiveMessage()
            DispatchQueue.main.async {
                self?.sendMessageApi("John: Hello, WebSocket!")
            }
        }
    }
    
    func configureBottomView() {
        let window = UIApplication.shared.windows.first
        let topPadding = window?.safeAreaInsets.top
        
        view.backgroundColor = UIColor(red: 0.937, green: 0.937, blue: 0.937, alpha: 1)
        
        view.addSubview(imageView)
        imageView.image = UIImage(named: "backImage")
        imageView.frame = CGRect(x: 0, y: topPadding ?? 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        
        
        bottomView.backgroundColor = UIColor(red: 0.937, green: 0.937, blue: 0.937, alpha: 1)
        bottomView.frame = CGRect(x: 0, y: Int(UIScreen.main.bounds.height) - 60, width: Int(UIScreen.main.bounds.width), height: 60)
        
        view.addSubview(tableView)
        tableView.backgroundColor = .clear
        
        tableView.frame = CGRect(x: 0, y: 91, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - bottomView.bounds.height)
        tableView.clipsToBounds = true
        
        view.addSubview(bottomView)
        
        replyView.backgroundColor = UIColor(red: 0.937, green: 0.937, blue: 0.937, alpha: 1)
        replyView.frame = CGRect(x: 0, y: bottomView.frame.minY - 50, width: UIScreen.main.bounds.width, height: 50)
        view.addSubview(replyView)
        
        replyUserLabel.text = "Reply to Maks Tsarevich"
        replyUserLabel.textColor = .systemBlue
        replyUserLabel.frame = CGRect(x: 45, y: 5, width: 200, height: 20)
        replyUserLabel.font = UIFont.systemFont(ofSize: 14)
        replyView.addSubview(replyUserLabel)
        
        replyView.isHidden = true
        
        replyMessageLabel.text = "dffdgdfgfdg"
        replyMessageLabel.textColor = .black
        replyMessageLabel.font = UIFont.systemFont(ofSize: 14)
        replyMessageLabel.frame = CGRect(x: 45, y: 25, width: 200, height: 20)
        replyView.addSubview(replyMessageLabel)
        
        replyButton.backgroundColor = .clear
        replyButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        replyButton.tintColor = .systemBlue
        replyButton.frame = CGRect(x: replyView.bounds.width - 30, y: (replyView.bounds.height / 2) - 10, width: 20, height: 20)
        replyView.addSubview(replyButton)
        
        tableView.alpha = 0
        heightTable = tableView.bounds.height
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.937, green: 0.937, blue: 0.937, alpha: 1)
        
        view.frame = CGRect(x: 0, y: 5, width: UIScreen.main.bounds.width, height: 26)
        bottomView.addSubview(view)
        
        
        flipButton.setImage(UIImage(systemName: "paperclip"), for: .normal)
        flipButton.tintColor = UIColor(red: 0.553, green: 0.565, blue: 0.576, alpha: 1)
        view.addSubview(flipButton)
        flipButton.frame = CGRect(x: 5, y: 0, width: 26, height: 26)

        sendButton.backgroundColor = .systemBlue
        sendButton.setImage(UIImage(systemName: "arrow.up"), for: .normal)
        sendButton.tintColor = .white
        view.addSubview(sendButton)
        sendButton.frame = CGRect(x: bottomView.bounds.width - 35, y: 0, width: 26, height: 26)
        sendButton.layer.cornerRadius = 13
        
        
        micButton.backgroundColor = .clear
        micButton.setImage(UIImage(systemName: "mic"), for: .normal)
        micButton.tintColor = .lightGray
        view.addSubview(micButton)
        micButton.frame = CGRect(x: bottomView.bounds.width - 35, y: -2, width: 26, height: 26)
        
        
        let textView = UIView()
        textView.backgroundColor = .white
        view.addSubview(textView)
        textView.frame = CGRect(x: Int(flipButton.bounds.width + 9), y: 0, width: Int(sendButton.frame.minX - (flipButton.bounds.width + 9) - 4), height: 26)
        textView.layer.cornerRadius = 13
        
        let smileButton = UIButton()
        smileButton.setImage(UIImage(systemName: "smiley"), for: .normal)
        smileButton.tintColor = UIColor(red: 0.553, green: 0.565, blue: 0.576, alpha: 1)
        textView.addSubview(smileButton)
        smileButton.frame = CGRect(x: Int(textView.bounds.maxX) - 25, y: 3, width: 20, height: 20)
        
        textView.addSubview(messageTextField)
        messageTextField.placeholder = "Message..."
        messageTextField.frame = CGRect(x: 5, y: 2, width: Int(smileButton.frame.minX) - 15, height: 20)
        messageTextField.font = UIFont.systemFont(ofSize: 14)
        messageTextField.delegate = self
        
        sendButton.alpha = 0
        sendButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        
    }
    
    func configureDataSource() {
        tableView.separatorStyle = .none
        dataSource = TableDataSource(tableView: tableView, messages: messages, delegate: self)
        tableView.clipsToBounds = true
    }
    
    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addAction() {
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        flipButton.addTarget(self, action: #selector(showPicker), for: .touchUpInside)
        micButton.addTarget(self, action: #selector(changeTypeLive), for: .touchUpInside)
        replyButton.addTarget(self, action: #selector(crossReply), for: .touchUpInside)
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressButtonLongPressed(_:)))
        micButton.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    // - Action
    @objc func crossReply() {
        replyView.isHidden = true
        reply = false
        
        var cellHeights: CGFloat = 30
        for i in 0..<messages.count {
            if let height = messages[i].heightCell {
                cellHeights += height
            }
        }
        var newY = heightTable - cellHeights
        var height = cellHeights
        if keyboardHeight > 0 {
             newY = heightTable - cellHeights - keyboardHeight + 20
            if reply {
                newY -= replyView.bounds.height
            }
        }
        
        if height < heightTable - 91 {
//            tableView.isScrollEnabled = false
            if height > bottomView.frame.minY - 91 {
                tableView.isScrollEnabled = true
                height = bottomView.frame.minY - 91
            }
            newHeightTable = height
            UIView.transition(with: tableView, duration: 0.3) { [weak self] in
                guard let sSelf = self else { return }
                sSelf.tableView.frame = CGRect(x: 0, y: newY < 91 ? 91 : newY, width: UIScreen.main.bounds.width, height: CGFloat(sSelf.reply ? height - sSelf.replyView.bounds.height : height))
            }
        } else {
            UIView.transition(with: tableView, duration: 0.3) { [weak self] in
                guard let sSelf = self else { return }
                sSelf.tableView.frame = CGRect(x: 0, y: 91, width: UIScreen.main.bounds.width, height: sSelf.reply ? sSelf.heightTable - 91 - sSelf.keyboardHeight + 20 - sSelf.replyView.bounds.height : sSelf.heightTable - 91 - sSelf.keyboardHeight + 20)
            }
            tableView.isScrollEnabled = true
        }
    }
    
    @objc func sendMessage() {
        if let text = messageTextField.text {
            if !text.isEmpty {
                var newText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if reply {
                    newText += "$user$\(replyUser)"
                    newText += "$message$\(replyMessage)$"
                }
                sendMessageApi("\(name): \(newText)")
                messageTextField.text = ""
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.micButton.alpha = 1
                }
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.sendButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    self?.sendButton.alpha = 0
                }
            }
        }
        replyUser = ""
        replyMessage = ""
        replyView.isHidden = true
        reply = false
        var cellHeights: CGFloat = 30
        for i in 0..<messages.count {
            if let height = messages[i].heightCell {
                cellHeights += height
            }
        }
        var newY = heightTable - cellHeights
        var height = cellHeights
        if keyboardHeight > 0 {
             newY = heightTable - cellHeights - keyboardHeight + 20
            if reply {
                newY -= replyView.bounds.height
            }
        }
        
        if height < heightTable - 91 {
            if height > bottomView.frame.minY - 91 {
                tableView.isScrollEnabled = true
                height = bottomView.frame.minY - 91
            }
            newHeightTable = height
            UIView.transition(with: tableView, duration: 0.3) { [weak self] in
                guard let sSelf = self else { return }
                sSelf.tableView.frame = CGRect(x: 0, y: newY < 91 ? 91 : newY, width: UIScreen.main.bounds.width, height: CGFloat(sSelf.reply ? height - sSelf.replyView.bounds.height : height))
            }
        } else {
            UIView.transition(with: tableView, duration: 0.3) { [weak self] in
                guard let sSelf = self else { return }
                sSelf.tableView.frame = CGRect(x: 0, y: 91, width: UIScreen.main.bounds.width, height: sSelf.reply ? sSelf.heightTable - 91 - sSelf.keyboardHeight + 20 - sSelf.replyView.bounds.height : sSelf.heightTable - 91 - sSelf.keyboardHeight + 20)
            }
            tableView.isScrollEnabled = true
        }
    }
    
    @objc func longPressButtonLongPressed(_ gestureRecognizer: UILongPressGestureRecognizer) {
            if gestureRecognizer.state == .began {
                if mic {
                    print("Кнопка была длительно нажата mic")
                } else {
                    print("video")
                }
            }
        }
    
    @objc func changeTypeLive() {
        micButton.setImage(UIImage(systemName: mic ? "camera.metering.partial" : "mic"), for: .normal)
        mic = !mic
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.keyboardHeight = keyboardHeight
            bottomView.transform = CGAffineTransform(translationX: 0, y: -(keyboardHeight - 20))
            var cellHeights: CGFloat = 30
            for i in 0..<messages.count {
                if let height = messages[i].heightCell {
                    cellHeights += height
                }
            }
            if cellHeights + keyboardHeight < (heightTable - 20) {
                var newY = heightTable - cellHeights - keyboardHeight + 20
                if reply {
                    newY -= replyView.bounds.height
                }
                let height = cellHeights
                UIView.transition(with: tableView, duration: 0.3) { [weak self] in
                    guard let sSelf = self else { return }
                    sSelf.tableView.frame = CGRect(x: 0, y: newY, width: UIScreen.main.bounds.width, height: CGFloat(height))
                }
            } else {
                tableView.frame = CGRect(x: 0, y: 91, width: Int(UIScreen.main.bounds.width), height: Int(reply ? newHeightTable - replyView.bounds.height : newHeightTable))
            }
            tableView.scrollToRow(at: IndexPath(row: dataSource.getMessagesLast(), section: 0), at: .bottom, animated: true)
        } else {
            print("dissmis")
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        bottomView.transform = .identity
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc func showPicker() {
        PHPhotoLibrary.requestAuthorization{ [weak self] status in
            let required = status == .authorized
            if required {
                DispatchQueue.main.async { [weak self] in
                    let picker = UIImagePickerController()
                    picker.delegate = self
//                    var configure = PhotosPickerConfigure()
//                    configure.mediaType = .image
//                    configure.maxSelectedAssets = 5
//                    picker.configure = configure
                    self?.present(picker, animated: true)
                }
            }
        }
    }
    
    func fetchURLString(for asset: PHAsset, completion: @escaping (String?) -> Void) {
        let options = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = { adjustmentData in
            return true
        }

        asset.requestContentEditingInput(with: options) { (contentEditingInput, info) in
            guard let input = contentEditingInput else {
                completion(nil)
                return
            }
            let urlString = input.fullSizeImageURL?.absoluteString
            completion(urlString)
        }
    }
}



// MARK: -
// MARK: - Delegate

extension SecondViewController: UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate {
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        if withPHAssets.count == 0 { return }
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        let targetSize = PHImageManagerMaximumSize
        if withPHAssets[0].mediaType == .image {
            PHImageManager.default().requestImage(for: withPHAssets[0], targetSize: targetSize, contentMode: .aspectFit, options: requestOptions) { [weak self] image, _ in
                guard let strongSelf = self else { return }
                
                if let image = image {
                    var path = ""
                    strongSelf.fetchURLString(for: withPHAssets[0], completion: { (url) in
                        if let url = url {
                            path = url
                        } else {
                            print("Не удалось получить URL")
                        }
                        var message = Message(message: "", messageSender: .ourself, username: "", image: image)
                        let modifiedPath = path.replacingOccurrences(of: ":", with: "@")
                        message.pathImage = modifiedPath
//                        strongSelf.chatRoom.send(message: modifiedPath)
                    })
                    
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = messageTextField.text else {
            return true
        }
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if updatedText.isEmpty {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.micButton.alpha = 1
            }
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.sendButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self?.sendButton.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.micButton.alpha = 0
            }
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.sendButton.transform = .identity
                self?.sendButton.alpha = 1
            }
        }
        return true
    }
}
