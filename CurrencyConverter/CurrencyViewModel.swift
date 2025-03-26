import Foundation
import Combine

class CurrencyViewModel: ObservableObject {
    @Published var availableCurrencies = [
        "USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "CNY", "INR",
        "NZD", "SGD", "HKD", "SEK", "KRW", "MXN"
    ]
    
    @Published var targetCurrencies: [String] {
        didSet {
            UserDefaults.standard.preferredCurrencies = targetCurrencies
        }
    }
    
    @Published var exchangeRates: [String: Double] = [:]
    @Published var error: ExchangeRateError?
    @Published var isLoading = false
    @Published var lastUpdated: Date?
    
    private let exchangeService = ExchangeRateService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.targetCurrencies = UserDefaults.standard.preferredCurrencies
        self.lastUpdated = UserDefaults.standard.lastUpdateTime
        
        // Auto-refresh exchange rates every 30 minutes if the app is active
        Timer.publish(every: 1800, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchExchangeRates()
            }
            .store(in: &cancellables)
            
        fetchExchangeRates()
    }
    
    func fetchExchangeRates() {
        isLoading = true
        error = nil
        
        exchangeService.fetchExchangeRates(baseCurrency: "USD")
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] rates in
                    self?.exchangeRates = rates
                    self?.lastUpdated = Date()
                    UserDefaults.standard.lastUpdateTime = Date()
                }
            )
            .store(in: &cancellables)
    }
    
    func addTargetCurrency(_ currency: String) {
        guard !targetCurrencies.contains(currency) else { return }
        targetCurrencies.append(currency)
    }
    
    func removeTargetCurrency(_ currency: String) {
        targetCurrencies.removeAll { $0 == currency }
    }
    
    func convert(amount: Double, from sourceCurrency: String, to targetCurrency: String) -> Double {
        guard let targetRate = exchangeRates[targetCurrency] else { return 0 }
        
        if sourceCurrency == "USD" {
            return amount * targetRate
        } else if let sourceRate = exchangeRates[sourceCurrency] {
            // Convert through USD as base currency
            let amountInUSD = amount / sourceRate
            return amountInUSD * targetRate
        }
        
        return 0
    }
    
    var formattedLastUpdated: String {
        guard let date = lastUpdated else { return "Not updated yet" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return "Last updated " + formatter.localizedString(for: date, relativeTo: Date())
    }
}