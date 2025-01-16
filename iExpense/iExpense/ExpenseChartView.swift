//
//  ExpenseChartView.swift
//  iExpense
//
//  Created by Soumyadeep Chatterjee on 1/14/25.
//

import Charts
import SwiftUI

struct ExpenseChartView: View {
    //Passing data to chart view
    let expenseSummary: [(type: String, total: Double)]
    let totalExpense: Double

    var body: some View {
        NavigationStack{
            VStack(spacing: 20) {
                Text("Expense Breakdown")
                    .font(.title2)
                    .padding()
                
                if !expenseSummary.isEmpty {
                    Chart(expenseSummary, id: \.type) { expense in
                        SectorMark(
                            angle: .value("Amount", expense.total),
                            innerRadius: 60,
                            outerRadius: 130
                        )
                        .foregroundStyle(by: .value("Type", expense.type))
                    }
                    .frame(height: 300)
                    .chartLegend(.visible)
                } else {
                    Text("No expenses to display")
                        .foregroundColor(.secondary)
                        .padding()
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(expenseSummary, id: \.type){ expense in
                        HStack{
                            Text(expense.type)
                                .font(.headline)
                            Spacer()
                            
                            Text(String(format: "%.2f", expense.total) + "$")
                                .font(.body)
                            Text(String(format: "%.0f%%", (expense.total / totalExpense) * 100))
                                .font(.body)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Categories")
    }
}

#Preview {
    ExpenseChartView(
        expenseSummary: [
            (type: "Personal", total: 1200.00),
            (type: "Business", total: 800.00),
        ],
        totalExpense: 800.00
    )
}
