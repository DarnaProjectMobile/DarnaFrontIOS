//
//  VisitCalendarView.swift
//  DarnaApp
//

import SwiftUI

struct VisitCalendarView: View {
    @ObservedObject var visitStore: VisitStore
    let userId: UUID
    let isOwner: Bool
    
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showVisitDetail: VisitModel? = nil
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var daysInMonth: [Date] {
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let adjustedFirstWeekday = (firstWeekday + 5) % 7 // Ajuster pour lundi = 0
        
        var days: [Date] = []
        
        // Ajouter les jours du mois précédent pour compléter la première semaine
        if adjustedFirstWeekday > 0 {
            let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
            let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: previousMonth)!.count
            for i in (daysInPreviousMonth - adjustedFirstWeekday + 1)...daysInPreviousMonth {
                if let date = calendar.date(byAdding: .day, value: i - daysInPreviousMonth, to: firstDayOfMonth) {
                    days.append(date)
                }
            }
        }
        
        // Ajouter les jours du mois actuel
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        // Ajouter les jours du mois suivant pour compléter la dernière semaine
        let remainingDays = 42 - days.count
        for i in 1...remainingDays {
            if let date = calendar.date(byAdding: .day, value: i, to: days.last!) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private var visitsForSelectedDate: [VisitModel] {
        visitStore.getVisitsForDate(selectedDate, userId: userId, isOwner: isOwner)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Month Navigation
            HStack {
                Button {
                    withAnimation {
                        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppTheme.primary)
                }
                
                Spacer()
                
                Text(currentMonth, formatter: monthFormatter)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Button {
                    withAnimation {
                        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.primary)
                }
            }
            .padding()
            
            // Weekday Headers
            HStack(spacing: 0) {
                ForEach(["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                        hasVisits: !visitStore.getVisitsForDate(date, userId: userId, isOwner: isOwner).isEmpty,
                        visitCount: visitStore.getVisitsForDate(date, userId: userId, isOwner: isOwner).count
                    ) {
                        selectedDate = date
                    }
                }
            }
            .padding()
            
            Divider()
            
            // Visits for selected date
            ScrollView {
                LazyVStack(spacing: 12) {
                    if visitsForSelectedDate.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 50))
                                .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                            Text("Aucune visite prévue")
                                .font(.headline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.top, 50)
                    } else {
                        ForEach(visitsForSelectedDate) { visit in
                            VisitCardView(visit: visit, isOwner: isOwner) {
                                showVisitDetail = visit
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(item: $showVisitDetail) { visit in
            VisitDetailView(visit: visit, visitStore: visitStore, isOwner: isOwner)
        }
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isCurrentMonth: Bool
    let hasVisits: Bool
    let visitCount: Int
    let action: () -> Void
    
    private var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(dayNumber)")
                    .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                    .foregroundColor(
                        isSelected ? AppTheme.onPrimary :
                        isCurrentMonth ? AppTheme.textPrimary :
                        AppTheme.textSecondary.opacity(0.5)
                    )
                
                if hasVisits {
                    Circle()
                        .fill(isSelected ? AppTheme.onPrimary : AppTheme.primary)
                        .frame(width: 6, height: 6)
                    
                    if visitCount > 1 {
                        Text("\(visitCount)")
                            .font(.caption2)
                            .foregroundColor(isSelected ? AppTheme.onPrimary : AppTheme.primary)
                    }
                }
            }
            .frame(width: 44, height: 44)
            .background(isSelected ? AppTheme.primary : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

