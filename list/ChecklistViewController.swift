//
//  ChecklistViewController.swift
//  list
//
//  Created by donezio on 11/13/17.
//  Copyright © 2017 macbook pro. All rights reserved.
//

import UIKit
import FoldingCell

class ChecklistViewController:  UITableViewController, addListDelegate{

    @IBOutlet weak var amountText: UILabel!
    
    let kCloseCellHeight: CGFloat = 75
    let kOpenCellHeight: CGFloat = 150
    let kRowsCount = 4
    var cellHeights: [CGFloat] = []
    var arr  = [listObject]()
    var userCount = "1"
    
    
    var numberOfPeople = 1
    
    //get avg button
    @IBAction func getAvg(_ sender: Any) {
        numberOfUsers()
        
    }
    // add item button
    @IBAction func addItem(_ sender: Any) {
        tableView.reloadData()
        addNewListItem()
    }
    
    func addNewListItem(){
        
        //arr.append("4")
        
        performSegue(withIdentifier: "addList", sender: nil)
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? addListVC {
            destination.delegate = self
        }
    }
    
    // data is updated by the child VC
    func updateData(_ newList : listObject){
        print(newList.shortDetail)
        
        arr.append(newList)
        //update table UI
        self.saveLists()
        updateTable()
    }
    
    
    func updateTable(){
        updateHeader()
        self.setup()
        let indexPath = NSIndexPath(item : arr.count - 1,  section : 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath as IndexPath] , with: .automatic)
        tableView.endUpdates()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // wait for data to be populated using dispatchGrounp
        loadChecklistItems()
        updateHeader()
        self.setup()
        //empty cell empty seperater
        tableView.tableFooterView = UIView(frame: .zero)
        //seperater fully extend
        tableView.separatorInset = .zero
        tableView.layoutMargins = .zero
    }
    
    private func setup() {
        cellHeights = Array(repeating: kCloseCellHeight, count: arr.count)
        tableView.estimatedRowHeight = kCloseCellHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
    }
}

extension ChecklistViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as newCell = cell else {
            return
        }
        
        cell.backgroundColor = .clear
        
        if cellHeights[indexPath.row] == kCloseCellHeight {
            cell.selectedAnimation(false, animated: false, completion:nil)
        } else {
            cell.selectedAnimation(true, animated: false, completion: nil)
        }
        if let tmp = arr[indexPath.row].time  as? String{
            cell.time.text = tmp
        }
        if let tmp = arr[indexPath.row].shortDetail  as? String{
            cell.shortDes.text = tmp
        }
        
        if let tmp = arr[indexPath.row].amount  as? String{
            cell.amount.text = tmp
        }
 
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkListItem", for: indexPath) as! FoldingCell
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == kCloseCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = kOpenCellHeight
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 0.8
        }
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
        
    }
    
    //swipe to delete
    override func tableView(_ tableView: UITableView,
                              commit editingStyle: UITableViewCellEditingStyle,
                              forRowAt indexPath: IndexPath) {
        deleteAlert(indexPath)
            
    }
    
    // functions below are for saving data
    func docRoot() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory,
                                             in : .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL{
        return docRoot().appendingPathComponent("lists.plist")
    }
    
    func saveLists(){
        print("start saving")
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos:.userInitiated).async {
            let encoder = PropertyListEncoder()
            do{
                let data = try encoder.encode(self.arr)
                try data.write(to: self.dataFilePath(),
                           options: Data.WritingOptions.atomic)
            }catch{
                print("oh error oh error")
            }
            group.leave()
        }
        group.wait()
        print("i finish saving data now")
    }
    
    // functions below are for loading data
    func loadChecklistItems() {
        print("start loading")
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos:.userInitiated).async {
            let path = self.dataFilePath()
            // 2
            if let data = try? Data(contentsOf: path) {
                // 3
                let decoder = PropertyListDecoder()
                do {// 4
                    self.arr = try decoder.decode([listObject].self,
                                             from: data)
                }catch {
                    print("Error decoding item array!")
                }
            }
            group.leave()
        }
        group.wait();
        print("i finish loading data")
    }
    
    
    
    // this function is for updating the header
    func updateHeader(){
        var tmp : Float = 0.0
        for object in arr {
            let url = object.amount
            var num = Float(url!)
            if num != nil{
                tmp = num! + tmp
            }
            print("not a number")
        }
        amountText.text = String(tmp)
    }
    
    // aletr for delete
    func deleteAlert(_ indexPath : IndexPath){
        var res = false
        let alert = UIAlertController(title: "delete", message: "Are you sure you want to delete it?", preferredStyle: .alert)
        let clearAction = UIAlertAction(title: "delete", style: .destructive) { (alert: UIAlertAction!) -> Void in
            // 1
            self.arr.remove(at: indexPath.row)
            // 2
            let indexPaths = [indexPath]
            self.tableView.deleteRows(at: indexPaths, with: .automatic)
            self.saveLists()
            self.updateHeader()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction!) -> Void in
            res = false
            print("cancel delete")
        }
        
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion:nil)

    }
    
    // alert for getting number of users
    func numberOfUsers(){
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Number of Users? ", message: "Enter number of users",preferredStyle: .alert)
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            //getting the input values from user
            self.userCount = (alertController.textFields?[0].text)!
            self.getAvg()
        }
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            print("cancel user input alert")
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter number of users"
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getAvg(){
        var avg = (amountText.text as! NSString).floatValue / (userCount as! NSString).floatValue
        let alert = UIAlertController(title: "Avg", message: "Avg :" + String(avg) , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

