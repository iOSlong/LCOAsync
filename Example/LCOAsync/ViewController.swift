//
//  ViewController.swift
//  LCOAsync
//
//  Created by xuewu1011@163.com on 08/27/2019.
//  Copyright (c) 2019 xuewu1011@163.com. All rights reserved.
//

import UIKit
import LCOAsync

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var tableView:UITableView? = nil
    var dataSource:NSMutableArray? = [];
    var selfDispatchModel:Bool? = false
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section\(section)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows:NSArray = self.dataSource?[section] as! NSArray
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cellReuseID"
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell.init(style:.subtitle, reuseIdentifier: identifier)
        }
        cell?.accessoryType = .detailDisclosureButton
        let rows:NSArray = self.dataSource?[indexPath.section] as! NSArray
        let model:LCSignModel = rows[indexPath.row] as! LCSignModel
        cell?.textLabel?.text = model.signDesc
        cell?.detailTextLabel?.text = model.signName
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rows:NSArray = self.dataSource?[indexPath.section] as! NSArray
        let model:LCSignModel = rows[indexPath.row] as! LCSignModel
        let signVC:SignViewController   = SignViewController()
        signVC.signModel                = model
        signVC.selfDispatchModel        = selfDispatchModel
        self.navigationController?.pushViewController(signVC, animated:true)
    }
    
    
    func configureTableView() {
        self.tableView =  UITableView(frame: self.view.frame, style: .plain)
        self.tableView?.backgroundColor = .clear
        self.tableView?.dataSource   = self
        self.tableView?.delegate     = self
        
        self.view.addSubview(self.tableView!)
    }
    
    
    @objc func modelChange(sw:UISwitch) -> Void {
        selfDispatchModel = sw.isOn
        print("sw.isOn:\(sw.isOn)")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureTableView()
        
        
        let swView:UISwitch = UISwitch.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 30))
        swView.addTarget(self, action: #selector(modelChange(sw:)), for: .valueChanged)
        let rightBarItem :UIBarButtonItem = UIBarButtonItem.init(customView: swView)
        self.navigationItem.rightBarButtonItem = rightBarItem
    }
    
}
