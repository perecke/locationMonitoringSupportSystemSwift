//
//  ViewControllerComment.swift
//  locationMonitoringSupportSystemSwift
//
//  Created by Kubota Naoyuki on 2017/05/04.
//  Copyright © 2017年 Kubota Naoyuki. All rights reserved.
//

import UIKit
import CoreData
import ContactsUI

class ViewControllerComment: UIViewController,UITableViewDelegate,UITableViewDataSource,CNContactPickerDelegate {

    @IBOutlet var tableViewComment: UITableView!
    
    //Variables to store in the core data for the markers
    var titleName : String = "";
    var latitudeValue : Double = 0.0;
    var longtitudeValue : Double = 0.0;
    //The variable we want to store
    var commentList : String! = "";
    
    let shoppingComments : [String] = ["米","パン","肉","トマト","りんご","砂糖","塩","小麦粉","卵","牛乳"];
    let medicineComments : [String] = ["薬","薬","薬","薬","薬","薬"];
    let peopleComments : [String] = ["お母さん","お父さん","お婆さん","お爺さん","お姉さん","お兄さん","日本太郎"];
    let reservationComments : [String] = ["レストラン","病院","映画館"]; //TODO actually decide how should this work
    
    //var choosenCategory: [String] = [];
    var choosenCategory: [NSManagedObject] = [];
    
    let cellReuseIndentifierComment = "cell";
    var isLaunched = 0;
    var enetytiNameChoosen = "";
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Check if we have launched the app first
        if(UserDefaults.standard.bool(forKey: "HasLaunchedOnce"))
        {
            isLaunched = 1;
        }
        else
        {
            // This is the first launch ever
            UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
            UserDefaults.standard.synchronize()
        }
        
        //TODO switch to switch case
        
        switch titleName {
        case "買い物":
            enetytiNameChoosen = "Shopping";
            if isLaunched == 0 {
                for item in shoppingComments {
                    self.save(name: item, entituName: enetytiNameChoosen);
                }
            }
        case "薬":
            enetytiNameChoosen = "Medicine";
            if isLaunched == 0 {
                for item in medicineComments {
                    self.save(name: item, entituName: enetytiNameChoosen);
                }
            }
        case "打ち合わせ":
            enetytiNameChoosen = "Meeting";
            //choosenCategory = peopleComments;
            
            if isLaunched == 0 {
                for item in peopleComments {
                    self.save(name: item, entituName: enetytiNameChoosen);
                }
            }
        case "要約":
            //TODO figure out what to do here
            return;
        default:
            return;
        }
        
        self.fetchData(entytName: enetytiNameChoosen);
        
        self.tableViewComment.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIndentifierComment);
        tableViewComment.delegate = self;
        tableViewComment.dataSource = self;
        
    }
    
    //Set up the tableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choosenCategory.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = self.tableViewComment.dequeueReusableCell(withIdentifier: cellReuseIndentifierComment) as UITableViewCell!;
        
        let item = choosenCategory[indexPath.row];
        cell.textLabel?.text = item.value(forKey: "item") as! String?;
        //cell.textLabel?.text = choosenCategory[indexPath.row];
        let costumPlusButton = UIButton(type: .custom);
        costumPlusButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        costumPlusButton.addTarget(self, action: #selector(self.accessoryButtonAddTapped(sender:)), for: .touchUpInside);
        costumPlusButton.backgroundColor = UIColor.white;
        costumPlusButton.setTitle("+", for: UIControlState.normal);
        costumPlusButton.setTitleColor(UIColor.blue, for: UIControlState.normal);
        costumPlusButton.tag = indexPath.row;
        cell.accessoryView = costumPlusButton as UIView;
        
        return cell;
        
    }
    
    func accessoryButtonAddTapped(sender : UIButton){
        print(sender.tag)
        print("Tapped the add button \(sender.tag)");
        let getObjectFromArray = self.choosenCategory[sender.tag];
        let getTextFromObject = getObjectFromArray.value(forKey: "item");
        let stringVersion : String! = getTextFromObject as! String;
        print("Choosen element \(stringVersion as String)");
        
        let alertControllerForAcceting = UIAlertController(title: "Add new element to list", message: "Do you want to add \(stringVersion as String) to your list?", preferredStyle: UIAlertControllerStyle.alert);
        
        let alertActionOkay = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) { (UIAlertAction) in
            let valami : String = self.commentList;
            print("This is : \(valami as String)");
            
            self.commentList = "\(valami as String) \(stringVersion as String)";
            let stringVersion2 : String! = self.commentList as String;
            print("This is the final \(stringVersion2 as String)");
            
            alertControllerForAcceting.dismiss(animated: true, completion: nil);
        }
        
        let alertActionNo = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (UIAlertAction) in
            alertControllerForAcceting.dismiss(animated: true, completion: nil);
        }
        
        alertControllerForAcceting.addAction(alertActionOkay);
        alertControllerForAcceting.addAction(alertActionNo);
        
        self.present(alertControllerForAcceting, animated: true, completion: nil);
        
        
    }
    
    @IBAction func newElement(_ sender: Any) {
        
        let alertControllerForNewElement = UIAlertController(title: "新しい物", message: "", preferredStyle: .alert);
        let saveAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            let nameTextfield = alertControllerForNewElement.textFields![0] as UITextField;
            print("The inserted element: \(nameTextfield.text)");
            //self.choosenCategory.append(nameTextfield.text!);
            self.save(name: nameTextfield.text!, entituName: self.enetytiNameChoosen);
            
            self.tableViewComment.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            alertControllerForNewElement.dismiss(animated: true, completion: nil);
        }
        
        alertControllerForNewElement.addTextField { (textField:UITextField!) in
            textField.placeholder = "新しい物の名前"
        }
        
        alertControllerForNewElement.addAction(saveAction);
        alertControllerForNewElement.addAction(cancelAction);
        
        self.present(alertControllerForNewElement, animated: true, completion: nil);
    }

    @IBAction func acceptButton(_ sender: Any) {
        
        //Save the title/comment/lang/longtitude into the core data
        self.saveForAnnotation(title: titleName, comment: commentList, latitude: latitudeValue, longtitude: longtitudeValue);
        
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "消す") { (UITableViewRowAction, IndexPath) in
            //Delete the row from the CoreData
            let choosenNSManagedObject = self.choosenCategory[indexPath.row];
            let chossenString = choosenNSManagedObject.value(forKey: "item");
            
            let stringVersionOfChoosen : String = chossenString as! String;
            
            for item in self.choosenCategory{
                let itemName = item.value(forKey: "item") as! String;
                if(stringVersionOfChoosen == itemName){
                    let indexOfElement = self.choosenCategory.index(of: item);
                    self.choosenCategory.remove(at: indexOfElement!);
                }
            }
            
            self.delete(item: chossenString as! String, entityName: self.enetytiNameChoosen);
            self.tableViewComment.reloadData();
        }
        
        return [deleteAction];
    }
    
    //Save for the data to the database
    func save(name: String, entituName : String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        //choosenCategory.append(name);
        let managedContext = appDelegate.persistentContainer.viewContext
            
            //let entity = NSEntityDescription.entity(forEntityName: "Shopping",
            //in: managedContext)!
        let entity = NSEntityDescription.entity(forEntityName: entituName,
                                                    in: managedContext)!
            
        let item1 = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
            
        item1.setValue(name, forKeyPath: "item")
            
        do {
            try managedContext.save()
            //Put the contact list here
            if entituName == "打ち合わせ" {
                //load the contact list
            }
            else{
                self.choosenCategory.append(item1)
                self.tableViewComment.reloadData();
            }
            //self.choosenCategory.append(item1)
            //self.tableViewComment.reloadData();
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
    }
        
    }
    
    func delete(item: String, entityName: String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext;
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName);
        
        let result = try? managedContext.fetch(fetchRequest)
        let resultData = result as! [NSManagedObject]
        
        for object in resultData {
            //managedContext.delete(object)
            let itemText = object.value(forKey: "item") as! String?;
            if itemText == item {
                managedContext.delete(object);
                print("Object has been deleted");
            }
        }
        
        do {
            try managedContext.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
    }
    
    func fetchData(entytName: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext;
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entytName);
        do {
            choosenCategory = try managedContext.fetch(fetchRequest);
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)");
        }

    }
    
    //Save for the annotation
    func saveForAnnotation(title: String, comment : String, latitude: Double, longtitude: Double){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        //choosenCategory.append(name);
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Marker",
                                                in: managedContext)!
        
        let item1 = NSManagedObject(entity: entity,
                                    insertInto: managedContext)
        
        item1.setValue(title, forKeyPath: "title");
        item1.setValue(comment, forKey: "comment");
        item1.setValue(latitude, forKey: "latitude");
        item1.setValue(longtitude, forKey: "longtitude");
        
        do {
            try managedContext.save()
            // Dismiss the ViewController and go back to root view
            //self.navigationController?.p(animated: true);
            self.view.window?.rootViewController?.viewDidLoad();
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

    }

}
