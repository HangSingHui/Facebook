//
//  ViewController.swift
//  FaceBook
//
//  Created by Sing Hui Hang on 16/10/25.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    let userURL = "https://dummyjson.com/users?limit=10"
    let pictureURL = "https://ozgrozer.github.io/100k-faces/0/3/"
    var pictureID = 003101
    let table = UITableView()
    var users = [SimplifiedUser]()
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    //Add search controller
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredUsers: [SimplifiedUser] = []
    private var isSearching: Bool{
        let hasText = !(searchController.searchBar.text?.isEmpty ??  true)
        let hasScope = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (hasText || hasScope)
    }
    
    // Diffable data source
    private var dataSource: UITableViewDiffableDataSource<Int, Int>!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "FaceBook 👥"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .white
        
        //configure search
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for Someone"
        navigationItem.searchController = searchController
        definesPresentationContext = true
      
       
        setupTableView()
        setupActivityIndicator()
        setupDataSource()
        fetchUsers()
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .black
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        view.addSubview(table)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.register(UserTableViewCell.self, forCellReuseIdentifier: "cell")
        
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.topAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContent()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int){
        filterContent()
    }
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Int, Int>(
            tableView: table
        ) { [weak self] tableView, indexPath, userID in
            guard let self = self,
                  let user = self.users.first(where: { $0.id == userID }),
                  let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UserTableViewCell
            else {
                return UITableViewCell()
            }
            cell.configure(with: user)
            return cell
        }
        
        table.dataSource = dataSource
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        snapshot.appendSections([0])  // Single section
        let currentUsers = isSearching ? filteredUsers : users
        let userIDs = currentUsers.map { $0.id }
        
        snapshot.appendItems(userIDs, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    
    private func filterContent(){
        var filtered = users
        
        //Narrow by search text
        if let searchText = searchController.searchBar.text?.lowercased(),
            !searchText.isEmpty {
                filtered = filtered.filter { $0.fullName.lowercased().contains(searchText)
            }
        }
        
        filteredUsers = filtered
        updateSnapshot()
    }
    
    
    func fetchUsers() {
        activityIndicator.startAnimating()
        Task {
            let url = URL(string: userURL)!
            
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                if let httpResponse = response as? HTTPURLResponse {
                    guard (200...299).contains(httpResponse.statusCode) else {
                        print("❌ HTTP Error: \(httpResponse.statusCode)")
                        switch httpResponse.statusCode {
                        case 404:
                            print("Not found")
                        case 500...599:
                            print("Server error")
                        default:
                            print("Request failed")
                        }
                        await MainActor.run {
                            self.activityIndicator.stopAnimating()
                        }
                        return
                    }
                }
                
                let newResponse = try JSONDecoder().decode(Response.self, from: data)
                users = newResponse.users
                
                // Assign profile pictures
                updateProfilePictures()
                
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.updateSnapshot()
                }
                
                print("✅ Fetched \(users.count) users:")
                for user in users {
                    print("- \(user.fullName) from \(user.city), \(user.state)")
                }
                
            } catch DecodingError.keyNotFound(_, _) {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                }
                
            } catch DecodingError.typeMismatch(_, let context) {
                print("Context: \(context.debugDescription)")
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                }
                
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func updateProfilePictures() {
        var start = 3101
        users = users.map { user in
            var u = user
            u.profileImage = pictureURL + String(format: "%06d", start) + ".jpg"
            start += 1
            return u
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let userID = dataSource.itemIdentifier(for: indexPath) else {
            return }
        
        guard let selectedUser = users.first(where: { $0.id == userID }) else { return }

        
        let detailVC = UserDetailViewController(user: selectedUser)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
