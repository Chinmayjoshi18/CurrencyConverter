import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CurrencyViewModel()
    @State private var amount: String = ""
    @State private var selectedSourceCurrency = "USD"
    @State private var showingCurrencyPicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Amount input and source currency selection
                VStack(spacing: 15) {
                    HStack {
                        TextField("Enter amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 24))
                        
                        Picker("Source Currency", selection: $selectedSourceCurrency) {
                            ForEach(viewModel.availableCurrencies, id: \.self) { currency in
                                Text(currency)
                                    .tag(currency)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Last updated timestamp
                    Text(viewModel.formattedLastUpdated)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // Error view
                if let error = viewModel.error {
                    ErrorView(error: error) {
                        viewModel.fetchExchangeRates()
                    }
                }
                
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
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.removeTargetCurrency(currency)
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                // Add currency button
                Button {
                    showingCurrencyPicker = true
                } label: {
                    Label("Add Currency", systemImage: "plus.circle.fill")
                        .font(.headline)
                }
                .padding()
            }
            .navigationTitle("Currency Converter")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.fetchExchangeRates()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .sheet(isPresented: $showingCurrencyPicker) {
                CurrencyPickerView(
                    availableCurrencies: viewModel.availableCurrencies,
                    selectedCurrencies: viewModel.targetCurrencies,
                    onCurrencySelected: { currency in
                        viewModel.addTargetCurrency(currency)
                        showingCurrencyPicker = false
                    }
                )
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
}

struct ErrorView: View {
    let error: ExchangeRateError
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
                .font(.title)
            
            Text(error.message)
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
            
            Button("Retry") {
                retry()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
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
                Text("1 \(sourceCurrency) = \(rate, specifier: "%.4f") \(targetCurrency)")
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

struct CurrencyPickerView: View {
    let availableCurrencies: [String]
    let selectedCurrencies: [String]
    let onCurrencySelected: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    var unselectedCurrencies: [String] {
        availableCurrencies.filter { !selectedCurrencies.contains($0) }
    }
    
    var body: some View {
        NavigationView {
            List(unselectedCurrencies, id: \.self) { currency in
                Button {
                    onCurrencySelected(currency)
                } label: {
                    Text(currency)
                }
            }
            .navigationTitle("Add Currency")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}