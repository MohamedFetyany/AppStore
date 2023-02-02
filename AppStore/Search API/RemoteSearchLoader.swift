//
//  RemoteSearchLoader.swift
//  AppStore
//
//  Created by Mohamed Ibrahim on 02/02/2023.
//

import Foundation

public class RemoteSearchLoader {
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result {
        case success([SearchItem])
        case failure(Error)
    }
    
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL,client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion:@escaping ((Result) -> Void)) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(data,response):
                do {
                    let items = try SearchItemsMapper.map(data: data, from: response)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
                
            case .failure:
                completion(.failure(.connectivity))
            }
            
        }
    }
}
