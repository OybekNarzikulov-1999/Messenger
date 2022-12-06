//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 27/11/22.
//

import UIKit

private let reuseID = "Cell"

class NewConversationViewController: UIViewController {
    
    // MARK: - Properties
    
    private let searchBar: UISearchBar = {
       
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for user..."
        return searchBar
        
    }()
    
    private let tableView: UITableView = {
       
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseID)
        tableView.isHidden = true
        return tableView
        
    }()
    
    private let noResultsLabel: UILabel = {
       
        let label = UILabel()
        label.text = "No Users Find..."
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
        
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelButtonTapped))
        navigationController?.navigationBar.backgroundColor = .white
        
        searchBar.becomeFirstResponder()
    }
    
    // MARK: Selectors
    
    @objc private func cancelButtonTapped(){
        self.dismiss(animated: true)
    }
    
    // MARK: Helper Methods

}


extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
