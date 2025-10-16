//
//  UsersResponse.swift
//  FaceBook
//
//  Created by Sing Hui Hang on 16/10/25.
//

struct UsersResponse: Codable {
    let users: [User]
    let total: Int
    let skip: Int
    let limit: Int
}
