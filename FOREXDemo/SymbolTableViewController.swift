//
//  ViewController.swift
//  FOREXDemo
//
//  Created by n on 3/2/19.
//  Copyright © 2019 Noble Desktop. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class SymbolTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    
    lazy var db = Firestore.firestore()
    var favoritesData: [QueryDocumentSnapshot] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var symbols: [String] = []
    var filteredSymbols: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        
//        db.collection("favorites").addDocument(data: ["EURUSD": true, "USDCAD": false])
        
        db.collection("favorites").addSnapshotListener { (snapshot, error) in
            self.favoritesData = snapshot?.documents ?? []
            self.tableView.reloadData()
        }
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search FX Pairs"
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        let urlString = "https://forex.1forge.com/1.0.3/symbols?api_key=scKdc5njprJwBjonYn417rDniGrve9aM"
        Alamofire.request(urlString).responseJSON { response in
            if let responseData = response.data {
                self.symbols = (try? JSONDecoder().decode([String].self, from: responseData)) ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? "" {
        case "SymbolTableViewController_to_SymbolDetailViewController":
            guard let destination = segue.destination as? SymbolDetailViewController else {
                fatalError() // you'e changed the class of the destination
            }
            for indexPath in tableView.indexPathsForSelectedRows ?? [] {
                let passedSymbols = searchController.isFiltering ? filteredSymbols[indexPath.row] : symbols[indexPath.row]
                destination.symbols.append(passedSymbols)
            }
            
        default:
            fatalError() // you've defined a segue without implementing prepare.
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isFiltering ? filteredSymbols.count : symbols.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SymbolTableViewCell", for: indexPath) as! SymbolTableViewCell
        let symbol: String = searchController.isFiltering ? filteredSymbols[indexPath.row] : symbols[indexPath.row]
        cell.titleLabel.text = symbol
        cell.favoriteSwitch.isOn = favoritesData.contains { (snapshot: QueryDocumentSnapshot) -> Bool in
            return (snapshot[symbol] as? Bool) ?? false == true
        }
        cell.selectionStyle = .none
        let cellIsSelected = tableView.indexPathsForSelectedRows?.contains(indexPath) ?? false
        cell.accessoryType = cellIsSelected ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
        enableDoneButtonIfNecessary()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
        enableDoneButtonIfNecessary()
    }
    
    func enableDoneButtonIfNecessary() {
        doneBarButtonItem.isEnabled = (tableView.indexPathsForSelectedRows?.count ?? 0) > 0
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filteredSymbols = symbols.filter({ (symbol) -> Bool in
            return symbol.contains(searchText.uppercased())
        })
        tableView.reloadData()
    }
}
