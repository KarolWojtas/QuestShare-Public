//
//  UserInfo.swift
//  QuestShare
//
//  Created by Karol Wojtas on 23/09/2021.
//

import SwiftUI
import Firebase

struct UserInfo: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    var user: QSUser
    var onSignOut: (() -> Void)?
    
    var body: some View {
        VStack {
            Spacer()
            Text("user-info-login-info")
                .modalTitle()
                .padding(.bottom, 8)
            Text(user.email)
                .font(.title)
            Spacer()
            settings
            Spacer()
            HStack {
                Spacer()
                ButtonGroup([
                    Button("sign-out"){
                        if let safeSignOut = onSignOut {
                            safeSignOut()
                        }
                    }
                ])
                    .padding()
            }
        }
        .background(
            LinearGradient(
                stops: [
                    Gradient.Stop(
                        color: .green, location: -0.3),
                    Gradient.Stop(
                        color: Color(UIColor.systemBackground), location: 0.9)
                ],
                startPoint: .top,
                endPoint: .bottom)
        )
    }
    
    var settings: some View {
        RoundedRectangleContainer {
            Text("settings")
                .font(.title3)
                .foregroundColor(Color(UIColor.systemGray))
                .padding(.bottom, 8)
            Toggle("ignore-distance", isOn: $settingsVM.ignoreDistance)
            Toggle("root-status", isOn: $settingsVM.rootNodeStatus)
            Toggle("disable-root-transform", isOn: $settingsVM.disableRootNodeTransform)
            Toggle("show-root", isOn: $settingsVM.rootNodeVisible)
        }
        .padding(.horizontal, 16)
    }
}

struct UserInfo_Previews: PreviewProvider {
    static var previews: some View {
        UserInfo(user: QSUser(email: "test@test.com"))
            .preferredColorScheme(.dark)
    }
}
