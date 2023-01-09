//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 27/11/22.
//

import UIKit
import JGProgressHUD

private let reuseID = "Cell"

class NewConversationViewController: UIViewController {
    
    // MARK: - Properties
    
    private var users = [[String: String]]()
    private var results = [[String: String]]()
    private var hasFetched = false
    
    private let spinner = JGProgressHUD(style: .dark)
    
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
        
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelButtonTapped))
        navigationController?.navigationBar.backgroundColor = .white
        
        searchBar.becomeFirstResponder()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        view.addSubview(noResultsLabel)
        
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: 100, y: (view.frame.height - 100) / 2, width:  view.frame.width - 200, height: 100)
    }
    
    // MARK: Selectors
    
    @objc private func cancelButtonTapped(){
        self.dismiss(animated: true)
    }
    
    // MARK: Helper Methods

}

// MARK: - TableViewDelegate and TableViewDatasource

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ChatViewController()
        vc.title = "Chat"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
}


// MARK: - Search Bar Delegate

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty  else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        self.spinner.show(in: view)
        
        self.results.removeAll()
        self.searchUsers(query: text)
    }
    
    func searchUsers(query: String){
        
        // Check if array has firebase results
        if hasFetched {
            
            // If it does: filter users
            filterUsers(with: query)
            
        } else {
            
            // If it doesn't: fetch users and filter them
            DatabaseManager.shared.getAllUsers { [weak self] result in
                switch result {
                case .failure(_):
                    print("There is only one user")
                case .success(let fetchedUsers):
                    self?.hasFetched = true
                    self?.users = fetchedUsers
                    self?.filterUsers(with: query)
                }
            }
        }
    }
    
    func filterUsers(with term: String ){
        
        self.spinner.dismiss(animated: true)
        
        guard hasFetched else {
            return
        }
        
        let results: [[String: String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        })
        
        self.results = results
        updateUI()
    }
    
    func updateUI(){
        
        if self.results.isEmpty {
            
            self.tableView.isHidden = true
            self.noResultsLabel.isHidden = false
            
        } else {
            
            self.tableView.isHidden = false
            self.noResultsLabel.isHidden = true
            self.tableView.reloadData()
        }
        
    }
}
