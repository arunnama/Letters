//
//  LoadAlphabets.swift
//  Letters
//
//  Created by Arun Kumar Nama on 3/9/23.
//

import Foundation

class AlphabetLoader: ObservableObject {
    @Published var alphabets: [String] = []

    func fetchAlphabets() {
        guard let url = URL(string: "https://raw.githubusercontent.com/arunnama/traindemo2/main/alphabets.json") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode([String].self, from: data)
                    DispatchQueue.main.async {
                        self.alphabets = decodedData
                    }
                } catch {
                    print("Error decoding alphabet data: \(error)")
                }
            } else if let error = error {
                print("Error fetching alphabet data: \(error)")
            }
        }.resume()
    }
}
