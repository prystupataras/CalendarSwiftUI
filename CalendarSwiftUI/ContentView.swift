//
//  ContentView.swift
//  CalendarSwiftUI
//
//  Created by Taras Prystupa on 26.12.2024.
//

import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var currentMonth = Calendar.current.component(.month, from: Date())
    @State private var currentYear = Calendar.current.component(.year, from: Date())
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Set Monday as the first day of the week
        return calendar
    }()
    
    let week: [String] = {
        var collection = Calendar(identifier: .gregorian).shortWeekdaySymbols
        collection = collection.rotateFromLeft(by: 1)
        return collection
    }()
    
    var body: some View {
        VStack {
           
            topView

            weekdaysView
            
            monthView
            
            Spacer(minLength: 0)
            
            bottomView
        }
        .padding()
    }
}


#Preview {
    CalendarView()
}

//MARK: body
extension CalendarView {
    private var topView: some View {
        VStack {
            Text("\(yearName(currentYear))")
                .font(.title)
            
            HStack {
                Button(action: {
                    changeMonth(by: -1)
                    
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title)
                }
                
                Spacer()
                
                Text("\(monthName(currentMonth))")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    changeMonth(by: 1)
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title)
                }
            }
            .padding(.horizontal)
        }
    }
    private var weekdaysView: some View {
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(week, id: \.self) { weekday in

                Text(weekday)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
        }
        .padding(.horizontal)
    }
    
    private var monthView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(daysInMonth(), id: \.self) { day in
                if day == 0 {
                    Text("") // Empty space for days before the 1st
                } else {
                    let date = getDateFor(day: day)
                    Button(action: {
                        selectedDate = date
                    }) {
                        Text("\(day)")
                            .padding(8)
                            .background(isSameDay(date1: date, date2: selectedDate) ? Color.blue : Color.clear)
                            .background(isSameDay(date1: date, date2: Date()) ? Color.secondary.opacity(0.4) : Color.clear)
                            .foregroundColor(isSameDay(date1: date, date2: selectedDate) ? .white : .primary)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    private var bottomView: some View {
        VStack {
            Text("Selected Date: \(selectedDate, formatter: dateFormatter)")
                .padding(.top)
            
            Image(systemName: "magnifyingglass")
                .background {
                    Capsule()
                        .foregroundColor(Color.blue)
                        .frame(width: 100, height: 50)
                }
                .padding()
                .onTapGesture {
                    selectedDate = Date()
                    currentMonth = Calendar.current.component(.month, from: Date())
                    currentYear = Calendar.current.component(.year, from: Date())
                }
        }
    }
}

//MARK: - functions
private extension CalendarView {
    private func daysInMonth() -> [Int] {
        let dateComponents = DateComponents(year: currentYear, month: currentMonth)
        guard let date = calendar.date(from: dateComponents),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return []
        }
        
        let numDays = range.count
        var firstDayOfMonth = calendar.component(.weekday, from: date)
        firstDayOfMonth -= calendar.firstWeekday - 1 //Adjust first day for correct offset
        if firstDayOfMonth < 1 {
            firstDayOfMonth += 7
        }
        
        var days: [Int] = Array(repeating: 0, count: firstDayOfMonth - 1)
        days.append(contentsOf: 1...numDays)
        return days
    }

    private func getDateFor(day: Int) -> Date {
        let dateComponents = DateComponents(year: currentYear, month: currentMonth, day: day)
        return calendar.date(from: dateComponents)!
    }

    private func monthName(_ month: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let dateComponents = DateComponents(year: currentYear, month: month)
        guard let date = calendar.date(from: dateComponents) else { return "" }
        return dateFormatter.string(from: date)
    }
    
    private func yearName(_ year: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        let dateComponents = DateComponents(year: year)
        guard let date = calendar.date(from: dateComponents) else { return "" }
        return dateFormatter.string(from: date)
    }

    private func changeMonth(by value: Int) {
        currentMonth += value
        if currentMonth > 12 {
            currentMonth = 1
            currentYear += 1
        } else if currentMonth < 1 {
            currentMonth = 12
            currentYear -= 1
        }
    }

    private func isSameDay(date1: Date, date2: Date) -> Bool {
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
}


extension Array {
    func rotateFromLeft(by steps: Int) -> [Element] {
        guard !isEmpty else { return [] }

        let count = self.count // Use self.count for clarity
        let moveIndex = (steps % count + count) % count // Handle negative steps correctly

        let rotatedElements = Array(self[moveIndex...]) + Array(self[0..<moveIndex])
        return rotatedElements
    }
}
