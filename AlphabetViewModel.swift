//
//  AlphabetViewModel.swift
//  Letters
//
//  Created by Arun Kumar Nama on 3/9/23.
//

import Foundation
import Combine

class AlphabetViewModel: ObservableObject {
    @Published var alphabets: [AlphabetItem] = []

    init() {
        fetchAlphabets()
    }

    func fetchAlphabets() {
        if let url = URL(string: "https://raw.githubusercontent.com/arunnama/traindemo2/main/alphabets.json") {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode(AlphabetData.self, from: data)
                        DispatchQueue.main.async {
                            self.alphabets = decodedData.alphabets
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                } else if let error = error {
                    print("Error fetching JSON data: \(error)")
                }
            }.resume()
        }
    }
}
