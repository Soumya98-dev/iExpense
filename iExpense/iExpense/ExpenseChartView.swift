//
//  ExpenseChartView.swift
//  iExpense
//
//  Created by Soumyadeep Chatterjee on 1/14/25.
//

import SwiftUI
import Charts

struct ExpenseChartView: View {
    //Passing data to chart view
    let expenseSummary: [(type: String, total: Double)]
    var body: some View {
        VStack {
            Text("Expense Breakdown")
                .font(.title)
                .padding()
            
            if !expenseSummary.isEmpty {
                Chart(expenseSummary, id: \.type) { expense in
                    SectorMark(
                        angle: .value("Amount", expense.total),
                        innerRadius: 50,
                        outerRadius: 100
                    )
                    .foregroundStyle(by: .value("Type", expense.type))
                }
                .frame(height: 300)
                .padding()
                .chartLegend(.visible)
            } else {
                Text("No expenses to display")
                    .foregroundColor(.secondary)
                    .padding()
            }
            
            Spacer()
        }
        .navigationTitle("Expense Chart")
        
    }
}

#Preview {
    ExpenseChartView(expenseSummary: [
        (type: "Personal", total: 1200.00), (type: "Business", total: 800.00)
    ])
}
