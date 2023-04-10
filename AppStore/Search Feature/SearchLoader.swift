//
//  SearchLoader.swift
//  AppStore
//
//  Created by Mohamed Ibrahim on 25/01/2023.
//

import Foundation

public protocol SearchLoader {
    typealias Result = Swift.Result<[SearchItem],Error>
    
    func load(query: String,completion:@escaping ((Result) -> Void))
}
