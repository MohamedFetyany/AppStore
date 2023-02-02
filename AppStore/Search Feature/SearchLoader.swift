//
//  SearchLoader.swift
//  AppStore
//
//  Created by Mohamed Ibrahim on 25/01/2023.
//

import Foundation

public enum LoadSearchResult {
    case success([SearchItem])
    case failure(Error)
}

protocol SearchLoader {
    func load(query: String,completion:@escaping ((LoadSearchResult) -> Void))
}
