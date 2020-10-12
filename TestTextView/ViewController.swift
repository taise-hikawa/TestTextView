//
//  ViewController.swift
//  TestTextView
//
//  Created by Sakurako Shimbori on 2020/10/11.
//

import UIKit

class ViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate {
    var buttonFlag:Dictionary<String,Bool> = ["textField":false,"textView":false]{
        didSet{
            if button != nil{
                if buttonFlag.values.contains(true){
                    print("button on")
                    button.isEnabled = true
                }else{
                    print("button off")
                    button.isEnabled = false
                }
            }
        }
    }
    @IBOutlet weak var textField: UITextField!{
        didSet{
            textField.delegate = self
        }
    }
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textView: UITextView!{
        didSet{
            textView.delegate = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        button.isEnabled = false
        button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        self.configureObserver()

    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        self.removeObserver() // Notificationを画面が消えるときに削除
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @objc func buttonTapped(_ sender : Any) {
        if buttonFlag["textView"] == true{
            print(textView.text ?? "nil")
        }
        if buttonFlag["textField"] == true{
            print(textField.text ?? "nil")
        }
        
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if text?.isEmpty == true{
            buttonFlag["textField"] = false
        }else{
            buttonFlag["textField"] = true
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if text?.isEmpty == true{
            buttonFlag["textView"] = false
        }else{
            buttonFlag["textView"] = true
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (textView.isFirstResponder) {
            textView.resignFirstResponder()
        }
        if(textField.isFirstResponder){
            textField.resignFirstResponder()
        }
    }
    private var activeTextField: UITextField? = nil
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")
        activeTextField = textField
        return true
    }
    private var activeTextView: UITextView? = nil
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("textViewShouldBeginEditing")
        activeTextView = textView
        return true
    }
    
    
    // Notificationを設定
    func configureObserver() {
        
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Notificationを削除
    func removeObserver() {
        
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }
    // キーボードが現れた時に、画面全体をずらす。
    @objc func keyboardWillShow(notification: Notification?) {
        print("show")
        guard let userInfo = notification?.userInfo,
              let keyboard = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardScreenEndFrame = keyboard.cgRectValue
        let myBoundSize: CGSize = UIScreen.main.bounds.size
        //FirstResponderによって分岐
        var textframeParent:CGRect!
        if (textView.isFirstResponder) {
            // textViewの座標を全体座標に変換
            textframeParent = activeTextView!.convert(activeTextView!.frame, to: self.view)
        }
        if(textField.isFirstResponder){
            // textFieldの座標を全体座標に変換
            textframeParent = activeTextField!.convert(activeTextField!.frame, to: self.view)
        }
        
        let txtLimit = textframeParent.origin.y + textframeParent.height + 8.0
        let kbdLimit = myBoundSize.height - keyboardScreenEndFrame.size.height




        let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        if txtLimit >= kbdLimit {
            UIView.animate(withDuration: duration!, animations: { () in
                let transform = CGAffineTransform(translationX: 0, y: -(keyboardScreenEndFrame.size.height))
                self.view.transform = transform

            })
        }
    }
    
    // キーボードが消えたときに、画面を戻す
    @objc func keyboardWillHide(notification: Notification?) {
        print("hide")
        let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            
            self.view.transform = CGAffineTransform.identity
        })
    }

}


