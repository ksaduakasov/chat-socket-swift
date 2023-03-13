import UIKit

class ChatRoomViewController: UIViewController {
  let tableView = UITableView()
  let messageInputBar = MessageInputView()
  let chatRoom = ChatRoom()
  
  var messages: [Message] = []
  
  var username = ""
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    chatRoom.delegate = self
    chatRoom.setupNetworkCommunication()
    chatRoom.joinChat(username: username)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    chatRoom.stopChatSession()
  }
}

extension ChatRoomViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = MessageTableViewCell(style: .default, reuseIdentifier: "MessageCell")
    cell.selectionStyle = .none
    
    let message = messages[indexPath.row]
    cell.apply(message: message)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let height = MessageTableViewCell.height(for: messages[indexPath.row])
    return height
  }
  
  func insertNewMessageCell(_ message: Message) {
    messages.append(message)
    let indexPath = IndexPath(row: messages.count - 1, section: 0)
    tableView.beginUpdates()
    tableView.insertRows(at: [indexPath], with: .bottom)
    tableView.endUpdates()
    tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
  }
}

extension ChatRoomViewController: MessageInputDelegate {
  func sendWasTapped(message: String) {
    chatRoom.send(message: message)
  }
}

extension ChatRoomViewController: ChatRoomDelegate {
  func received(message: Message) {
    insertNewMessageCell(message)
  }
}

//MARK: - Layout
extension ChatRoomViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
    loadViews()
  }
  
  @objc func keyboardWillChange(notification: NSNotification) {
    if let userInfo = notification.userInfo {
      let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!.cgRectValue
      let messageBarHeight = messageInputBar.bounds.size.height
      let point = CGPoint(x: messageInputBar.center.x, y: endFrame.origin.y - messageBarHeight/2.0)
      let inset = UIEdgeInsets(top: 0, left: 0, bottom: endFrame.size.height, right: 0)
      UIView.animate(withDuration: 0.25) {
        self.messageInputBar.center = point
        self.tableView.contentInset = inset
      }
    }
  }
  
  func loadViews() {
    navigationItem.title = "Let's Chat!"
    navigationItem.backBarButtonItem?.title = "Run!"
    
    view.backgroundColor = UIColor(red: 24 / 255, green: 180 / 255, blue: 128 / 255, alpha: 1.0)
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorStyle = .none
    
    view.addSubview(tableView)
    view.addSubview(messageInputBar)
    
    messageInputBar.delegate = self
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let messageBarHeight:CGFloat = 60.0
    let size = view.bounds.size
    tableView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height - messageBarHeight - view.safeAreaInsets.bottom)
    messageInputBar.frame = CGRect(x: 0, y: size.height - messageBarHeight - view.safeAreaInsets.bottom, width: size.width, height: messageBarHeight)
  }
}
