//
//  NetworkManager.swift
//  iQuiz
//
//  Created by Quinton Baebler on 5/14/24.
//


import Network
import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    var isConnected: Bool = false
    
    private init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = (path.status == .satisfied)
            
            if path.status == .unsatisfied {
                DispatchQueue.main.async {
                    guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
                    let alertController = UIAlertController(title: "No Internet Connection", message: "Please check your network settings and try again.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    if rootViewController.presentedViewController == nil {
                        rootViewController.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        
        monitor.start(queue: queue)
    }
}
