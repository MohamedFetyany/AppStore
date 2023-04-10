//
//  SearchItem.swift
//  AppStore
//
//  Created by Mohamed Ibrahim on 25/01/2023.
//

import Foundation

public struct SearchItem: Equatable {
    public let id: Int
    public let name: String
    public let category: String
    public let rate: Float?
    public let urls: [URL]
    public let urlIcon: URL
    
    public init(
        id: Int,
        name: String,
        category: String,
        rate: Float? = nil,
        urls: [URL],
        urlIcon: URL
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.rate = rate
        self.urls = urls
        self.urlIcon = urlIcon
    }
    
    public var ratingText: String {
        "Rating: \(rate ?? 0)"
    }
}
