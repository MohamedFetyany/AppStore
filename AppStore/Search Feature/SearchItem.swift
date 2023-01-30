//
//  SearchItem.swift
//  AppStore
//
//  Created by Mohamed Ibrahim on 25/01/2023.
//

import Foundation

public struct SearchItem: Equatable {
    public let trackId: Int
    public let trackName: String
    public let primaryGenreName: String
    public let rate: Float?
    public let screenshotUrls: [URL]
    public let iconImage: URL
    public let formattedPrice: String?
    public let description: String?
    public let releaseNotes: String?
    public let artistName: String?
    public let collectionName: String?
    
    public init(
        trackId: Int,
        trackName: String,
        primaryGenreName: String,
        rate: Float? = nil,
        screenshotUrls: [URL],
        iconImage: URL,
        formattedPrice: String? = nil,
        description: String? = nil,
        releaseNotes: String? = nil,
        artistName: String? = nil,
        collectionName: String? = nil
    ) {
        self.trackId = trackId
        self.trackName = trackName
        self.primaryGenreName = primaryGenreName
        self.rate = rate
        self.screenshotUrls = screenshotUrls
        self.iconImage = iconImage
        self.formattedPrice = formattedPrice
        self.description = description
        self.releaseNotes = releaseNotes
        self.artistName = artistName
        self.collectionName = collectionName
    }
}
