//
//  AlphabetData.swift
//  Letters
//
//  Created by Arun Kumar Nama on 3/9/23.
//

import Foundation


struct AlphabetData: Codable {
    let alphabets: [AlphabetItem]
}

struct AlphabetItem: Codable, Identifiable {
    let id = UUID()
    let letter: String
}
