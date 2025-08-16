//  AddExpenseConfirmationView.swift
//  iExpense
//
//  Popup de confirmation après tentative d'enregistrement
//  - Récap nom + montant
//  - Sélecteur catégorie (menu déroulant)
//  - Boutons OK / X
//  - Fond blanc, texte noir, centré ~1/3 de l'écran

import SwiftUI

struct AddExpenseConfirmationView: View {
    @Binding var isPresented: Bool

    let name: String
    let amount: Double

    @Binding var category: String // "Personal" ou "Business"

    var onConfirm: () -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .onTapGesture { isPresented = false }


                VStack(alignment: .center, spacing: 16) {
                    
                    VStack(alignment: .leading, spacing: 8) {
        
                        Text(name.isEmpty ? "—" : name)
                            .font(.title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .textCase(nil)
                    }

                    VStack(alignment: .leading, spacing: 8) {

                        Text(amount, format: .currency(code: "EUR"))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .monospacedDigit()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        ZStack {
                            Theme.Gradients.lightPurple
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                )

                            HStack {
                                Text(category == "Business" ? "Pro" : "Perso")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.black.opacity(0.7))
                                    .rotationEffect(.degrees(category == "Pro" ? 180 : 0))
                                                    .animation(.spring(response: 0.25, dampingFraction: 0.85), value: category)
                                                    .foregroundColor(.black.opacity(0.7))
                            }
                            .padding(.horizontal, 12)
                            .contentShape(Rectangle()) // rend toute la zone tappable
                            .onTapGesture {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                                    category = (category == "Business") ? "Personal" : "Business"
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 48)
                    }

                    Spacer()

                    HStack(spacing: 12) {
                        Button {
                            isPresented = false
                        } label: {
                            Text("Modifier")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.black.opacity(0.08))
                                .foregroundColor(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }

                        Button {
                            onConfirm()
                            isPresented = false
                        } label: {
                            Text("OK")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.purple.opacity(0.9))
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                }
                .padding(20)
                .frame(
                    width: min(geo.size.width * 0.9, 450),
                    height: min(geo.size.height * 0.5, 270)
                )
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(radius: 24)
            }
        }
    }
}

#Preview {
    @Previewable @State var presented = true
    @Previewable @State var cat = "Personal"
    return AddExpenseConfirmationView(isPresented: $presented, name: "Café", amount: 3.5, category: $cat) {}
}
