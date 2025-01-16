//
//  ContentView.swift
//  iExpense
//
//  Created by Soumyadeep Chatterjee on 11/23/24.
//

import Observation
import SwiftUI

//Represents a single expense
struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses {
    //Creates an empty array of expense items
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }

    //To show the values from UserDefaults
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode(
                [ExpenseItem].self, from: savedItems)
            {
                items = decodedItems
                return
            }
        }

        items = []
    }
}

struct ContentView: View {
    
    //Instance of your Expenses class
    @State private var expenses = Expenses()
    
    //Tracks whether AddView is being shown
    @State private var showingAddExpense = false
    
    @State private var totalBudgetText: String = ""
    
    @State private var totalBudget: Double = 0.0 {
        didSet {
            UserDefaults.standard.set(totalBudget, forKey: "TotalBudget")
        }
    }
    
    @State private var csvFileURL: URL? = nil
    
    private var expenseSummary: [(type: String, total: Double)] {
        let grouped = Dictionary(grouping: expenses.items, by: { $0.type })
        return grouped.map { (type, items) in
            (type: type, total: items.reduce(0) { $0 + $1.amount})
        }
    }
    
    var body: some View{
        NavigationStack {
            VStack {
                //Input field for the total budget
                VStack(alignment: .leading, spacing: 8){
                    Text("Total Budget:")
                        .font(.headline)
                    TextField("Total Budget", text: $totalBudgetText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: totalBudgetText){ oldValue, newValue in
                            if let value = Double(newValue) {
                                totalBudget = value
                            } else {
                                totalBudget = 0.0
                            }
                        }
                }
                .padding()
                
                HStack {
                    Image(systemName: remainingAmount() < 0 ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                        .foregroundColor(remainingAmount() < 0 ? .red : .green)
                    //Displaying remaining budget
                    Text("Remaining: \(remainingAmount(), format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                        .font(.title2)
                        
                }
                .cornerRadius(10)
                .foregroundColor(remainingAmount() < 0 ? Color.red.opacity(0.8): Color.green.opacity(1.1))
                
                
                List {
                    //Section for personal expenses
                    Section(header: Text("Personal")) {
                        ForEach(expenses.items.filter { $0.type == "Personal" }) { item in
                            expenseRow(for: item)
                        }
                        .onDelete { offsets in
                            removeItems(for: "Personal", at: offsets)
                        }
                    }
                    
                    Section(header: Text("Business")) {
                        ForEach(expenses.items.filter { $0.type == "Business"}) { item in
                            expenseRow(for: item)
                        }
                        .onDelete { offsets in
                            removeItems(for: "Business", at: offsets)
                        }
                    }
                }
                
                if let url = csvFileURL {
                    ShareLink(item: url) {
                        Text("Export Expenses")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding()
                } else {
                    Button(action: {
                        csvFileURL = saveCSVToFile()
                    }) {
                        Text("Export Expenses")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
            }
            .navigationTitle("iExpense")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddExpense = true
                    } label : {
                        Label("Add Expense", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ExpenseChartView(expenseSummary: expenseSummary, totalExpense: totalBudget)) {
                        Label("View Chart", systemImage: "chart.pie.fill")
                    }
                }
            }
            
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: expenses)
            }
            .onAppear {
                if let savedBudget = UserDefaults.standard.value(forKey: "TotalBudget") as? Double {
                    totalBudget = savedBudget
                    totalBudgetText = String(format: "%.2f", savedBudget)
                }
            }
        }
    }
    
    
    private func removeItems(for type: String, at offsets: IndexSet) {
        let filteredItems = expenses.items.filter{$0.type == type}
        for offset  in offsets{
            if let index = expenses.items.firstIndex(where: {$0.id == filteredItems[offset].id}){
                expenses.items.remove(at:index)
            }
        }
    }
    
    private func textColor(for amount: Double) -> Color {
        if amount < 10 {
            return .green
        } else if amount < 100 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func expenseRow(for item: ExpenseItem) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
            }
            Spacer()
            Text(
                item.amount,
                format: .currency(
                    code: Locale.current.currency?.identifier
                    ?? "USD")
            )
            .keyboardType(.decimalPad)
            .padding(8)
            .foregroundColor(textColor(for: item.amount))
            .font(item.amount > 100 ? .headline : .body)
            .background(
                item.amount > 100
                ? Color.red.opacity(0.2) : Color.clear
            )
            .clipShape(Capsule())
            
        }
    }
    
    private func remainingAmount() -> Double {
        totalBudget - expenses.items.reduce(0) { (currentTotal, item) in
            currentTotal + item.amount
        }
    }
    
    private func generateCSV() -> String {
        var csvString = "Name, Type, Amount\n"
        
        for item in expenses.items {
            csvString += "\(item.name), \(item.type), \(item.amount)\n"
        }
        
        return csvString
    }
    
    private func saveCSVToFile() -> URL? {
        let csvString = generateCSV()
        let fileName = "Expenses.csv"
        let filePath = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: filePath, atomically: true, encoding: .utf8)
            return filePath
        } catch{
          print("Error saving csv file: \(error)")
            return nil
        }
    }
}

#Preview {
    ContentView()
}
