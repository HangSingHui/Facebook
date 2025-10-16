//
//  User.swift
//  FaceBook
//
//  Created by Sing Hui Hang on 16/10/25.
//

struct User: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let maidenName: String
    let age: Int
    let gender: String
    let email: String
    let phone: String
    let username: String
    let password: String
    let birthDate: String
    let image: String
    let bloodGroup: String
    let height: Double
    let weight: Double
    let eyeColor: String
    let hair: Hair
    let ip: String
    let address: Address
    let macAddress: String
    let university: String
    let bank: Bank
    let company: Company
    let ein: String
    let ssn: String
    let userAgent: String
    let crypto: Crypto
    let role: String
}

// MARK: - Hair
struct Hair: Codable {
    let color: String
    let type: String
}

// MARK: - Address
struct Address: Codable {
    let address: String
    let city: String
    let state: String
    let stateCode: String
    let postalCode: String
    let coordinates: Coordinates
    let country: String
}

// MARK: - Coordinates
struct Coordinates: Codable {
    let lat: Double
    let lng: Double
}

// MARK: - Bank
struct Bank: Codable {
    let cardExpire: String
    let cardNumber: String
    let cardType: String
    let currency: String
    let iban: String
}

// MARK: - Company
struct Company: Codable {
    let department: String
    let name: String
    let title: String
    let address: Address
}

// MARK: - Crypto
struct Crypto: Codable {
    let coin: String
    let wallet: String
    let network: String
}
