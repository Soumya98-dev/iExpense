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
    var items = [ExpenseItem](){
        didSet{
            if let encoded = try? JSONEncoder().encode(items){
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    //To show the values from UserDefaults
    init(){
        if let savedItems = UserDefaults.standard.data(forKey: "Items"){
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems){
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
    
    var body: some View {
        NavigationStack {
            List {
                //"id: \.name" -> identify each expenses uniquely by it's name
                ForEach(expenses.items) { item in
                    HStack{
                        VStack(alignment: .leading){
                            Text(item.name)
                                .font(.headline)
                            Text(item.type)
                        }
                        Spacer()
                        Text(item.amount, format: .currency(code: "USD"))
                            .padding(8)
                            .foregroundColor(textColor(for: item.amount))
                            .font(item.amount > 100 ? .headline:.body)
                            .background(item.amount > 100 ? Color.red.opacity(0.2) : Color.clear)
                            .clipShape(Capsule())
                    }
                    
                }
                .onDelete(perform: removeItems)
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button("Add Expense", systemImage: "plus") {
                    showingAddExpense = true
                }
            }
        }
        .sheet(isPresented: $showingAddExpense){
            AddView(expenses: expenses)
        }
    }
    
    func removeItems(at offsets: IndexSet){
        expenses.items.remove(atOffsets: offsets)
    }
    
    private func textColor(for amount: Double) -> Color{
        if amount < 10{
            return .green
        }
        else if amount < 100{
            return .orange
        }
        else{
            return .red
        }
    }
}

#Preview {
    ContentView()
}
