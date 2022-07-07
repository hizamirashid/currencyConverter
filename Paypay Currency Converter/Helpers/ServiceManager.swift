//
//  ServiceManager.swift
//  Paypay Currency Converter
//
//  Created by User on 28/06/2022.
//

import Foundation

class ServiceManager {
    public static let shared = ServiceManager()
    
    func request<T: Codable> (
        url: String?,
        expecting: T.Type,
        includeAppID: Bool = false,
        completion: @escaping (Result<T, Error>) -> Void) {
            
            guard let urlObj = URL(string: "\(url ?? "")?app_id=\(Constants.appID)") else { return }
            let session = URLSession.shared
            var request = URLRequest(url: urlObj)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { data, response, error in
                
                guard let data = data else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(CustomError.invalidData))
                    }
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(expecting, from: data)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
}
