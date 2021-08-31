# CryptoDemo
Simple app to read crypto pricing data. Targets, features in IOS14, using SwiftUI, and an observable view model.

## Dependencies:
Needs an api token, which you can obtain from from https://finnhub.io. Update the Constants.swift file with that token

## TODO
The original gameplan was to store all tradable symbles in coredata, but due to the complexity of the data tyoes and time concerns, 
the app currently uses a static list of known symbols. 
