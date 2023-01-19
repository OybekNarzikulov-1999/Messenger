//
//  PhotoViewerViewController.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 27/11/22.
//

import UIKit
import SnapKit

class PhotoViewerViewController: UIViewController {
    
    // MARK: - Properties
    
    private var url: URL?
    
    private lazy var imageView: UIImageView = {
       
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
        
    }()
    
    // MARK: - Lifecycle
    
    init(url: URL?){
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(imageView)
        imageView.sd_setImage(with: url, completed: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
    
    // MARK: - Helper Methods
    
    
}
