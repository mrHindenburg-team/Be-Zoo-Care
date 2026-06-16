import SwiftUI
import PhotosUI

struct BZCAddPetView: View {
    @Bindable var viewModel: BZCPetsViewModel
    var onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var photoItem: PhotosPickerItem?

    private enum Field: Hashable { case name, breed, weight, notes }
    @FocusState private var focus: Field?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                BZCColors.gradientBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: BZCLayout.spacingLarge) {
                        photoPickerSection
                        identitySection
                        physicalSection
                        notesSection
                    }
                    .padding(BZCLayout.paddingDefault)
                    .padding(.bottom, 100)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .onTapGesture { focus = nil }

                saveButtonOverlay
            }
            .navigationTitle("New Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(BZCColors.textSecondary)
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") { focus = nil }
                            .font(.subheadline.bold())
                            .foregroundStyle(BZCColors.richGold)
                    }
                }
            }
        }
        .onChange(of: photoItem) { loadPhoto() }
    }

    // MARK: - Photo Picker

    private var photoPickerSection: some View {
        VStack(spacing: BZCLayout.spacingSmall) {
            PhotosPicker(selection: $photoItem, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let img = viewModel.newPetPhoto {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 108, height: 108)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(BZCColors.glassBackground)
                                .frame(width: 108, height: 108)
                                .overlay {
                                    VStack(spacing: 6) {
                                        Image(systemName: "camera.fill")
                                            .font(.title2)
                                            .foregroundStyle(BZCColors.richGold)
                                        Text("Photo")
                                            .font(.caption2.bold())
                                            .foregroundStyle(BZCColors.textSecondary)
                                    }
                                }
                        }
                    }
                    .overlay(Circle().strokeBorder(BZCColors.richGold.opacity(0.45), lineWidth: 2))

                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(BZCColors.richGold)
                        .background(BZCColors.darkBackground, in: Circle())
                        .offset(x: 2, y: 2)
                }
            }
            .sensoryFeedback(.selection, trigger: viewModel.newPetPhoto != nil)

            if viewModel.newPetPhoto != nil {
                Button("Remove photo") { viewModel.newPetPhoto = nil }
                    .font(.caption)
                    .foregroundStyle(BZCColors.errorRed.opacity(0.85))
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, BZCLayout.spacingSmall)
        .animation(BZCMotion.springDefault, value: viewModel.newPetPhoto != nil)
    }

    // MARK: - Identity

    private var identitySection: some View {
        BZCFormCard(title: "Identity", icon: "pawprint.fill") {
            VStack(spacing: BZCLayout.spacingDefault) {
                fieldRow(label: "Name", required: true) {
                    TextField("e.g. Max, Luna…", text: $viewModel.newPetName)
                        .focused($focus, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focus = .breed }
                        .multilineTextAlignment(.trailing)
                }

                rowDivider

                HStack {
                    fieldLabel("Species")
                    Spacer()
                    Picker("Species", selection: $viewModel.newPetSpecies) {
                        ForEach(BZCSpecies.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    .tint(BZCColors.richGold)
                    .labelsHidden()
                }

                rowDivider

                fieldRow(label: "Breed") {
                    TextField("Optional", text: $viewModel.newPetBreed)
                        .focused($focus, equals: .breed)
                        .submitLabel(.done)
                        .onSubmit { focus = nil }
                        .multilineTextAlignment(.trailing)
                }

                rowDivider

                VStack(alignment: .leading, spacing: BZCLayout.spacingSmall) {
                    fieldLabel("Sex")
                    Picker("Sex", selection: $viewModel.newPetGender) {
                        ForEach(BZCGender.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }

                rowDivider

                Toggle(isOn: $viewModel.newPetHasDOB.animation(BZCMotion.springDefault)) {
                    fieldLabel("Date of Birth")
                }
                .tint(BZCColors.richGold)

                if viewModel.newPetHasDOB {
                    DatePicker(
                        "Born",
                        selection: $viewModel.newPetDateOfBirth,
                        in: ...Date.now,
                        displayedComponents: .date
                    )
                    .tint(BZCColors.richGold)
                    .transition(.push(from: .top).combined(with: .opacity))
                }
            }
        }
    }

    // MARK: - Physical

    private var physicalSection: some View {
        BZCFormCard(title: "Physical Stats", icon: "scalemass.fill") {
            fieldRow(label: "Weight") {
                HStack(spacing: 4) {
                    TextField("0.0", value: $viewModel.newPetWeight, format: .number.precision(.fractionLength(1)))
                        .focused($focus, equals: .weight)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 72)
                    Text("kg")
                        .font(.subheadline)
                        .foregroundStyle(BZCColors.textTertiary)
                }
            }
        }
    }

    // MARK: - Notes

    private var notesSection: some View {
        BZCFormCard(title: "Notes", icon: "note.text") {
            TextField(
                viewModel.newPetName.isEmpty ? "Any notes about your pet…" : "Notes about \(viewModel.newPetName)…",
                text: $viewModel.newPetNotes,
                axis: .vertical
            )
            .focused($focus, equals: .notes)
            .lineLimit(3...8)
            .submitLabel(.done)
            .onSubmit { focus = nil }
            .foregroundStyle(BZCColors.textPrimary)
            .font(.subheadline)
        }
    }

    // MARK: - Save Button

    private var saveButtonOverlay: some View {
        Button {
            focus = nil
            onSave()
            dismiss()
        } label: {
            HStack(spacing: BZCLayout.spacingSmall) {
                Image(systemName: "plus.circle.fill")
                Text(viewModel.newPetName.isEmpty ? "Add Pet" : "Add \(viewModel.newPetName)")
                    .contentTransition(.numericText())
            }
            .font(.headline.bold())
            .foregroundStyle(viewModel.isFormValid ? BZCColors.darkBackground : BZCColors.textTertiary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                viewModel.isFormValid
                    ? AnyShapeStyle(BZCColors.gradientGold)
                    : AnyShapeStyle(BZCColors.glassBackground),
                in: RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
            )
        }
        .disabled(!viewModel.isFormValid)
        .padding(.horizontal, BZCLayout.paddingLarge)
        .padding(.bottom, 32)
        .animation(BZCMotion.springDefault, value: viewModel.isFormValid)
        .animation(BZCMotion.springDefault, value: viewModel.newPetName)
    }

    // MARK: - Helpers

    private var rowDivider: some View {
        Divider().background(BZCColors.glassBorder)
    }

    private func fieldLabel(_ text: String, required: Bool = false) -> some View {
        Text(required ? text + " *" : text)
            .font(.subheadline)
            .foregroundStyle(BZCColors.textSecondary)
    }

    @ViewBuilder
    private func fieldRow<Content: View>(
        label: String,
        required: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack {
            fieldLabel(label, required: required)
            Spacer(minLength: BZCLayout.spacingDefault)
            content()
                .font(.subheadline)
                .foregroundStyle(BZCColors.textPrimary)
        }
    }

    private func loadPhoto() {
        Task {
            guard let item = photoItem,
                  let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else { return }
            viewModel.newPetPhoto = image
        }
    }
}

// MARK: - Form Card

struct BZCFormCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            Label(title, systemImage: icon)
                .font(.caption.bold())
                .foregroundStyle(BZCColors.textTertiary)
                .textCase(.uppercase)
                .tracking(0.6)

            content()
        }
        .padding(BZCLayout.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                .fill(BZCColors.glassBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                        .strokeBorder(BZCColors.glassBorder, lineWidth: 1)
                )
        )
    }
}
