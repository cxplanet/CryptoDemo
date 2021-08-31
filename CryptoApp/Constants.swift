//
//  Constants.swift
//  CryptoApp
//
//  Created by James Lorenzo on 8/27/21.
//

import Foundation

struct Api {
    private static let apiToken = "c4js56qad3idfmhpas6g"
    static let SYMBOL_LIST_ENDPOINT = "https://finnhub.io/api/v1/crypto/symbol?exchange=binance&token=\(apiToken)"
    static let SYMBOL_REALTIME_ENDPOINT = "wss://ws.finnhub.io?token=\(apiToken)"
}

