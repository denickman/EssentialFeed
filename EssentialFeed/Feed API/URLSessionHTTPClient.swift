//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 08.10.2024.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    // MARK: - Properties
    
    private let session: URLSession
    private struct UnexpectedValueRepresentation: Error {}
    
    // MARK: - Init
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Methods
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        
        // Options # 1
//        session.dataTask(with: url) { data, response, error in
//            if let error {
//                completion(.failure(error))
//            }
//            else if let data = data, let response = response as? HTTPURLResponse {
//                completion(.success((data, response)))
//            } else {
//                completion(.failure(UnexpectedValueRepresentation()))
//            }
//        }
//        .resume()
        
        // Options # 2
        
        session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let error = error {
                    /// Если внутри замыкания была выброшена ошибка с помощью throw, то эта ошибка автоматически ловится и преобразуется в .failure.
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    /// Если замыкание завершилось без ошибок, то результат будет типа .success с возвращённым значением.
                    return (data, response)
                } else {
                    throw UnexpectedValueRepresentation()
                }
            })
        }.resume()
    }
}
