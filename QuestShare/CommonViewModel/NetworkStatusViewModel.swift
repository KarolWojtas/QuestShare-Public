//
//  NetworkStatusViewModel.swift
//  QuestShare
//
//  Created by Karol Wojtas on 15/11/2021.
//

import Foundation
import Network

class NetworkStatusViewModel: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global()
    @Published var isConnected: Bool = false
    func startMonitoring(){
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = {[weak self] path in
            self?.isConnected = path.status == .satisfied
        }
    }
    func stopMonitoring(){
        monitor.cancel()
    }
}
