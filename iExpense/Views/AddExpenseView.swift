//  AddExpenseView.swift — refonte
//  iExpense
//
//  Objectifs:
//  - Même thème que HomeView (gradient), mais un peu plus contrasté
//  - Validation: champs vides -> messages d'erreurs
//  - Choix de catégorie Pro / Perso via boutons
//  - Pavé numérique: saisie du prix dans un seul conteneur, affiché au centre en gros

import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) private var dismiss

    // Données
    @State private var name: String = ""
    @State private var category: Category = .personal
    @State private var cents: Int = 0

    // Validation
    @State private var attemptedSave = false

    var expenses: Expenses

    enum Category: String, CaseIterable { case business, personal }

    private var amount: Double { Double(cents) / 100.0 }
    private var isNameValid: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var isAmountValid: Bool { cents > 0 }
    private var formIsValid: Bool { isNameValid && isAmountValid }

    @State private var showConfirm = false
    @State private var confirmCategory: String = "Personal" // stocke la sélection du popup

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Gradients.midBlue
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        titleSection
                        nameField
                        amountPad
                        saveButton
                    }
                    .padding(20)
                    .blur(radius: showConfirm ? 7 : 0)

                }
                .overlay {
                    if showConfirm {
                        AddExpenseConfirmationView(
                            isPresented: $showConfirm,
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            amount: amount,
                            category: $confirmCategory
                        ) {
                            // onConfirm
                            let item = ExpenseItem(
                                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                type: confirmCategory,
                                amount: amount
                            )
                            expenses.items.append(item)
                            dismiss()
                        }
                        .transition(.opacity.combined(with: .scale))
                    }
                }

            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                    }
                    .tint(.white)
                }
            }
        }
    }

    // MARK: - Sections

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Nouvelle dépense")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text("Renseigne un nom, une catégorie, puis saisis le montant avec le pavé numérique.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Libellé")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))

            TextField("Ex: Café, Uber, Snacks…", text: $name)
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
                .padding(.horizontal, 14)
                .frame(height: 54)
                .background(
                    // un peu plus contrasté que HomeView
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.28))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                        )
                )
                .foregroundColor(.black)
                .font(.system(size: 18, weight: .semibold, design: .rounded))

            if attemptedSave && !isNameValid {
                Label("Le nom est obligatoire", systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote)
                    .foregroundColor(.red.opacity(0.95))
            }
        }
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Catégorie")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))

            HStack(spacing: 10) {
                categoryButton(.personal, title: "Perso", icon: "person")
                categoryButton(.business, title: "Pro", icon: "briefcase")
            }
        }
    }

    private func categoryButton(_ value: Category, title: String, icon: String) -> some View {
        let isSelected = category == value
        return Button {
            category = value
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(isSelected ? Color.white.opacity(0.35) : Color.white.opacity(0.2))
            )
            .overlay(
                Capsule()
                    .strokeBorder(Color.white.opacity(isSelected ? 0.9 : 0.5), lineWidth: 1)
            )
            .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }

    private var amountPad: some View {
        VStack(spacing: 16) {
            // Affichage du montant au centre, dans un seul conteneur
            VStack(spacing: 6) {
                Text("Montant")
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.85))
                Text(amount, format: .currency(code: "EUR"))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
                    .foregroundColor(.white)
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.28)) // plus contrasté que HomeView
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                    )
            )

            if attemptedSave && !isAmountValid {
                Label("Le montant doit être supérieur à 0", systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote)
                    .foregroundColor(.red.opacity(0.95))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            NumericPad(cents: $cents)
        }
    }

    private var saveButton: some View {
        Button {
            attemptedSave = true
            guard formIsValid else { return }
            confirmCategory = (category == .business) ? "Business" : "Personal"
            showConfirm = true

        } label: {
            HStack {
                Image(systemName: "tray.and.arrow.down.fill")
                Text("Enregistrer")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(formIsValid ? Color.purple.opacity(0.85) : Color.gray.opacity(0.75)))
            .foregroundColor(.white)
        }
        .disabled(!formIsValid)
        .padding(.top, 8)
    }
}

// MARK: - Pavé numérique
private struct NumericPad: View {
    @Binding var cents: Int

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(1...9, id: \.self) { n in
                key(String(n)) { appendDigit(n) }
            }
            key("C") { cents = 0 }
            key("0") { appendDigit(0) }
            key("⌫") { backspace() }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.32))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func key(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.title3).bold()
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.25))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                )
                .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions
    private func appendDigit(_ n: Int) {
        // Limiter à 9 chiffres pour éviter les débordements (max ~ 9 999 999,99)
        if cents <= 99_999_999 { cents = cents * 10 + n }
    }
    private func backspace() { cents /= 10 }
}

#Preview {
    AddView(expenses: Expenses())
}
