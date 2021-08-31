//
//  ApiService.swift
//  CryptoApp
//
//  Created by James Lorenzo on 8/27/21.
//

import Foundation
import Combine


class CryptoTrackerViewModel : ObservableObject {

    // far too many symbols to parse through in the exchange, we'll just hardcode a subset for now
    let symbols: [String] = ["BTC", "ETH", "ADA", "XLM", "BNB", "XMR", "DOGE", "LINK"]
    
    private let urlSession = URLSession(configuration: .default)
    private var webSocketTask: URLSessionWebSocketTask?
    
    private let baseURL = URL(string: Api.SYMBOL_REALTIME_ENDPOINT)!
    
    @Published var errorMessage: String = ""
    
    // subscribe to the current symbol when set
    @Published var currentSymbol: String = "" {
        didSet {
            priceResult = ""
            subscribe()
        }
    }

    let didChange = PassthroughSubject<Void, Never>()
    @Published var price: String = ""
    
    private var cancellable: AnyCancellable? = nil
    
    var priceResult: String = "" {
        didSet {
            didChange.send()
        }
    }
    
    init() {
        // try to stop the webxsocket from caching data after closure
        urlSession.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        currentSymbol = symbols[0]
        
        cancellable = AnyCancellable($price
            .debounce(for: 1.0, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.priceResult, on: self))
    }

    func connect() {
        webSocketTask = urlSession.webSocketTask(with: baseURL)
        webSocketTask?.resume()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        DispatchQueue.main.async{
            self.price = ""
        }
        
    }
    
    func subscribe() {
        disconnect()
        // just keeping it simple, instead of using the json encoder
        let subscribeMessage = BinanceSubscribeRequest(symbol: currentSymbol)
        connect()
        sendMessage(message: subscribeMessage.toBUSDRequest())
        receiveMessage()
    }
    
    func cancelUpdates() {
        disconnect()
        cancellable?.cancel()
    }
    
    private func sendMessage(message: String)
    {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                self.errorMessage = "Unable to send message: \(error)"
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive {[weak self] result in
            
            switch result {
            case .failure(let error):
                self?.errorMessage = "Error while recieving updates: \(error)"
            case .success(.string(let str)):
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(APIResponse.self, from: Data(str.utf8))
                    DispatchQueue.main.async{
                        self?.price = "\(result.data[0].currPrice)".usdFormat()
                    }
                } catch  {
                    // the data in the stream is somewhat unreliable, so instead of bubbling this data up to the
                    // user, just dumping it to the console. Need a different vendor, methinks
                    print("An error occured decoding price information: \(error.localizedDescription)")
                }
                
                self?.receiveMessage()
                
            default:
                print("unhandled result: \(result)")
            }
        }
    }
    
}

struct APIResponse: Codable {
    var data: [SymbolPrice]
    var type : String
}

struct SymbolPrice : Codable{
    public var symbol: String
    public var currPrice: Float
    
    enum CodingKeys: String, CodingKey {
        case symbol = "s"
        case currPrice = "p"
    }
}

struct BinanceSubscribeRequest: Codable {
    var symbol: String
    
    func toBUSDRequest() -> String {
        return "{\"type\":\"subscribe\",\"symbol\":\"BINANCE:\(symbol)BUSD\"}"
    }
}

// this type of formatting should reside elsewhere, but
// since there is only one format, leaving it in the view for now
extension String {
    func usdFormat() -> String {
        if let value = Double(self) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            if let str = formatter.string(for: value) {
                return str
            }
        }
        return ""
    }
}

