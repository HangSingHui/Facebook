//
//  UserTableViewCell.swift
//  FaceBook
//
//  Created by Sing Hui Hang on 16/10/25.
//

import UIKit
class UserTableViewCell: UITableViewCell{
    static let identifier = "UserTableViewCell"
    
    private let userName = UILabel()
    private let userAddress = UILabel()
    private let userAge = UILabel()
    
    private let userStack = UIStackView()
    private let detailStack = UIStackView()
    private let cardView = UIView()
    
    //Declare userImage closure
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return imageView
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOpacity = 0.1
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        accessoryType = .disclosureIndicator
        
        //configure detail stack
        detailStack.axis = .vertical
        detailStack.spacing = 4
        detailStack.translatesAutoresizingMaskIntoConstraints = false
        
        //configure user stack
        userStack.axis = .horizontal
        userStack.spacing = 4
        userStack.translatesAutoresizingMaskIntoConstraints = false
        
//        stack.addArrangedSubview(userImageView) //add uiimage
        detailStack.addArrangedSubview(userName)
        detailStack.addArrangedSubview(userAddress)
        detailStack.addArrangedSubview(userAge)
        
        userStack.addArrangedSubview(userImageView)
        userStack.addArrangedSubview(detailStack)
        
        cardView.addSubview(userStack)
    
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            userStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            userStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            userStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -40),
            userStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with user: SimplifiedUser){
        userName.text = user.fullName
        userAddress.text = "\(user.city), \(user.state)"
        if let urlString = user.profileImage, let url = URL(string: urlString) {
            loadImage(from: url)
        }
        else{
            userImageView.image = UIImage(systemName: "person.crop.circle")
        }
    }
    
    private func loadImage(from url: URL) {
        userImageView.image = UIImage(systemName: "hourglass") // placeholder
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self, let data = data, let image = UIImage(data: data), error == nil else {
                return
            }
            DispatchQueue.main.async {
                self.userImageView.image = image
            }
        }.resume()
    }
    

}






