//
//  Category.swift
//  Todoey
//
//  Created by Lean Caro on 23/11/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
 
    //Properties
    @objc dynamic var name: String = ""
    @objc dynamic var cellColor: String = ""
    let items = List<Item>() //Define relationship between Category and Item. Each Category has a list of Items. Initialize an empty list of Item objects
    
}
