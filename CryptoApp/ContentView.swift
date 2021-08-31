//
//  ContentView.swift
//  CryptoApp
//
//  Created by James Lorenzo on 8/26/21.
//

import SwiftUI
import Combine
import Foundation

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var symbolViewModel = CryptoTrackerViewModel()
    
    var body: some View {
        Spacer()
        VStack {
    
            Text(symbolViewModel.currentSymbol)
                .font(.system(size: 48))
                .padding()

            if (symbolViewModel.priceResult.isEmpty) {
                ProgressView("Requesting price data")
                    .frame(height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            } else {
                Text(symbolViewModel.priceResult)
                    .font(.largeTitle)
                    .frame(height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
            
        }
        .onDisappear() {
            symbolViewModel.cancelUpdates()
        }
        Spacer()
        VStack {
            Picker("Select a different crypto currency", selection: $symbolViewModel.currentSymbol, content: {
                ForEach(symbolViewModel.symbols, id: \.self) { Text($0) }
            })
            .padding()
        }.pickerStyle(MenuPickerStyle())
    }
    
}

