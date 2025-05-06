//
//  TableDataSource.swift
//  LocalChat
//
//  Created by Maks Tsarevich on 5.12.23.
//

import UIKit
import SwipeCellKit

protocol TableDataSourceDelegate: AnyObject {
    func updateMessages(_ messages: [Message])
    func resendMessageFrame(_ rect: CGRect, message: Message)
}

class TableDataSource: NSObject {
    
    // - UI
    private unowned let tableView: UITableView
    
    // - Delegate
    weak var delegate: TableDataSourceDelegate?
    
    // - Data
    private var messages: [Message] = []
    
    private var isHeaderVisible = false
    private var headerTimer: Timer?
    
    init(tableView: UITableView, messages: [Message], delegate: TableDataSourceDelegate) {
        self.tableView = tableView
        self.messages = messages
        self.delegate = delegate
        super.init()
        configure()
    }
    
    func insertNewImageCell(_ message: Message) {
        
    }
    
    func insertNewMessageCell(_ message: Message) {
        messages.append(message)
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
        delegate?.updateMessages(messages)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func getMessagesLast() -> Int {
        return messages.count - 1
    }
}


// MARK: -
// MARK: - Configure DataSource, Delegate
extension TableDataSource: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TableViewCell(style: .default, reuseIdentifier: "TableViewCell")
        cell.selectionStyle = .none
        
        let message = messages[indexPath.row]
        cell.apply(message: message)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressButtonLongPressed(_:)))
        cell.addGestureRecognizer(longPressGestureRecognizer)
        
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
//        cell.addGestureRecognizer(panGestureRecognizer)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = TableViewCell.height(for: messages[indexPath.row])
        
        if messages[indexPath.row].image == nil {
            messages[indexPath.row].heightCell = height
            return height
            
        } else {
            messages[indexPath.row].heightCell = height + CGFloat(300)
            return height + CGFloat(300)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = TableViewHeader(reuseIdentifier: "TableViewHeader")
        header.apply()
        var backgroundConfig = UIBackgroundConfiguration.listPlainHeaderFooter()
        backgroundConfig.backgroundColor = .clear
        backgroundConfig.visualEffect = nil
        header.backgroundConfiguration = backgroundConfig
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
   
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let swipeAction = UIContextualAction(style: .normal, title: "Swipe Action") { [weak self] (_, _, completionHandler) in
            // Обработка свайп-действия.
//            self?.coordinatorManager.showPaywall(self)
            print("swipe")
            completionHandler(true)
        }

        // Настройка внешнего вида свайп-действия.
        swipeAction.backgroundColor = .blue
        swipeAction.image = UIImage(named: "YourImageName")

        let configuration = UISwipeActionsConfiguration(actions: [swipeAction])
        configuration.performsFirstActionWithFullSwipe = false // Запрещаем автоматическое выполнение действия при полном свайпе.
        
        return configuration
    }
      
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//        let contentHeight = scrollView.contentSize.height
//        let screenHeight = scrollView.frame.height
//        
//        print(offsetY)
//        
//        if offsetY > 0 && offsetY + screenHeight < contentHeight || offsetY <= 0 {
       
        showHeader()
        headerTimer?.invalidate()
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
//        print(offsetY)
        if offsetY > 30 {
            hideHeaderAfterDelay()
        }
    }
}

// MARK: -
// MARK: - Configure

private extension TableDataSource {
    
    func configure() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.bounces = false
    }
    
    func getDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        let result = formatter.string(from: date)
        return result
    }
    
    private func showHeader() {
//        if !isHeaderVisible {
            UIView.animate(withDuration: 0.3) {
                // Код для отображения заголовка
                self.tableView.headerView(forSection: 0)?.isHidden = false
                self.isHeaderVisible = true
            }
//        }
    }
    
    private func hideHeader() {
//        if isHeaderVisible {
            UIView.animate(withDuration: 0.3) {
                self.tableView.headerView(forSection: 0)?.isHidden = true
                self.isHeaderVisible = false
            }
//        }
    }
    
    private func hideHeaderAfterDelay() {
        headerTimer?.invalidate()
        headerTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] timer in
            self?.hideHeader()
        }
    }
    
    private func handleMarkAsFavourite() {
        print("Marked as favourite")
    }
    
    @objc func longPressButtonLongPressed(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: tableView)
            
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                if let cell = tableView.cellForRow(at: indexPath) as? TableViewCell {
                    
                    // Далее вы можете использовать созданную ячейку
                    delegate?.resendMessageFrame(cell.getFrameMessage(), message: messages[indexPath.row])
                }
            }
        }
    }
}
