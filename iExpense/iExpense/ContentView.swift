//
//  ContentView.swift
//  iExpense
//
//  Created by Soumyadeep Chatterjee on 11/23/24.
//

import Observation
import SwiftUI

//Represents a single expense
struct ExpenseItem: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses {
    //Creates an empty array of expense items
    var items = [ExpenseItem]()
}

struct ContentView: View {
    //Instance of your Expenses class
    @State private var expenses = Expenses()
    var body: some View {
        NavigationStack {
            List {
                //"id: \.name" -> identify each expenses uniquely by it's name
                ForEach(expenses.items) { item in
                    Text(item.name)
                }
                .onDelete(perform: removeItems)
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button("Add Expense", systemImage: "plus") {
                    let expense = ExpenseItem(name: "Test", type: "Personal", amount: 5)
                    expenses.items.append(expense)
                }
            }
        }
    }
    
    func removeItems(at offsets: IndexSet){
        expenses.items.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}
