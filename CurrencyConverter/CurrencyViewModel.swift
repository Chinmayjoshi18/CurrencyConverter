import Foundation
import Combine

class CurrencyViewModel: ObservableObject {
    @Published var availableCurrencies = [
        "USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "CNY", "INR"
    ]
    
    @Published var targetCurrencies = [
        "EUR", "GBP", "JPY", "AUD"
    ]
    
    @Published var exchangeRates: [String: Double] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchExchangeRates()
    }
    
    func fetchExchangeRates() {
        // In a production app, you would want to use a real currency API
        // For demo purposes, using sample exchange rates
        exchangeRates = [
            "EUR": 0.85,
            "GBP": 0.73,
            "JPY": 110.0,
            "AUD": 1.35,
            "CAD": 1.25,
            "CHF": 0.92,
            "CNY": 6.45,
            "INR": 74.5
        ]
    }
    
    func updateConversions() {
        // This method would be used to trigger real-time updates
        // For now, it just triggers a UI refresh
        objectWillChange.send()
    }
    
    func convert(amount: Double, from sourceCurrency: String, to targetCurrency: String) -> Double {
        guard let rate = exchangeRates[targetCurrency] else { return 0 }
        
        if sourceCurrency == "USD" {
            return amount * rate
        } else if let sourceRate = exchangeRates[sourceCurrency] {
            // Convert through USD as base currency
            let amountInUSD = amount / sourceRate
            return amountInUSD * rate
        }
        
        return 0
    }
}