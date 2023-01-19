//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 27/11/22.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    // MARK: - Properties
    
    private var users = [[String: String]]()
    private var results = [SearchResult]()
    private var hasFetched = false
    
    public var completion: ((SearchResult) -> Void)?
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let searchBar: UISearchBar = {
       
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for user..."
        return searchBar
        
    }()
    
    private let tableView: UITableView = {
       
        let tableView = UITableView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(NewConversationTableViewCell.self, forCellReuseIdentifier: NewConversationTableViewCell.identifier)
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
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationTableViewCell.identifier, for: indexPath) as! NewConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedUser = results[indexPath.row]
        self.dismiss(animated: true) {
            self.completion?(selectedUser)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
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
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {return}
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        let results: [SearchResult] = self.users.filter({
            guard safeEmail != $0["email"] else {return false}
            
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        }).compactMap { element in
            
            guard let name = element["name"], let email = element["email"] else {return nil}
            
            return SearchResult(name: name, email: email)
        }
        
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


struct SearchResult {
    let name: String
    let email: String
}
