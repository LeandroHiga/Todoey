//
//  Item.swift
//  Todoey
//
//  Created by Lean Caro on 23/11/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    
    //Properties
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")  //Define relationship between Item and Category. Each item has a parentCategory of type Category that comes from the property "items"
}
