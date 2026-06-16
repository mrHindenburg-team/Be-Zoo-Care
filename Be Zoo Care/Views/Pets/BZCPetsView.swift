import SwiftUI
import SwiftData

struct BZCPetsView: View {
    @Environment(BZCGuardianProgress.self) private var progress
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BZCPet.name) private var pets: [BZCPet]

    @State private var viewModel = BZCPetsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                BZCColors.gradientBackground.ignoresSafeArea()

                Group {
                    if viewModel.filteredPets(pets).isEmpty {
                        emptyState
                    } else {
                        petList
                    }
                }
            }
            .navigationTitle("My Pets")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Pet", systemImage: "plus.circle.fill", action: openAddPet)
                        .tint(BZCColors.richGold)
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search pets…")
            .sheet(isPresented: $viewModel.isAddingPet) {
                BZCAddPetView(viewModel: viewModel) {
                    let _ = viewModel.createPet(in: modelContext, progress: progress)
                }
            }
            .navigationDestination(for: BZCPet.self) { pet in
                BZCPetDetailView(pet: pet)
            }
        }
    }

    // MARK: - Subviews

    private var petList: some View {
        ScrollView {
            LazyVStack(spacing: BZCLayout.spacingDefault) {
                speciesFilter
                    .padding(.horizontal, BZCLayout.paddingDefault)

                ForEach(viewModel.filteredPets(pets)) { pet in
                    NavigationLink(value: pet) {
                        BZCPetCardView(pet: pet)
                            .padding(.horizontal, BZCLayout.paddingDefault)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, BZCLayout.paddingDefault)
            .padding(.bottom, 80)
        }
        .scrollIndicators(.hidden)
    }

    private var speciesFilter: some View {
        ScrollView(.horizontal) {
            HStack(spacing: BZCLayout.spacingSmall) {
                filterChip(label: "All", isSelected: viewModel.selectedSpecies == nil) {
                    viewModel.selectedSpecies = nil
                }
                ForEach(BZCSpecies.allCases, id: \.self) { species in
                    filterChip(
                        label: species.rawValue,
                        isSelected: viewModel.selectedSpecies == species
                    ) {
                        viewModel.selectedSpecies = viewModel.selectedSpecies == species ? nil : species
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private func filterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption.bold())
                .foregroundStyle(isSelected ? BZCColors.darkBackground : BZCColors.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? BZCColors.richGold : BZCColors.glassBackground)
                        .overlay(
                            Capsule().strokeBorder(isSelected ? .clear : BZCColors.glassBorder, lineWidth: 1)
                        )
                )
        }
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Pets Yet", systemImage: "pawprint.fill")
        } description: {
            Text("Add your first pet to start tracking their care, health, and wellness journey.")
        } actions: {
            Button("Add My First Pet", action: openAddPet)
                .buttonStyle(.borderedProminent)
                .tint(BZCColors.royalPurple)
        }
        .foregroundStyle(BZCColors.textPrimary, BZCColors.textSecondary)
    }

    private func openAddPet() {
        viewModel.isAddingPet = true
    }
}

#Preview {
    BZCPetsView()
        .modelContainer(for: [BZCPet.self], inMemory: true)
        .environment(BZCGuardianProgress())
}
