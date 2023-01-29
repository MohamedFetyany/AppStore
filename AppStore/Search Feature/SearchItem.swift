//
//  SearchItem.swift
//  AppStore
//
//  Created by Mohamed Ibrahim on 25/01/2023.
//

import Foundation

public struct SearchItem: Equatable {
    let trackId: Int
    let trackName: String
    let primaryGenreName: String
    let rate: Float?
    let screenshotUrls: [URL]
    let iconImage: URL
    var formattedPrice: String?
    var description: String?
    var releaseNotes: String?
    var artistName: String?
    var collectionName: String?
}
