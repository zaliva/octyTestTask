# OctyTestTask

A simple iOS app to display currency exchange rates, manage favorites, and provide offline access. Built with UIKit, MVVM and Core Data.


Build & Run
    Requirements: Xcode 15+, iOS 15+
    1. Clone repo 
    2. In terminal run: "cd ../OctyTestTask" and "pod install"
    3. Open .xcworkspace
    4. In file Constants you can enter SWOPApiKey but for test i encrypt self APIKey
    5. Run on Simulator or device.
    
    
Overview
    - Currency rates list.
    - Favorites list with add/remove favorites with instant UI updates.
    - Offline access to last update with core data.

Architecture
    - MVVM + Coordinator: clean separation of concerns.
    - Repository: abstracts Remote (GraphQL) + Local (Core Data).
    - Core Data: local cache for offline mode.
    - Diffable Data Source: safe, animated list updates.
    
Frameworks: 
    - **Alamofire**, **SwiftyJSON** - networking helper
    - **SnapKit** - Auto Layout in code 
    - **CryptoSwift** - API key encryption/decryption 
