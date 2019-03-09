//
//  SymbolTableViewCell.swift
//  FOREXDemo
//
//  Created by n on 3/9/19.
//  Copyright © 2019 Noble Desktop. All rights reserved.
//

import UIKit

protocol SymbolTableViewCellDelegate: class {
    
    func symbolTableViewCellValueDidChange(_ cell: SymbolTableViewCell)
    
}

class SymbolTableViewCell: UITableViewCell {
    
    weak var delegate: SymbolTableViewCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var favoriteSwitch: UISwitch!
    
    @IBAction func favoriteSwitchValueChanged(_ sender: UISwitch) {
        delegate?.symbolTableViewCellValueDidChange(self)
    }
}
