//
//  CreateGroupViewController.swift
//  SampleChat
//
//  Created by Admin on 03/02/21.
//

import UIKit
import CometChatPro

protocol CreateDelegate: AnyObject {
    func reloadGroup(group: Group)
}

class CreateGroupViewController: UIViewController {
    @IBOutlet weak var txtGroupName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnCreate: UIButton!
    @IBOutlet weak var conTxtPasswordTop: NSLayoutConstraint!
    @IBOutlet weak var conTxtPasswordHt: NSLayoutConstraint!
    
    var groupType: CometChat.groupType?
    var group = Group(guid: "", name: "", groupType: .password, password: "");
    
    var groupsRequest  = GroupsRequest.GroupsRequestBuilder(limit: 20).build();
    
    weak var delegate: CreateDelegate?
    
    var leavePage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if groupType == nil {
            if leavePage {
                btnCreate.setTitle("Leave", for: .normal)
                conTxtPasswordTop.constant = 0
                conTxtPasswordHt.constant = 0
            } else {
                btnCreate.setTitle("Join", for: .normal)
            }
       }
    }
    
    @IBAction func btnCreateGroupAction(_ sender: Any) {
        if groupType != nil && txtGroupName.text != "" && txtPassword.text != "" {
            group = Group(guid: "group_\(Int(Date().timeIntervalSince1970))", name: txtGroupName.text!, groupType: groupType!, password: txtPassword.text!);
            CometChat.createGroup(group: group, onSuccess: { (group) in
                self.sucessfullyCreatedAction(group: group)
                print("Group created successfully. " + group.stringValue())
                
            }) { (error) in
                
                print("Group creation failed with error:" + error!.errorDescription);
            }
        } else if groupType == nil && txtGroupName.text != "" && txtPassword.text != "" {
            groupsRequest  = GroupsRequest.GroupsRequestBuilder(limit: 20).build();
            groupsRequest.fetchNext(onSuccess: { (groups) in
                
                for group in groups {
                    DispatchQueue.main.async {
                        if !group.hasJoined && group.name! == self.txtGroupName.text! {
                            CometChat.joinGroup(GUID: group.guid, groupType: group.groupType, password: self.txtGroupName.text!, onSuccess: { (group) in
                                self.sucessfullyCreatedAction(group: group)
                                print("Group joined successfully. " + group.stringValue())
                                
                            }) { (error) in
                                
                                print("Group joining failed with error:" + error!.errorDescription);
                            }
                        }
                    }
                    
                }
                
            }) { (error) in
                
                print("Groups list fetching failed with error:" + error!.errorDescription);
            }
        } else if groupType == nil && txtGroupName.text != "" && leavePage {
            groupsRequest  = GroupsRequest.GroupsRequestBuilder(limit: 20).build();
            groupsRequest.fetchNext(onSuccess: { (groups) in
                
                for group in groups {
                    DispatchQueue.main.async {
                        if group.hasJoined && group.name! == self.txtGroupName.text! {
                            CometChat.leaveGroup(GUID: group.guid, onSuccess: { (response) in
                                self.sucessfullyCreatedAction(group: group)
                                print("Left group successfully.")

                            }) { (error) in

                              print("Group leaving failed with error:" + error!.errorDescription);
                            }
                        }
                    }
                    
                }
                
            }) { (error) in
                
                print("Groups list fetching failed with error:" + error!.errorDescription);
            }
        }
    }
    
    @objc func sucessfullyCreatedAction (group: Group) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
            self.delegate?.reloadGroup(group: group)
        }
    }
}
