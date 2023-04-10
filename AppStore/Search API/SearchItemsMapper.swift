//
//  SearchItemsMapper.swift
//  AppStore
//
//  Created by Mohamed Ibrahim on 02/02/2023.
//

import Foundation

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
                id: trackId,
                name: trackName,
                category: primaryGenreName,
                rate: averageUserRating,
                urls: screenshotUrls,
                urlIcon: artworkUrl100
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

