//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    let realm = try! Realm()
    
    var todoItems: Results<Item>?
    var selectedCategory: Category? {
        didSet { //didSet it's going to happen as soon as selectedCategory get set with a value. This way, we make sure to execute loadItems() when we already have a value for selectedCategory
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Show SQLite database
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory!.name
        
        if let colorHex = selectedCategory?.cellColor {
            
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation Controller does not exists.")
            }
            
            if let navBarColor = UIColor(hexString: colorHex) {
                navBar.backgroundColor = navBarColor
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                searchBar.barTintColor = navBarColor
            }
        }
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        //Check if todoItems is nil
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            //Gradient color                                  Current row number divided by total of rows/items
            if let color = UIColor(hexString: selectedCategory!.cellColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
   
            //Ternary operator --> value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done ? .checkmark : .none
            
        } else {
            cell.textLabel?.text = "No Items Addesd"
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    //To know which row was selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Check if todoItems is nil
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done //If it's done, update to not done, and viceversa
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        
        //When row selected, turn grey and white back again. If not use, the cell keep grey color when selected
        tableView.deselectRow(at: indexPath, animated: true)
        
//        //To delete/remove item
//        try realm.write {
//            realm.delete(item)
//        }
    }
    
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }

    
    
    
    //MARK: - Add New Items
    
    //Add button (+)
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write { //Save to realm
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving context \(error)")
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        //Add texfield to alert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action) //Add the action to the alert
        
        present(alert, animated: true, completion: nil) //Show alert
        
    }
    
    //MARK: - Model Manipulation Methods
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true) //Sort the result

        tableView.reloadData()
    }
}

//MARK: - SearchBar Delegate Methods

extension TodoListViewController: UISearchBarDelegate {

    //When search button is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        //Filter and sort the items by dateCreated
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    //Triggered when the text inside the searchbar is changed
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            //Filter and sort the items by dateCreated
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
    }
}


