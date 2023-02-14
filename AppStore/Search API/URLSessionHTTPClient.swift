//
//  URLSessionHTTPClient.swift
//  AppStore
//
//  Created by Mohamed Ibrahim on 14/02/2023.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL,completion: @escaping ((HTTPClientResult) -> Void)) {
        session.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(error))
            } else if let data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
}
