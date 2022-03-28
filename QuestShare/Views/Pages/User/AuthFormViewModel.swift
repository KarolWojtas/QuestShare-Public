//
//  AuthFormViewModel.swift
//  QuestShare
//
//  Created by Karol Wojtas on 21/09/2021.
//

import Foundation
import SwiftUI
import Combine
import Firebase
import FirebaseFunctions
import AVFoundation

class AuthFormViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var tabSelection = AuthFormTab.login
    @Published var authPending = false
    @Published var serviceError: Error?
    private var cancellables = Set<AnyCancellable>()
    
    func logIn(){
        authPending = true
        serviceError = nil
        Auth.auth().signIn(withEmail: email, password: password){ [weak self] authResult, error in
            self?.serviceError = error
            self?.authPending = false
        }
    }
    
    func register(){
        authPending = true
        serviceError = nil
        createUser(email: email, password: password, displayName: name)
            .sink { [weak self] (error: Subscribers.Completion<Error>) in
                self?.serviceError = error as? Error
                self?.authPending = false
            } receiveValue: { [weak self] _ in
                self?.logIn()
            }
            .store(in: &cancellables)

    }
    
    private func createUser(email: String, password: String, displayName: String) -> Future<String, Error> {
        Future { promise in
            Functions.functions().httpsCallable("registerUser")
                .call ([
                    "email": email,
                    "password": password,
                    "displayName": displayName
                ]){ result, error in
                    if let data = result?.data as? [String: String], let uid = data["uid"] {
                        promise(.success(uid))
                    } else if let safeError = error {
                        promise(.failure(safeError))
                    }
                }
        }
    }
    
    func signOut(){
        do {
            try Auth.auth().signOut()
        } catch  {
            serviceError = error
        }
    }
    
    func resetForm(){
        name = ""
        email = ""
        password = ""
        confirmPassword = ""
        serviceError = nil
    }
}

enum AuthFormTab {
    case login
    case register
}
