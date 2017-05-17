//
//  ViewControllerAddNotes.swift
//  locationMonitoringSupportSystemSwift
//
//  Created by Kubota Naoyuki on 2017/05/04.
//  Copyright © 2017年 Kubota Naoyuki. All rights reserved.
//

import UIKit

class ViewControllerAddNotes: UIViewController, UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var tableViewTitle: UITableView!
    
    let titles:[String] = ["買い物","薬","打ち合わせ"];
    let cellReuseIndentifier = "cell";
    let iconNames:[String] = ["shopping.png","medicine.jpeg","people.png"];
    
    //The recived long and latitude
    var gottenLat : Double = 0.0;
    var gottenLong : Double = 0.0;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Check if we have recived the lat and long
        print("The recived lat : \(gottenLat)");
        print(gottenLong);
        
        //register the tableview
        self.tableViewTitle.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIndentifier);
        tableViewTitle.delegate = self;
        tableViewTitle.dataSource = self;
        
    }
    
    //Set number of rows in the tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count;
    }
    
    //create cell for each tableview row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableViewTitle.dequeueReusableCell(withIdentifier: cellReuseIndentifier) as UITableViewCell!;
        
        cell.textLabel?.text = self.titles[indexPath.row];
        let costumIcon : UIImage = UIImage(named: self.iconNames[indexPath.row])!;
        cell.imageView?.image = costumIcon;
        
        return cell;
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let choosenTitle : String = self.titles[indexPath.row];
        let commentVC : ViewControllerComment = ViewControllerComment();
        commentVC.titleName = choosenTitle;
        commentVC.latitudeValue = gottenLat;
        commentVC.longtitudeValue = gottenLong;
        self.present(commentVC, animated: true, completion: nil);
        
    }


}
