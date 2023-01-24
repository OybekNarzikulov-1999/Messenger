//
//  ProfileViewModel.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 24/01/23.
//

import Foundation

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let completion: (() -> Void)?
}
