import Foundation
import Combine

enum ExchangeRateError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case apiError(String)
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let message):
            return "API error: \(message)"
        }
    }
}

struct ExchangeRateResponse: Codable {
    let result: String
    let base_code: String
    let conversion_rates: [String: Double]
}

class ExchangeRateService {
    // Replace with your actual API key from exchangerate-api.com
    private let apiKey = "YOUR_API_KEY"
    private let baseURL = "https://v6.exchangerate-api.com/v6"
    
    func fetchExchangeRates(baseCurrency: String) -> AnyPublisher<[String: Double], ExchangeRateError> {
        guard let url = URL(string: "\(baseURL)/\(apiKey)/latest/\(baseCurrency)") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { ExchangeRateError.networkError($0) }
            .flatMap { data, response -> AnyPublisher<[String: Double], ExchangeRateError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: .invalidResponse).eraseToAnyPublisher()
                }
                
                guard httpResponse.statusCode == 200 else {
                    return Fail(error: .apiError("Status code: \(httpResponse.statusCode)"))
                        .eraseToAnyPublisher()
                }
                
                return Just(data)
                    .decode(type: ExchangeRateResponse.self, decoder: JSONDecoder())
                    .map { $0.conversion_rates }
                    .mapError { _ in ExchangeRateError.invalidResponse }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}