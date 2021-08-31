//
//  CryptoViewModel.swift
//  CryptoApp
//
//  Created by James Lorenzo on 8/26/21.
//

import Foundation

// initially was populating the currency from an API call, with the intent of
// storing in in coredata and have that be the source of truth. ran out of
// time, but keeping this here so I can get back to it later.

class CryptoSymbolsRepository: ObservableObject {
    
    private let urlSession = URLSession(configuration: .default)
    private var webSocketTask: URLSessionWebSocketTask?
    let jsonEncoder = JSONEncoder()

    @Published var symbols = [CryptoSymbol]()

    init() {
        fetchCryptoSymbols()
    }

    func fetchCryptoSymbols()
    {
        URLSession.shared.dataTaskPublisher(for: URL(string: Api.SYMBOL_LIST_ENDPOINT)!)
            .map { $0.data }
            .decode(type: [CryptoSymbol].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: \.symbols, on: self)
    }
}

