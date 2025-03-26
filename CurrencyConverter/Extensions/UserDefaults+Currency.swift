import Foundation

extension UserDefaults {
    private enum Keys {
        static let preferredCurrencies = "preferredCurrencies"
        static let lastUpdateTime = "lastUpdateTime"
    }
    
    var preferredCurrencies: [String] {
        get {
            array(forKey: Keys.preferredCurrencies) as? [String] ?? [
                "EUR", "GBP", "JPY", "AUD"
            ]
        }
        set {
            set(newValue, forKey: Keys.preferredCurrencies)
        }
    }
    
    var lastUpdateTime: Date? {
        get {
            return object(forKey: Keys.lastUpdateTime) as? Date
        }
        set {
            set(newValue, forKey: Keys.lastUpdateTime)
        }
    }
}