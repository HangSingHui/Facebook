//
//  ViewController.swift
//  FaceBook
//
//  Created by Sing Hui Hang on 16/10/25.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate {
    
    let userURL = "https://dummyjson.com/users?limit=10"
    let pictureURL = "https://ozgrozer.github.io/100k-faces/0/3/"
    var pictureID = 003101
    let table = UITableView()
    var users = [SimplifiedUser]()
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // Diffable data source
    private var dataSource: UITableViewDiffableDataSource<Int, Int>!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "FaceBook 👥"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .white
        
        setupActivityIndicator()
        setupTableView()
        setupDataSource()
        fetchUsers()
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        
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
        let userIDs = users.map { $0.id }
        snapshot.appendItems(userIDs, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
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
                
            } catch DecodingError.keyNotFound(let key, let context) {
                print("❌ Missing key: '\(key.stringValue)'")
                print("Context: \(context.debugDescription)")
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                }
                
            } catch DecodingError.typeMismatch(let type, let context) {
                print("❌ Type mismatch for type: \(type)")
                print("Context: \(context.debugDescription)")
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                }
                
            } catch {
                print("❌ Error: \(error)")
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
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("🔵 Cell tapped at row \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let userID = dataSource.itemIdentifier(for: indexPath) else {
            print("❌ No userID found")
            return
        }
        print("🔵 UserID: \(userID)")
        
        guard let selectedUser = users.first(where: { $0.id == userID }) else {
            print("❌ No user found with ID \(userID)")
            return
        }
        print("🔵 Selected user: \(selectedUser.fullName)")
        
        let detailVC = UserDetailViewController(user: selectedUser)
        print("🔵 DetailVC created, pushing...")
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
