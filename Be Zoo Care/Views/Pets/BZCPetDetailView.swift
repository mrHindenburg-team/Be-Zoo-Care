import SwiftUI
import SwiftData

struct BZCPetDetailView: View {
    @Bindable var pet: BZCPet
    @Environment(BZCGuardianProgress.self) private var progress
    @Environment(\.modelContext) private var modelContext

    @State private var selectedTab: BZCPetDetailTab = .care
    @State private var showLogCare = false
    @State private var showAddReminder = false

    var body: some View {
        ZStack {
            BZCColors.gradientBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                petHeroHeader
                tabSelector
                tabContent
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("More", systemImage: "ellipsis.circle") {
                    Button("Edit Profile", systemImage: "pencil") { }
                    Button("Add Reminder", systemImage: "bell.badge") { showAddReminder = true }
                    Divider()
                    Button("Archive Pet", systemImage: "archivebox", role: .destructive) {
                        pet.isArchived = true
                    }
                }
                .tint(BZCColors.richGold)
            }
        }
        .sheet(isPresented: $showLogCare) {
            BZCLogCareSheet(pet: pet, progress: progress)
        }
    }

    // MARK: - Hero Header

    private var petHeroHeader: some View {
        VStack(spacing: BZCLayout.spacingDefault) {
            HStack(alignment: .top, spacing: BZCLayout.spacingLarge) {
                petAvatar

                VStack(alignment: .leading, spacing: BZCLayout.spacingSmall) {
                    Text(pet.name)
                        .font(.title2.bold())
                        .foregroundStyle(BZCColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Label(pet.breed.isEmpty ? pet.species.rawValue : "\(pet.species.rawValue) · \(pet.breed)", systemImage: "pawprint.fill")
                        .font(.subheadline)
                        .foregroundStyle(BZCColors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    HStack(spacing: BZCLayout.spacingSmall) {
                        infoPill(pet.ageDescription, systemIcon: "calendar")
                        infoPill(String(format: "%.1f kg", pet.weightKg), systemIcon: "scalemass.fill")
                        infoPill(pet.gender.rawValue, systemIcon: "person.fill")
                    }
                }

                Spacer()

                BZCWellnessRingView(score: pet.wellnessScore, size: 70, lineWidth: 7)
            }

            Button(action: { showLogCare = true }) {
                Label("Log Care Activity", systemImage: "plus.circle.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(BZCColors.darkBackground)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(BZCColors.gradientGold, in: RoundedRectangle(cornerRadius: BZCLayout.cornerRadius))
            }
        }
        .padding(BZCLayout.cardPadding)
        .background(BZCColors.gradientPurple)
    }

    private var petAvatar: some View {
        Group {
            if let data = pet.photoData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(BZCColors.richGold.opacity(0.5), lineWidth: 2))
            } else {
                ZStack {
                    Circle()
                        .fill(pet.cardColor.opacity(0.4))
                        .frame(width: 80, height: 80)
                    Image(systemName: pet.species.symbolName)
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(pet.cardColor)
                }
            }
        }
    }

    private func infoPill(_ text: String, systemIcon: String) -> some View {
        Label(text, systemImage: systemIcon)
            .font(.caption.bold())
            .foregroundStyle(BZCColors.textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.12), in: Capsule())
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(BZCPetDetailTab.allCases, id: \.self) { tab in
                    Button(action: { withAnimation(BZCMotion.easeDefault) { selectedTab = tab } }) {
                        VStack(spacing: 4) {
                            Label(tab.title, systemImage: tab.icon)
                                .font(.caption.bold())
                                .foregroundStyle(selectedTab == tab ? BZCColors.richGold : BZCColors.textTertiary)
                                .labelStyle(.titleOnly)

                            Rectangle()
                                .fill(selectedTab == tab ? BZCColors.richGold : Color.clear)
                                .frame(height: 2)
                        }
                        .frame(height: 44)
                        .padding(.horizontal, BZCLayout.paddingDefault)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .background(BZCColors.cardBackground)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        ScrollView {
            LazyVStack(spacing: BZCLayout.spacingDefault) {
                switch selectedTab {
                case .care:
                    BZCCareLogTab(pet: pet, progress: progress, context: modelContext)
                case .health:
                    BZCHealthTab(pet: pet)
                case .reminders:
                    BZCRemindersTab(pet: pet)
                case .milestones:
                    BZCMilestonesTab(pet: pet)
                case .journal:
                    BZCJournalTab(pet: pet, progress: progress)
                }
            }
            .padding(BZCLayout.paddingDefault)
            .padding(.bottom, 80)
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - Tab Enum

enum BZCPetDetailTab: CaseIterable {
    case care, health, reminders, milestones, journal

    var title: String {
        switch self {
        case .care:       "Care Log"
        case .health:     "Health"
        case .reminders:  "Reminders"
        case .milestones: "Milestones"
        case .journal:    "Journal"
        }
    }

    var icon: String {
        switch self {
        case .care:       "checkmark.circle.fill"
        case .health:     "heart.fill"
        case .reminders:  "bell.fill"
        case .milestones: "star.fill"
        case .journal:    "book.fill"
        }
    }
}

// MARK: - Care Log Tab

struct BZCCareLogTab: View {
    let pet: BZCPet
    let progress: BZCGuardianProgress
    let context: ModelContext

    var body: some View {
        BZCGlassCard {
            VStack(alignment: .leading, spacing: BZCLayout.spacingSmall) {
                Label("Care Activities (\(pet.careActivities.count))", systemImage: "checkmark.circle.fill")
                    .font(.headline.bold())
                    .foregroundStyle(BZCColors.textPrimary)
                    .padding(.bottom, BZCLayout.spacingSmall)

                if pet.careActivities.isEmpty {
                    Text("No care activities yet. Tap 'Log Care Activity' to get started.")
                        .font(.subheadline)
                        .foregroundStyle(BZCColors.textTertiary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, BZCLayout.paddingLarge)
                } else {
                    ForEach(pet.careActivities.sorted(by: { $0.date > $1.date }).prefix(15), id: \.persistentModelID) { activity in
                        BZCCareActivityRow(activity: activity)
                    }
                }
            }
            .padding(BZCLayout.cardPadding)
        }
    }
}

struct BZCCareActivityRow: View {
    let activity: BZCCareActivity

    var body: some View {
        HStack(spacing: BZCLayout.spacingDefault) {
            Image(systemName: activity.type.systemIcon)
                .font(.body)
                .foregroundStyle(activity.type.guideMascot.accentColor)
                .frame(width: 32, height: 32)
                .background(activity.type.guideMascot.accentColor.opacity(0.15), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.type.rawValue)
                    .font(.subheadline.bold())
                    .foregroundStyle(BZCColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                if !activity.notes.isEmpty {
                    Text(activity.notes)
                        .font(.caption)
                        .foregroundStyle(BZCColors.textTertiary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(activity.date, format: .dateTime.day().month())
                .font(.caption)
                .foregroundStyle(BZCColors.textTertiary)
        }
        .padding(.vertical, BZCLayout.spacingSmall)
    }
}

// MARK: - Health Tab

struct BZCHealthTab: View {
    let pet: BZCPet

    var body: some View {
        VStack(spacing: BZCLayout.spacingDefault) {
            BZCGlassCard {
                VStack(alignment: .leading, spacing: BZCLayout.spacingSmall) {
                    Label("Vaccinations (\(pet.vaccinations.count))", systemImage: "syringe.fill")
                        .font(.headline.bold())
                        .foregroundStyle(BZCColors.textPrimary)

                    if pet.vaccinations.isEmpty {
                        Text("No vaccinations logged yet.")
                            .font(.subheadline)
                            .foregroundStyle(BZCColors.textTertiary)
                            .padding(.vertical, BZCLayout.paddingDefault)
                    } else {
                        ForEach(pet.vaccinations.sorted(by: { $0.dateGiven > $1.dateGiven }), id: \.persistentModelID) { vax in
                            BZCVaccinationRow(vaccination: vax)
                        }
                    }
                }
                .padding(BZCLayout.cardPadding)
            }

            BZCGlassCard {
                VStack(alignment: .leading, spacing: BZCLayout.spacingSmall) {
                    Label("Medications (\(pet.medications.filter(\.isActive).count) active)", systemImage: "pills.fill")
                        .font(.headline.bold())
                        .foregroundStyle(BZCColors.textPrimary)

                    if pet.medications.isEmpty {
                        Text("No medications recorded.")
                            .font(.subheadline)
                            .foregroundStyle(BZCColors.textTertiary)
                            .padding(.vertical, BZCLayout.paddingDefault)
                    } else {
                        ForEach(pet.medications, id: \.persistentModelID) { med in
                            BZCMedicationRow(medication: med)
                        }
                    }
                }
                .padding(BZCLayout.cardPadding)
            }
        }
    }
}

struct BZCVaccinationRow: View {
    let vaccination: BZCVaccination

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(vaccination.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(BZCColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(vaccination.dateGiven, format: .dateTime.day().month().year())
                    .font(.caption)
                    .foregroundStyle(BZCColors.textTertiary)
                    .lineLimit(1)
            }
            Spacer()
            if vaccination.isExpired {
                Label("Expired", systemImage: "exclamationmark.circle.fill")
                    .font(.caption.bold())
                    .foregroundStyle(BZCColors.errorRed)
            } else if vaccination.isExpiringSoon {
                Label("Soon", systemImage: "clock.badge.exclamationmark.fill")
                    .font(.caption.bold())
                    .foregroundStyle(BZCColors.richGold)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(BZCColors.emeraldGreen)
            }
        }
        .padding(.vertical, BZCLayout.spacingSmall)
    }
}

struct BZCMedicationRow: View {
    let medication: BZCMedication

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(medication.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(BZCColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("\(medication.dosage) · \(medication.frequency)")
                    .font(.caption)
                    .foregroundStyle(BZCColors.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Spacer()
            if medication.isActive {
                Text("Active")
                    .font(.caption.bold())
                    .foregroundStyle(BZCColors.emeraldGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(BZCColors.emeraldGreen.opacity(0.15), in: Capsule())
            }
        }
        .padding(.vertical, BZCLayout.spacingSmall)
    }
}

// MARK: - Reminders Tab

struct BZCRemindersTab: View {
    let pet: BZCPet

    var body: some View {
        BZCGlassCard {
            VStack(alignment: .leading, spacing: BZCLayout.spacingSmall) {
                Label("Reminders (\(pet.reminders.filter { !$0.isDone }.count) active)", systemImage: "bell.fill")
                    .font(.headline.bold())
                    .foregroundStyle(BZCColors.textPrimary)

                if pet.reminders.isEmpty {
                    Text("No reminders set. Add reminders for feeding, grooming, vet visits, and more.")
                        .font(.subheadline)
                        .foregroundStyle(BZCColors.textTertiary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, BZCLayout.paddingLarge)
                } else {
                    ForEach(
                        pet.reminders.sorted { $0.dueDate < $1.dueDate },
                        id: \.persistentModelID
                    ) { reminder in
                        BZCReminderRow(reminder: reminder)
                    }
                }
            }
            .padding(BZCLayout.cardPadding)
        }
    }
}

struct BZCReminderRow: View {
    @Bindable var reminder: BZCReminder

    var body: some View {
        HStack(spacing: BZCLayout.spacingDefault) {
            Button {
                withAnimation(BZCMotion.springBouncy) {
                    reminder.isDone.toggle()
                }
            } label: {
                Image(systemName: reminder.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(reminder.isDone ? BZCColors.emeraldGreen : BZCColors.textTertiary)
                    .font(.title3)
                    .frame(minWidth: BZCLayout.minTapTarget, minHeight: BZCLayout.minTapTarget)
            }
            .sensoryFeedback(.success, trigger: reminder.isDone)

            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(.subheadline)
                    .foregroundStyle(reminder.isDone ? BZCColors.textTertiary : BZCColors.textPrimary)
                    .strikethrough(reminder.isDone)

                Text(reminder.dueDate, format: .dateTime.day().month().hour().minute())
                    .font(.caption)
                    .foregroundStyle(reminder.isOverdue ? BZCColors.errorRed : BZCColors.textTertiary)
            }

            Spacer()

            if !reminder.isDone && reminder.repeatInterval != .none {
                Text(reminder.repeatInterval.rawValue)
                    .font(.caption2.bold())
                    .foregroundStyle(BZCColors.royalPurple)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(BZCColors.royalPurple.opacity(0.15), in: Capsule())
            }
        }
        .padding(.vertical, BZCLayout.spacingSmall)
    }
}

// MARK: - Milestones Tab

struct BZCMilestonesTab: View {
    let pet: BZCPet
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var showStore = false

    private static let premiumCategories: Set<BZCMilestoneCategory> = [.achievement, .training]
    private var hasGuardianPack: Bool { subscriptionManager.isPurchased(.guardianPack) }

    private var visibleMilestones: [BZCMilestone] {
        let sorted = pet.milestones.sorted { $0.date > $1.date }
        guard !hasGuardianPack else { return sorted }
        return sorted.filter { !Self.premiumCategories.contains($0.category) }
    }

    private var lockedMilestoneCount: Int {
        guard !hasGuardianPack else { return 0 }
        return pet.milestones.filter { Self.premiumCategories.contains($0.category) }.count
    }

    var body: some View {
        BZCGlassCard {
            VStack(alignment: .leading, spacing: BZCLayout.spacingSmall) {
                HStack {
                    Label("Milestones (\(pet.milestones.count))", systemImage: "star.fill")
                        .font(.headline.bold())
                        .foregroundStyle(BZCColors.textPrimary)
                    Spacer()
                    if !hasGuardianPack {
                        Label("Guardian Pack", systemImage: "lock.fill")
                            .font(.caption2.bold())
                            .foregroundStyle(BZCColors.richGold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(BZCColors.richGold.opacity(0.15), in: Capsule())
                    }
                }

                if pet.milestones.isEmpty {
                    Text("No milestones yet. Record your pet's special moments and achievements.")
                        .font(.subheadline)
                        .foregroundStyle(BZCColors.textTertiary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, BZCLayout.paddingLarge)
                } else {
                    ForEach(visibleMilestones, id: \.persistentModelID) { milestone in
                        HStack {
                            Image(systemName: milestone.category.symbolName)
                                .font(.subheadline.bold())
                                .foregroundStyle(BZCColors.richGold)
                                .frame(width: 32)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(milestone.title)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(BZCColors.textPrimary)
                                Text(milestone.date, format: .dateTime.day().month().year())
                                    .font(.caption)
                                    .foregroundStyle(BZCColors.textTertiary)
                            }
                            Spacer()
                            if milestone.isSpecial {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(BZCColors.richGold)
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, BZCLayout.spacingSmall)
                    }

                    if lockedMilestoneCount > 0 {
                        HStack(spacing: BZCLayout.spacingSmall) {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(BZCColors.richGold)
                            Text("\(lockedMilestoneCount) achievement \(lockedMilestoneCount == 1 ? "milestone" : "milestones") locked")
                                .font(.caption)
                                .foregroundStyle(BZCColors.textSecondary)
                            Spacer()
                            Button("Unlock") { showStore = true }
                                .font(.caption.bold())
                                .foregroundStyle(BZCColors.richGold)
                        }
                        .padding(BZCLayout.paddingSmall)
                        .background(BZCColors.richGold.opacity(0.08), in: RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusSmall))
                    }
                }

                if !hasGuardianPack {
                    Text("Achievement & Training milestones require the Zoo Guardian Pack.")
                        .font(.caption2)
                        .foregroundStyle(BZCColors.textTertiary)
                        .padding(.top, 2)
                }
            }
            .padding(BZCLayout.cardPadding)
        }
        .sheet(isPresented: $showStore) { BZCStoreView() }
    }
}

// MARK: - Journal Tab

struct BZCJournalTab: View {
    let pet: BZCPet
    let progress: BZCGuardianProgress
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var showStore = false

    private let freeEntryLimit = 3

    private var hasGuardianPack: Bool { subscriptionManager.isPurchased(.guardianPack) }

    private var sortedEntries: [BZCJournalEntry] {
        pet.journalEntries.sorted { $0.date > $1.date }
    }

    var body: some View {
        BZCGlassCard {
            VStack(alignment: .leading, spacing: BZCLayout.spacingSmall) {
                HStack {
                    Label("Journal (\(pet.journalEntries.count) entries)", systemImage: "book.fill")
                        .font(.headline.bold())
                        .foregroundStyle(BZCColors.textPrimary)
                    Spacer()
                    if !hasGuardianPack && pet.journalEntries.count > freeEntryLimit {
                        Label("Guardian Pack", systemImage: "lock.fill")
                            .font(.caption2.bold())
                            .foregroundStyle(BZCColors.richGold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(BZCColors.richGold.opacity(0.15), in: Capsule())
                    }
                }

                if sortedEntries.isEmpty {
                    Text("Start journaling your pet's daily life, observations, and behavioral changes.")
                        .font(.subheadline)
                        .foregroundStyle(BZCColors.textTertiary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, BZCLayout.paddingLarge)
                } else {
                    let visibleEntries = hasGuardianPack ? sortedEntries : Array(sortedEntries.prefix(freeEntryLimit))

                    ForEach(visibleEntries, id: \.persistentModelID) { entry in
                        journalEntryRow(entry)
                        if entry.persistentModelID != visibleEntries.last?.persistentModelID {
                            Divider().background(BZCColors.glassBorder)
                        }
                    }

                    // Guardian Pack lock gate
                    if !hasGuardianPack && sortedEntries.count > freeEntryLimit {
                        journalLockedOverlay(hiddenCount: sortedEntries.count - freeEntryLimit)
                    }
                }
            }
            .padding(BZCLayout.cardPadding)
        }
        .sheet(isPresented: $showStore) { BZCStoreView() }
    }

    private func journalEntryRow(_ entry: BZCJournalEntry) -> some View {
        HStack(alignment: .top, spacing: BZCLayout.spacingDefault) {
            Image(systemName: entry.mood.symbolName)
                .font(.subheadline.bold())
                .foregroundStyle(BZCColors.richGold)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    if !entry.title.isEmpty {
                        Text(entry.title)
                            .font(.subheadline.bold())
                            .foregroundStyle(BZCColors.textPrimary)
                    }
                    Spacer()
                    Text(entry.mood.rawValue)
                        .font(.caption2)
                        .foregroundStyle(BZCColors.textTertiary)
                }
                Text(entry.content)
                    .font(.caption)
                    .foregroundStyle(BZCColors.textSecondary)
                    .lineLimit(2)
                Text(entry.date, format: .dateTime.day().month().year())
                    .font(.caption2)
                    .foregroundStyle(BZCColors.textTertiary)
            }
        }
        .padding(.vertical, BZCLayout.spacingSmall)
    }

    private func journalLockedOverlay(hiddenCount: Int) -> some View {
        VStack(spacing: BZCLayout.spacingDefault) {
            Image(systemName: "lock.fill")
                .font(.title2)
                .foregroundStyle(BZCColors.richGold)
            Text("\(hiddenCount) more entr\(hiddenCount == 1 ? "y" : "ies") locked")
                .font(.subheadline.bold())
                .foregroundStyle(BZCColors.textPrimary)
            Text("Unlock unlimited journal entries, full mood history, and export with the Zoo Guardian Pack.")
                .font(.caption)
                .foregroundStyle(BZCColors.textSecondary)
                .multilineTextAlignment(.center)
            Button("Unlock Guardian Pack") { showStore = true }
                .font(.subheadline.bold())
                .foregroundStyle(BZCColors.darkBackground)
                .padding(.horizontal, BZCLayout.paddingLarge)
                .padding(.vertical, BZCLayout.paddingSmall)
                .background(BZCColors.gradientGold, in: Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(BZCLayout.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: BZCLayout.cornerRadius)
                .fill(BZCColors.richGold.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: BZCLayout.cornerRadius)
                        .strokeBorder(BZCColors.richGold.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                )
        )
        .padding(.top, BZCLayout.spacingSmall)
    }
}

// MARK: - Log Care Sheet

struct BZCLogCareSheet: View {
    @Bindable var pet: BZCPet
    let progress: BZCGuardianProgress

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var selectedType: BZCCareType = .feeding
    @State private var notes: String = ""
    @FocusState private var notesFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                BZCColors.gradientBackground.ignoresSafeArea()

                VStack(spacing: BZCLayout.spacingLarge) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: BZCLayout.spacingSmall) {
                        ForEach(BZCCareType.allCases, id: \.self) { type in
                            Button(action: { selectedType = type }) {
                                VStack(spacing: BZCLayout.spacingSmall) {
                                    Image(systemName: type.systemIcon)
                                        .font(.title3)
                                        .foregroundStyle(selectedType == type ? BZCColors.darkBackground : type.guideMascot.accentColor)
                                    Text(type.rawValue)
                                        .font(.caption2)
                                        .foregroundStyle(selectedType == type ? BZCColors.darkBackground : BZCColors.textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, BZCLayout.paddingSmall)
                                .background(
                                    RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusSmall)
                                        .fill(selectedType == type ? type.guideMascot.accentColor : BZCColors.glassBackground)
                                )
                            }
                            .sensoryFeedback(.selection, trigger: selectedType)
                        }
                    }
                    .padding(.horizontal, BZCLayout.paddingDefault)

                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .focused($notesFocused)
                        .lineLimit(3...)
                        .submitLabel(.done)
                        .onSubmit { notesFocused = false }
                        .foregroundStyle(BZCColors.textPrimary)
                        .padding(BZCLayout.paddingDefault)
                        .background(BZCColors.glassBackground, in: RoundedRectangle(cornerRadius: BZCLayout.cornerRadius))
                        .padding(.horizontal, BZCLayout.paddingDefault)

                    Button(action: save) {
                        Label("Log \(selectedType.rawValue)", systemImage: "checkmark.circle.fill")
                            .font(.headline.bold())
                            .foregroundStyle(BZCColors.darkBackground)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(BZCColors.gradientGold, in: RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge))
                    }
                    .padding(.horizontal, BZCLayout.paddingLarge)
                    .sensoryFeedback(.success, trigger: false)

                    Spacer()
                }
                .padding(.top, BZCLayout.paddingLarge)
            }
            .navigationTitle("Log Care Activity")
            .navigationBarTitleDisplayMode(.inline)
            .contentShape(Rectangle())
            .onTapGesture { notesFocused = false }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(BZCColors.textSecondary)
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") { notesFocused = false }
                            .font(.subheadline.bold())
                            .foregroundStyle(BZCColors.richGold)
                    }
                }
            }
        }
    }

    private func save() {
        let activity = BZCCareActivity(type: selectedType, notes: notes)
        pet.careActivities.append(activity)
        progress.recordCareActivity()
        dismiss()
    }
}
