//
//  VisitManagementView.swift
//  DarnaApp
//

import SwiftUI

struct VisitManagementView: View {
    @StateObject private var visitStore = VisitStore()
    @State private var selectedTab = 0
    @State private var showReservation = false
    @State private var currentUserId = UUID() // En production, récupérer depuis l'auth
    @State private var isOwner = false // En production, déterminer depuis l'auth
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Segmented Control
                    Picker("", selection: $selectedTab) {
                        Text("Calendrier").tag(0)
                        Text("Visites").tag(1)
                        Text("Historique").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        VisitCalendarView(visitStore: visitStore, userId: currentUserId, isOwner: isOwner)
                            .tag(0)
                        
                        VisitsListView(visitStore: visitStore, userId: currentUserId, isOwner: isOwner)
                            .tag(1)
                        
                        VisitHistoryView(visitStore: visitStore, userId: currentUserId, isOwner: isOwner)
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Gestion des Visites")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showReservation = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppTheme.onPrimary)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.primary)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            isOwner.toggle()
                        } label: {
                            Label(isOwner ? "Mode Locataire" : "Mode Propriétaire", 
                                  systemImage: isOwner ? "person.fill" : "person.badge.key.fill")
                        }
                    } label: {
                        Image(systemName: "person.circle")
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .sheet(isPresented: $showReservation) {
                VisitReservationView(visitStore: visitStore, userId: currentUserId, isOwner: isOwner)
            }
            .onAppear {
                visitStore.loadVisits()
                visitStore.scheduleReminders()
            }
        }
        .tint(AppTheme.primary)
    }
}


