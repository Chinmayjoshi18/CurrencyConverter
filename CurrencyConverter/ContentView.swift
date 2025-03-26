import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CurrencyViewModel()
    @State private var amount: String = ""
    @State private var selectedSourceCurrency = "USD"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Amount input and source currency selection
                VStack(spacing: 15) {
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 24))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    Picker("Source Currency", selection: $selectedSourceCurrency) {
                        ForEach(viewModel.availableCurrencies, id: \.self) { currency in
                            Text(currency)
                                .tag(currency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Target currencies list
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(viewModel.targetCurrencies, id: \.self) { currency in
                            CurrencyRowView(
                                sourceCurrency: selectedSourceCurrency,
                                targetCurrency: currency,
                                amount: Double(amount) ?? 0,
                                rate: viewModel.exchangeRates[currency] ?? 1.0
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Currency Converter")
            .onChange(of: amount) { _ in
                viewModel.updateConversions()
            }
            .onChange(of: selectedSourceCurrency) { _ in
                viewModel.updateConversions()
            }
        }
    }
}

struct CurrencyRowView: View {
    let sourceCurrency: String
    let targetCurrency: String
    let amount: Double
    let rate: Double
    
    var convertedAmount: Double {
        return amount * rate
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(targetCurrency)
                    .font(.headline)
                Text("1 \(sourceCurrency) = \(rate, specifier: "%.2f") \(targetCurrency)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(convertedAmount, format: .currency(code: targetCurrency))
                .font(.title3)
                .bold()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}