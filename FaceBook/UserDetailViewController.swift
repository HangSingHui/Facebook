//
//  UserDetailViewController.swift
//  FaceBook
//
//  Created by Sing Hui Hang on 16/10/25.
//

import UIKit

class UserDetailViewController: UITableViewController {
    
    var user: SimplifiedUser!
    
    init(user: SimplifiedUser){
        self.user = user
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented.")
    }
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 100 // circular
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    
    override func viewDidLoad(){
        super.viewDidLoad( )
        tableView.backgroundColor = .white
        title = user.fullName
        
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        switch section{
        case 0: return 1 //profile picture
        case 1: return 1 //name
        case 2: return 2 //state + city
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.selectionStyle = .none
        
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            // Clear any previous content
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            
            cell.contentView.addSubview(profileImageView)
            
            NSLayoutConstraint.activate([
                profileImageView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                profileImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                profileImageView.widthAnchor.constraint(equalToConstant: 200),
                profileImageView.heightAnchor.constraint(equalToConstant: 200)
            ])
            
            // Load image from URL
            if let urlString = user.profileImage, let url = URL(string: urlString) {
                loadImage(from: url)
            } else {
                profileImageView.image = UIImage(systemName: "person.crop.circle")
            }

        case (1,0):
            cell.textLabel?.text = "Name"
            cell.detailTextLabel?.text = user.fullName

        case (2,0):
            cell.textLabel?.text = "State"
            cell.detailTextLabel?.text = user.state

        case (2,1):
            cell.textLabel?.text = "City"
            cell.detailTextLabel?.text = user.city

        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        switch section{
        case 0: return "PHOTO"
        case 1: return "NAME"
        case 2: return "LOCATION"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath ) -> CGFloat{
        if indexPath.section == 0{
            return 200 //height for image
        }
        return 44
        
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.section == 0{
            return 200
        }
        return 44
    }

    private func loadImage(from url: URL) {
        profileImageView.image = UIImage(systemName: "hourglass") // placeholder
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, let image = UIImage(data: data), error == nil else {
                return
            }
            DispatchQueue.main.async {
                self.profileImageView.image = image
            }
        }.resume()
    }


}
