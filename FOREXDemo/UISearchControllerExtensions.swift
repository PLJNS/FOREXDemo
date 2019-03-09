//
//  UISearchControllerExtensions.swift
//  FOREXDemo
//
//  Created by n on 3/9/19.
//  Copyright © 2019 Noble Desktop. All rights reserved.
//

import UIKit

extension UISearchController {
    
    var searchBarIsEmpty: Bool {
        return searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return isActive && !searchBarIsEmpty
    }
    
}
