//
//  addListVC.swift
//  list
//
//  Created by donezio on 11/15/17.
//  Copyright © 2017 macbook pro. All rights reserved.
//

import UIKit

protocol addListDelegate
{
    func updateData(_ newList : listObject)
}



class addListVC: UIViewController,UITextViewDelegate,UITextFieldDelegate {

    //delegate
    var delegate:addListDelegate!
    
    
    //field
    @IBOutlet weak var timeText: UITextField!
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet weak var shortDescription: UITextField!
    @IBOutlet weak var longDescription: UITextView!
    
    let datePicker = UIDatePicker()
    
    var newList = listObject()
    
    @IBAction func dissMissVC(_ sender: Any) {
        //self.dismiss(animated: true, completion: {})
        if(newList.amount != nil && newList.shortDetail != nil && newList.time != nil){
            //safe to go back to parent
            // i will use delegate to pass data back to the parent
            delegate?.updateData(newList)
            self.dismiss(animated: true, completion: {})
        }
        if(newList.amount == nil){
            presentAlert("amount")
        }
        else if( newList.time == nil){
            presentAlert("time")
        }
        else if(newList.shortDetail == nil){
            presentAlert("short detail")
        }
    }
    

    @IBAction func cancelAdd(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
        print("nothing is add")
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creatDatePicker()
        let newView = self.view.superview
        self.longDescription.delegate = self
        self.amountText.delegate = self
        self.shortDescription.delegate = self
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            longDescription.resignFirstResponder()
            return false
        }
        return true
    }

    
    @IBAction func amountDone(_ sender: Any) {
        if amountText.text != nil{
            newList.amount = amountText.text
        }
    }
    
    @IBAction func shortDes(_ sender: Any) {
        if shortDescription.text != nil{
            newList.shortDetail = shortDescription.text
        }
    }
    
    
    @IBAction func longDes(_ sender: Any) {
        if longDescription.text != nil{
            newList.longDetail  = longDescription.text
        }
    }
    
    
    
    
    
    
    /// get time and date
    func creatDatePicker(){
        //format
        datePicker.datePickerMode = .dateAndTime
        //toolbar
        let toobar = UIToolbar()
        toobar.sizeToFit()
        //bar button item
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toobar.setItems([doneButton],animated: true)
        timeText.inputAccessoryView = toobar
        //assigning date picker text field
        timeText.inputView = datePicker
    }
    
    @objc func donePressed(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        timeText.text = dateFormatter.string(from: datePicker.date)
        newList.time = timeText.text
        self.view.endEditing(true)
    }
    // get time and date finish
    
    
    
    //present alert
    func presentAlert(_ field : String){
        let alert = UIAlertController(title: "Alert", message: "Message :" + field + " not set" , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // finish present alert
    
}

extension UIViewController  {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


