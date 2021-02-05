//
//  GroupsViewController.swift
//  SampleChat
//
//  Created by Admin on 29/01/21.
//

import UIKit
import CometChatPro

class GroupsViewController: UIViewController {
    
    
    @IBOutlet weak var tblGroups: UITableView!
    var groups = [Group]()
    let groupsRequest  = GroupsRequest.GroupsRequestBuilder(limit: 20).build();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        groupsRequest.fetchNext(onSuccess: { (groups) in
            
            self.groups = groups
            DispatchQueue.main.async {
                self.tblGroups.dataSource = self
                self.tblGroups.delegate = self
                self.tblGroups.reloadData()
            }
            
        }) { (error) in
            
            print("Groups list fetching failed with error:" + error!.errorDescription);
        }
    }
    
    @IBAction func btnLogoutAction(_ sender: Any) {
        CometChat.logout(onSuccess: { (response) in
            DispatchQueue.main.async {
                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
                self.tabBarController?.tabBar.isHidden = true
                self.navigationController?.viewControllers = [controller]
            }
            
            print("Logout successfully.")
            
        }) { (error) in
            
            print("logout failed with error: " + error.errorDescription);
        }
    }
    @IBAction func CreateGroup(_ sender: Any) {
        let alert = UIAlertController(title: "Create Group", message: "Select which way you want to create group", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Private Group", style: .default, handler: { (_) in
            
        }))
        
        alert.addAction(UIAlertAction(title: "Password Protected Group", style: .default, handler: { (_) in
            
        }))
        alert.addAction(UIAlertAction(title: "Public Group", style: .default, handler: { (_) in
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
}

extension GroupsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        print(groups[indexPath.row])
        if groups[indexPath.row].updatedAt > 0 {
            let updatedAt = Date(timeIntervalSince1970: TimeInterval(groups[indexPath.row].updatedAt))
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "dd/MM/yyyy HH:mm a"
            let wholeString = "\(String(describing: self.groups[indexPath.row].name!))\n \(dateFormat.string(from: updatedAt))"
            cell.textLabel?.attributedText = NSAttributedString().fontChange(name: String(describing: self.groups[indexPath.row].name!), wholeString: wholeString)
            cell.textLabel?.numberOfLines = 0
        } else {
            let wholeString = "\(String(describing: self.groups[indexPath.row].name!))\n Total Members: \(self.groups[indexPath.row].membersCount)"
            cell.textLabel?.attributedText = NSAttributedString().fontChange(name: String(describing: self.groups[indexPath.row].name!), wholeString: wholeString)
            cell.textLabel?.numberOfLines = 0
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessagingViewController") as! MessagingViewController
        controller.group = self.groups[indexPath.row]
        controller.messagesRequest = MessagesRequest.MessageRequestBuilder().set(guid: groups[indexPath.row].guid ).set(limit: 20).build()
        self.navigationController?.pushViewController(controller, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
