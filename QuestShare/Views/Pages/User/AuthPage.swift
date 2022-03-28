//
//  AuthForm.swift
//  QuestShare
//
//  Created by Karol Wojtas on 21/09/2021.
//

import SwiftUI

struct AuthPage: View {
    @StateObject private var vm = AuthFormViewModel()
    @ObservedObject var userVM: UserViewModel
    
    var body: some View {
        VStack {
            if let user = userVM.user{
                UserInfo(user: user) {
                    vm.signOut()
                }
            } else {
                TabView(selection: $vm.tabSelection) {
                    loginForm
                        .tabItem {
                            Image(systemName: "person.circle")
                            Text("log-in")
                        }
                        .tag(AuthFormTab.login)
                    registrationForm
                        .tabItem {
                            Image(systemName: "person.crop.circle.badge.plus")
                            Text("register")
                        }
                        .tag(AuthFormTab.register)
                }
                .onChange(of: vm.tabSelection) { _ in
                    vm.resetForm()
                }
            }
        }
    }
    
    var loginForm: some View {
        VStack {
            serviceError
            RoundedRectangleContainer {
                baseFields
            }
            ButtonGroup ([
                Button("log-in"){
                    vm.logIn()
                }
            ])
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 8)
        .background(gradient)
    }
    
    var registrationForm: some View {
        VStack{
            serviceError
            RoundedRectangleContainer {
                FormInputField(name: "form-name", value: $vm.name)
                baseFields
                Divider()
                FormInputField(name: "confirm-password", value: $vm.confirmPassword, type: .secure)
            }
            ButtonGroup ([
                Button("register"){
                    vm.register()
                }
            ])
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 8)
        .background(gradient)
    }
    
    var baseFields: some View {
        VStack {
            FormInputField(name: "email", value: $vm.email, keyboardType: .emailAddress)
            Divider()
            FormInputField(name: "password", value: $vm.password, type: .secure)
        }
    }
    
    var gradient: some View {
        LinearGradient(
            stops: [
                Gradient.Stop(
                    color: .purple,
                    location: -0.3
                ),
                Gradient.Stop(
                    color: Color(UIColor.systemBackground),
                    location: 0.9
                )
            ],
            startPoint: .top,
            endPoint: .bottom)
    }
    
    var serviceError: some View {
        VStack {
            if let serviceError = vm.serviceError {
                Text(serviceError.localizedDescription)
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
}

struct AuthPage_Previews: PreviewProvider {
    static var userVM = UserViewModel()
    static var previews: some View {
        AuthPage(userVM: userVM)
    }
}
