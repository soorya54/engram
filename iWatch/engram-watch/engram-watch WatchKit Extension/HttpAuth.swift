//
//  HttpAuth.swift
//  engram-watch WatchKit Extension
//
//  Created by Adam Berg on 2021-05-09.
//

import Foundation
import SwiftUI
import Combine

struct ServerMessage: Decodable {
    let success: Bool
}

extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

class HttpAuth: ObservableObject {

    let sessionManager: URLSession = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30 // seconds
            configuration.timeoutIntervalForResource = 30 // seconds
            return URLSession(configuration: configuration)
        }()
    
    @Published var authenticated = false
    @Published var errorMessage = ""

    func createNote(body: String, type: String = "note") {
        guard let url = URL(string: "https://engram.xyzdigital.com/api/notes") else { return }

        let body: [String: String] = ["body": body, "type": type, "date": Date().string(format: "yyyy-MM-dd")]

        let finalBody = try! JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        sessionManager.dataTask(with: request) { (data, response, error) in
            guard let data = data
            else { return }
            
            let resData = try? JSONDecoder().decode(ServerMessage.self, from: data)
            print(resData)
        }.resume()
    }
    
    func postAuth(username: String, password: String) {
        authenticated = false
        errorMessage = ""
        guard let url = URL(string: "https://engram.xyzdigital.com/api/users/login") else { return }

        let body: [String: String] = ["username": username, "password": password]

        let finalBody = try! JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // https://developer.apple.com/documentation/security/keychain_services/keychain_items/searching_for_keychain_items
        let server = "engram.xyzdigital.com"
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: server,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if (status != errSecItemNotFound) {
            
        }
        if (status == errSecSuccess) {
            guard let existingItem = item as? [String : Any],
                let passwordData = existingItem[kSecValueData as String] as? Data,
                let password = String(data: passwordData, encoding: String.Encoding.utf8),
                let account = existingItem[kSecAttrAccount as String] as? String
            else {
                return
            }
        }



        sessionManager.dataTask(with: request) { (data, response, error) in
            guard
                let data = data,
                let res: HTTPURLResponse = response as? HTTPURLResponse,
                let fields = res.allHeaderFields as? [String: String]
            else { return }
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)

            for cookie in cookies {
                if (cookie.name == "token") {
                    let token = cookie.value
                    print(token)
                }
            }
            
            let resData = try? JSONDecoder().decode(ServerMessage.self, from: data)
            if resData?.success == true {
                
                let account = username
                let password = password.data(using: String.Encoding.utf8)!
                
                let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                            kSecAttrAccount as String: account,
                                            kSecAttrServer as String: server,
                                            kSecValueData as String: password]
                let status = SecItemAdd(query as CFDictionary, nil)
                
                DispatchQueue.main.async {
                    self.authenticated = true
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid credentials"
                }
            }
        }.resume()
    }
}
