//  HomeView.swift
//  iExpense
//
//  Créé le 15/08/2025
//
//  Écran principal (Home) : total, filtre (Tous / Perso / Pro),
//  liste des dépenses, ajout, suppression, état vide.

import SwiftUI

struct HomeView: View {
    // Source de vérité locale pour l'instant.
    // Si vous souhaitez partager l'état entre plusieurs écrans,
    // passez `expenses` en paramètre avec @Bindable.
    @State private var expenses = Expenses()
    @State private var showingAddExpense = false
    @State private var filter: Filter = .all

    enum Filter: String, CaseIterable, Identifiable {
        case all = "Tous"
        case personal = "Perso"
        case business = "Pro"
        var id: String { rawValue }
    }

    // Items filtrés selon le segment sélectionné
    private var filteredItems: [ExpenseItem] {
        switch filter {
        case .all: return expenses.items
        case .personal: return expenses.items.filter { $0.type.lowercased() == "personal" }
        case .business: return expenses.items.filter { $0.type.lowercased() == "business" }
        }
    }

    private var total: Double {
        expenses.items.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Fond gradient issu de Theme
                Theme.Gradients.lightBlue
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    header
                        .padding(.horizontal)
                        .padding(.top)

                    // Filtre
                    Picker("Filtre", selection: $filter) {
                        ForEach(Filter.allCases) { f in
                            Text(f.rawValue).tag(f)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Liste
                    if filteredItems.isEmpty {
                        emptyState
                            .padding(.top, 24)
                    } else {
                        List {
                            ForEach(filteredItems) { item in
                                ExpenseRow(item: item)
                                    .listRowSeparator(.visible)
                                    .listRowBackground(Color.clear) // blanc translucide
                            }
                            .onDelete(perform: removeItems)
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.visible)
         //               .background(Color.white.opacity(0.25))

                    }
                }
            }
            .navigationTitle("Dépenses")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddExpense = true
                    } label: {
                        Label("Ajouter", systemImage: "plus")
                    }
                    .tint(.white)
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddView(expenses: expenses)
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(total, format: .currency(code: "EUR"))
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            HStack(spacing: 6) {
                Image(systemName: "list.bullet")
                Text("\(expenses.items.count) éléments")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 44, weight: .regular))
            Text("Aucune dépense")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Ajoutez votre première dépense avec le bouton +")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Actions

    private func removeItems(at offsets: IndexSet) {
        // Nous supprimons à partir de la source non filtrée pour éviter les décalages.
        let idsToDelete = offsets.map { filteredItems[$0].id }
        expenses.items.removeAll { idsToDelete.contains($0.id) }
    }
}

// MARK: - Row

private struct ExpenseRow: View {
    let item: ExpenseItem

    var amountTint: Color {
        switch item.amount {
        case 0..<20: return .green
        case 20..<100: return .orange
        default: return .red
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                Text(localizedType(item.type))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(item.amount, format: .currency(code: "EUR"))
                .font(.headline)
                .foregroundStyle(amountTint)
        }
        .padding(.vertical, 6)
    }

    private func localizedType(_ raw: String) -> String {
        switch raw.lowercased() {
        case "business": return "Pro"
        case "personal": return "Perso"
        default: return raw
        }
    }
}

#Preview {
    HomeView()
}
