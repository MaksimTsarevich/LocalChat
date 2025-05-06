//
//  ResendViewController.swift
//  LocalChat
//
//  Created by Maks Tsarevich on 22.12.23.
//

import UIKit

protocol ResendViewControllerDelegate: AnyObject {
    func replyMessage(_ message: Message)
    func copyMessage(_ message: Message)
    func editMessage(_ message: Message)
    func pinMessage(_ message: Message)
    func forwardMessage(_ message: Message)
    func deleteMessage(_ message: Message)
    func selectMessage(_ message: Message)
}

class ResendViewController: UIViewController {
    
    // - UI
    let messageView = UIView()
    let replyView = UIView()
    let copyView = UIView()
    let editView = UIView()
    let pinView = UIView()
    let forwardView = UIView()
    let deleteView = UIView()
    let selectView = UIView()
    
    // - Data
    var message: Message?
    
    // - Delegate
    weak var delegate: ResendViewControllerDelegate?
    
    // - Blur
    lazy var blurredView: UIView = {
        let containerView = UIView()
        let blurEffect = UIBlurEffect(style: .dark)
        let customBlurEffectView = CustomBlurView(effect: blurEffect, intensity: 0.7)
        customBlurEffectView.frame = view.bounds
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.fillRule = .evenOdd
        let transparentRect = messageView.frame
        let path = UIBezierPath(roundedRect: maskLayer.bounds, cornerRadius: 9 )
        path.append(UIBezierPath(roundedRect: transparentRect, cornerRadius: 9))
        maskLayer.path = path.cgPath
        
        let tempView = UIView()
        tempView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        tempView.frame = view.bounds
        
        let windowRect = messageView.frame
        let maskRect = UIBezierPath(rect: tempView.bounds)
        let windowPath = UIBezierPath(rect: windowRect)
        maskRect.append(windowPath.reversing())

        let mask2Layer = CAShapeLayer()
        mask2Layer.path = maskRect.cgPath

        tempView.layer.mask = mask2Layer
    
        customBlurEffectView.layer.mask = maskLayer
        
//        containerView.addSubview(tempView)
        containerView.addSubview(customBlurEffectView)
        
        return containerView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(blurredView)
        view.sendSubviewToBack(blurredView)
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}


// MARK: -
// MARK: - Configure

private extension ResendViewController {
    
    func configure() {
        configureGesture()
        configureView()
    }
    
    func configureGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissScreen))
        view.addGestureRecognizer(tapGesture)
        
        let reply = UITapGestureRecognizer(target: self, action: #selector(replyMessage))
        replyView.addGestureRecognizer(reply)
        
        let copy = UITapGestureRecognizer(target: self, action: #selector(copyMessage))
        copyView.addGestureRecognizer(copy)
        
        let edit = UITapGestureRecognizer(target: self, action: #selector(editMessage))
        editView.addGestureRecognizer(edit)
        
        let pin = UITapGestureRecognizer(target: self, action: #selector(pinMessage))
        pinView.addGestureRecognizer(pin)
        
        let forward = UITapGestureRecognizer(target: self, action: #selector(forwardMessage))
        forwardView.addGestureRecognizer(forward)
        
        let delete = UITapGestureRecognizer(target: self, action: #selector(deleteMessage))
        deleteView.addGestureRecognizer(delete)
        
        let select = UITapGestureRecognizer(target: self, action: #selector(selectMessage))
        selectView.addGestureRecognizer(select)
    }
    
    func configureView() {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.737, green: 0.737, blue: 0.737, alpha: 1)
        view.layer.cornerRadius = 10
        view.frame = CGRect(x: messageView.frame.minX, y: messageView.frame.maxY + 5, width: 200, height: 280)
        view.clipsToBounds = true
        if message?.messageSender == .ourself {
            view.center = CGPoint(x: messageView.frame.maxX - ((view.frame.width / 2)), y: messageView.frame.maxY + ((view.frame.height / 2) + 10))
        }
        self.view.addSubview(view)
        
        // - Stack View
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0.5
        stackView.backgroundColor = UIColor(red: 0.737, green: 0.737, blue: 0.737, alpha: 1)
        stackView.frame = view.bounds
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        
        
        replyView.backgroundColor = UIColor(red: 0.837, green: 0.837, blue: 0.837, alpha: 1)
        stackView.addArrangedSubview(replyView)
        
        
        copyView.backgroundColor = UIColor(red: 0.837, green: 0.837, blue: 0.837, alpha: 1)
        stackView.addArrangedSubview(copyView)
        
        
        editView.backgroundColor = UIColor(red: 0.837, green: 0.837, blue: 0.837, alpha: 1)
        stackView.addArrangedSubview(editView)
        
        
        pinView.backgroundColor = UIColor(red: 0.837, green: 0.837, blue: 0.837, alpha: 1)
        stackView.addArrangedSubview(pinView)
        
        
        forwardView.backgroundColor = UIColor(red: 0.837, green: 0.837, blue: 0.837, alpha: 1)
        stackView.addArrangedSubview(forwardView)
        
        
        deleteView.backgroundColor = UIColor(red: 0.837, green: 0.837, blue: 0.837, alpha: 1)
        stackView.addArrangedSubview(deleteView)
        
        
        selectView.backgroundColor = UIColor(red: 0.837, green: 0.837, blue: 0.837, alpha: 1)
        stackView.addArrangedSubview(selectView)
        
        let spacingView = UIView()
        spacingView.backgroundColor = UIColor(red: 0.737, green: 0.737, blue: 0.737, alpha: 1)
        spacingView.frame = CGRect(x: 0, y: 0, width: 200, height: 5)
        selectView.addSubview(spacingView)
        
        // Label
        let replyLabel = setLabel(text: "Reply", y: 8)
        replyView.addSubview(replyLabel)
        
        let copyLabel = setLabel(text: "Copy", y: 8)
        copyView.addSubview(copyLabel)
        
        let editLabel = setLabel(text: "Edit", y: 8)
        editView.addSubview(editLabel)
        
        let pinLabel = setLabel(text: "Pin", y: 8)
        pinView.addSubview(pinLabel)
        
        let forwardLabel = setLabel(text: "Forward", y: 8)
        forwardView.addSubview(forwardLabel)
        
        let deleteLabel = setLabel(text: "Delete", y: 8)
        deleteLabel.textColor = .red
        deleteView.addSubview(deleteLabel)
        
        let selectLabel = setLabel(text: "Select", y: 12)
        selectView.addSubview(selectLabel)
        
        // - Image
        let replyImage = setNewImage(imageName: "arrowshape.turn.up.left", y: 8)
        replyView.addSubview(replyImage)
        
        let copyImage = setNewImage(imageName: "doc.on.doc", y: 8)
        copyView.addSubview(copyImage)
        
        let editImage = setNewImage(imageName: "pencil", y: 8)
        editView.addSubview(editImage)
        
        let pinImage = setNewImage(imageName: "pin", y: 8)
        pinView.addSubview(pinImage)
        
        let forwardImage = setNewImage(imageName: "arrowshape.turn.up.forward", y: 8)
        forwardView.addSubview(forwardImage)
        
        let deleteImage = setNewImage(imageName: "trash", y: 8)
        deleteImage.tintColor = .red
        deleteView.addSubview(deleteImage)
        
        let selectImage = setNewImage(imageName: "checkmark.circle", y: 12)
        selectView.addSubview(selectImage)
    }
    
    func setLabel(text: String, y: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.frame = CGRect(x: 15, y: y, width: 100, height: 20)
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }
    
    func setNewImage(imageName: String, y: CGFloat) -> UIImageView {
        let image = UIImageView()
        image.image = UIImage(systemName: imageName)
        image.tintColor = .black
        image.frame = CGRect(x: 200 - 35, y: y, width: 18, height: 17)
        return image
    }
    
}

// MARK: -
// MARK: - Objc Method's

private extension ResendViewController {
    
    @objc func dismissScreen() {
        dismiss(animated: true)
    }
    
    @objc func replyMessage() {
        dismiss(animated: true)
        guard let message = message else { return }
        delegate?.replyMessage(message)
    }
    
    @objc func copyMessage() {
        dismiss(animated: true)
        guard let message = message else { return }
        delegate?.copyMessage(message)
    }
    
    @objc func editMessage() {
        dismiss(animated: true)
        guard let message = message else { return }
        delegate?.editMessage(message)
    }
    
    @objc func pinMessage() {
        dismiss(animated: true)
        guard let message = message else { return }
        delegate?.pinMessage(message)
    }
    
    @objc func forwardMessage() {
        dismiss(animated: true)
        guard let message = message else { return }
        delegate?.forwardMessage(message)
    }
    
    @objc func deleteMessage() {
        dismiss(animated: true)
        guard let message = message else { return }
        delegate?.deleteMessage(message)
    }
    
    @objc func selectMessage() {
        dismiss(animated: true)
        guard let message = message else { return }
        delegate?.selectMessage(message)
    }
}
