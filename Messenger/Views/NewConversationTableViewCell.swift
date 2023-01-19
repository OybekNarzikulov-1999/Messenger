//
//  NewConversationTableViewCell.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 19/01/23.
//

import UIKit
import SnapKit
import SDWebImage

class NewConversationTableViewCell: UITableViewCell {
    
    // Properties
    
    static let identifier = "NewConversationTableViewCell"
    
    private lazy var userImageView: UIImageView = {
       
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 18
        imageView.layer.masksToBounds = true
        return imageView
        
    }()
    
    private lazy var usernameLabel: UILabel = {
       
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 1
        return label
        
    }()
    
    // Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(usernameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(10)
            make.height.equalTo(36)
            make.width.equalTo(36)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.left.equalTo(userImageView.snp.right).offset(10)
            make.right.equalTo(-10)
            make.top.equalTo(contentView.snp.centerY).offset(-10)
            make.height.equalTo(20)
        }
        
    }
    
    // Helper Methods
    
    public func configure(with model: SearchResult){
        
        self.usernameLabel.text = model.name
        
        let path = "images/\(model.email)_profile_picture.png"
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
