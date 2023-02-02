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

final class SearchItemsMapper: Decodable {
    
    private let results: [Item]
    
    var items: [SearchItem] {
        results.map { $0.item }
    }
    
    private struct Item: Decodable {
        let trackId: Int
        let trackName: String
        let primaryGenreName: String
        let averageUserRating: Float?
        let screenshotUrls: [URL]
        let artworkUrl100: URL
        let formattedPrice: String?
        let description: String?
        let releaseNotes: String?
        let artistName: String?
        let collectionName: String?
        
        var item: SearchItem {
            SearchItem(
                trackId: trackId,
                trackName: trackName,
                primaryGenreName: primaryGenreName,
                rate: averageUserRating,
                screenshotUrls: screenshotUrls,
                iconImage: artworkUrl100,
                formattedPrice: formattedPrice,
                description: description,
                releaseNotes: releaseNotes,
                artistName: artistName,
                collectionName: collectionName
            )
        }
    }
    
    static func map(data: Data,from response: HTTPURLResponse) throws -> [SearchItem] {
        guard response.statusCode == 200 ,let root = try? JSONDecoder().decode(SearchItemsMapper.self, from: data) else {
            throw RemoteSearchLoader.Error.invalidData
        }
        
        return root.items
    }
}
