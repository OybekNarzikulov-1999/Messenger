//
//  ConversationTableViewCell.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 12/01/23.
//

import UIKit
import SnapKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    // Properties
    
    static let identifier = "ConversationTableViewCell"
    
    private lazy var userImageView: UIImageView = {
       
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        return imageView
        
    }()
    
    private lazy var usernameLabel: UILabel = {
       
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        label.numberOfLines = 1
        return label
        
    }()
    
    private lazy var userMessageLabel: UILabel = {
       
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        return label
        
    }()
    
    // Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(10)
            make.height.equalTo(80)
            make.width.equalTo(80)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.left.equalTo(userImageView.snp.right).offset(10)
            make.right.equalTo(-10)
            make.top.equalTo(10)
            make.height.equalTo(30)
        }
        
        userMessageLabel.snp.makeConstraints { make in
            make.left.equalTo(userImageView.snp.right).offset(10)
            make.right.equalTo(-10)
            make.top.equalTo(usernameLabel.snp.bottom).offset(5)
            make.bottom.equalTo(-10)
        }
        
    }
    
    // Helper Methods
    
    public func configure(with model: Conversation){
        
        usernameLabel.text = model.otherUserName
        userMessageLabel.text = model.latestMessage.text
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path) { [weak self] result in
            switch result {
            case .success(let url):
                
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
                
            case .failure(let error):
                print("Failed to download image url: \(error)")
            }
        }
        
    }
    
}
