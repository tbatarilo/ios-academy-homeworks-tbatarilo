//
//  CommentsViewController.swift
//  TVShow
//
//  Created by Infinum Student Academy on 01/08/2018.
//  Copyright © 2018 Tomislav Batarilo. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import CodableAlamofire

class CommentsViewController: UIViewController {
    
    var token: String?
    var episodeId: String?
    
    private var comments: [Comment] = []
    
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    var originalBottomConstraintConstant: CGFloat?
    
    @IBOutlet weak var postCommentView: UIView!
    
    @IBOutlet weak var addCommentField: UITextField!
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        addObservers()
        postCommentView.layer.borderColor = UIColor.lightGray.cgColor
        
        getComments()
        setColor()
        setTitle()
        setBackButton()
        
    }
    
    @objc func didSelectBackButton() {
        self.dismiss(animated: false)
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasHidden), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
    }
    
    private func setTitle() {
        navigationItem.title = "Comments"
    }
    
    private func setColor() {
        UINavigationBar.appearance().barTintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    private func setBackButton() {
        var image = UIImage(named: "ic-navigate-back")
        image = image?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style:.plain, target: self, action: #selector(didSelectBackButton))
    }
    
    private func getComments(){
        let headers = ["Authorization": token!]
        
        SVProgressHUD.show()
        
        Alamofire
            .request("https://api.infinum.academy/api" + "/episodes/" + episodeId! + "/comments",
                     method: .get,
                     encoding: JSONEncoding.default,
                     headers: headers)
            .validate()
            .responseDecodableObject(keyPath: "data", decoder: JSONDecoder()) {[weak self] (response:
                DataResponse<[Comment]>) in
                
                SVProgressHUD.dismiss()
                
                switch response.result {
                case .success(let comments):
                    self?.comments = comments
                    self?.tableView.reloadData()
                    
                    if comments.count > 0 {
                        self?.setTableViewBackgroundClear()
                    } else {
                        self?.setTableViewBackground()
                    }
                case .failure:
                    print("Error comments.")
                }
        }
        
    }
    
    private func setTableViewBackground(){
        let rectView = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        
        let rectImage = CGRect(origin: CGPoint(x:tableView.bounds.size.width/4 ,y :tableView.bounds.size.height/6), size: CGSize(width: tableView.bounds.size.width/2, height: tableView.bounds.size.height/3))
        
        let rectLabel = CGRect(origin: CGPoint(x: 10,y :tableView.bounds.size.height/2), size: CGSize(width: tableView.bounds.size.width - 20, height: tableView.bounds.size.height/2))
        
        let view = UIView(frame: rectView)
        
        let imageView = UIImageView(frame: rectImage)
        imageView.image = #imageLiteral(resourceName: "img-placehoder-comments")
        
        let messageLabel = UILabel(frame: rectLabel)
        messageLabel.text = "Sorry, we don't have comments yet. Be first who will write a review."
        messageLabel.numberOfLines = 0
        
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 18)
        messageLabel.sizeToFit()
        
        view.addSubview(imageView)
        view.addSubview(messageLabel)
        
        tableView.backgroundView = view;
        tableView.separatorStyle = .none;
    }
    
    private func setTableViewBackgroundClear() {
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.white
    }
    
    @IBAction func postComment(_ sender: Any) {
        if addCommentField.text!.isEmpty {
            shake(textField: addCommentField)
        }else{
            uploadComment(text: addCommentField.text!)
            if comments.count > 0 {
                setTableViewBackgroundClear()
            }
        }
    }
    
    private func uploadComment(text: String){
        let headers = ["Authorization": token!]
        
        let parameters: [String: String] = [
            "text": addCommentField.text!,
            "episodeId": episodeId!
        ]
        
        SVProgressHUD.show()
        
        Alamofire
            .request("https://api.infinum.academy/api" + "/comments",
                     method: .post,
                     parameters: parameters,
                     encoding: JSONEncoding.default,
                     headers: headers)
            .validate()
            .responseJSON() {[weak self] response in
                
                SVProgressHUD.dismiss()
                
                switch response.result {
                case .success:
                    self?.addCommentField.text = ""
                    self?.getComments()
                case .failure:
                    print("Fail while uploading.")
                }
        }
    }
    
    private func shake(textField: UITextField){
        
        let animation = CABasicAnimation(keyPath: "position")
        
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: textField.center.x - 4.0, y: textField.center.y)
        animation.toValue = CGPoint(x: textField.center.x + 4.0, y: textField.center.y)
        
        textField.layer.add(animation, forKey: "position")
    }
    
    
    @objc private func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.originalBottomConstraintConstant = self.viewBottomConstraint.constant
            self.viewBottomConstraint.constant = keyboardFrame.size.height
        })
    }
    
    @objc private func keyboardWasHidden(notification: NSNotification) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.viewBottomConstraint.constant = (self.originalBottomConstraintConstant)!
        })
    }
}

extension CommentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CommentsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CommentsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "CommentsTableViewCell",
            for: indexPath
            ) as! CommentsTableViewCell
        
        let comment = comments[indexPath.row]
        let image = chooseImage(commentsNumber: indexPath.row)
        cell.configureWith(comment: comment,image: image)
        
        return cell
    }
    
    private func chooseImage(commentsNumber: Int) -> UIImage{
        switch commentsNumber % 3 {
        case 0: return #imageLiteral(resourceName: "img-placeholder-user1")
        case 1: return #imageLiteral(resourceName: "img-placeholder-user2")
        case 2: return #imageLiteral(resourceName: "img-placeholder-user3")
        default: return #imageLiteral(resourceName: "img-placeholder-user1")
        }
    }}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
