import SwiftUI
import SwiftData

struct BZCHomeView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(BZCGuardianProgress.self) private var progress
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BZCPet.name) private var pets: [BZCPet]

    @Environment(BZCAppNavigation.self) private var appNav

    @State private var showStore = false
    @State private var selectedPet: BZCPet?
    @State private var quickLogPetIndex: Int = 0
    @State private var lastLoggedType: BZCCareType?

    private var activePets: [BZCPet] { pets.filter { !$0.isArchived } }

    private var quickLogPet: BZCPet? {
        guard !activePets.isEmpty else { return nil }
        return activePets[min(quickLogPetIndex, activePets.count - 1)]
    }

    private var todaysReminders: [(BZCPet, BZCReminder)] {
        let endOfTomorrow = Calendar.current.startOfDay(for: .now).addingTimeInterval(2 * 86400)
        var result: [(BZCPet, BZCReminder)] = []
        for pet in activePets {
            for r in pet.reminders where !r.isDone && r.dueDate < endOfTomorrow {
                result.append((pet, r))
            }
        }
        return result.sorted { $0.1.dueDate < $1.1.dueDate }.prefix(5).map { $0 }
    }

    private var recentActivities: [(BZCPet, BZCCareActivity)] {
        var result: [(BZCPet, BZCCareActivity)] = []
        for pet in activePets { for a in pet.careActivities { result.append((pet, a)) } }
        return result.sorted { $0.1.date > $1.1.date }.prefix(8).map { $0 }
    }

    private var expiringVaccinations: [(BZCPet, BZCVaccination)] {
        var result: [(BZCPet, BZCVaccination)] = []
        for pet in activePets {
            for v in pet.vaccinations where v.isExpiringSoon || v.isExpired { result.append((pet, v)) }
        }
        return result
    }

    private var weeklyActivity: [(date: Date, count: Int)] {
        let cal = Calendar.current
        return (0..<7).reversed().map { daysAgo in
            let date = cal.date(byAdding: .day, value: -daysAgo, to: cal.startOfDay(for: .now))!
            let count = activePets.reduce(0) { $0 + $1.careActivities.filter { cal.isDate($0.date, inSameDayAs: date) }.count }
            return (date: date, count: count)
        }
    }

    private var topCareTypeThisWeek: BZCCareType? {
        let weekStart = Calendar.current.date(byAdding: .day, value: -7, to: .now)!
        var counts: [BZCCareType: Int] = [:]
        for pet in activePets {
            for activity in pet.careActivities where activity.date > weekStart {
                counts[activity.type, default: 0] += 1
            }
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BZCColors.gradientBackground.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: BZCLayout.spacingLarge) {
                        headerSection
                        weeklyOverviewSection
                        if !activePets.isEmpty { wellnessSummarySection }
                        quickCareSection
                        aiMentorPreviewSection
                        todaysScheduleSection
                        if !activePets.isEmpty { petsQuickAccessSection } else { emptyPetsSection }
                        recentActivitySection
                        if !expiringVaccinations.isEmpty { healthAlertsSection }
                        guardianProgressSection
                        if !activePets.isEmpty { insightsSection }
                        mascotGridSection
                    }
                    .padding(BZCLayout.paddingDefault)
                    .padding(.bottom, 80)
                }
                .scrollIndicators(.hidden)
            }
            .navigationDestination(item: $selectedPet) { pet in
                BZCPetDetailView(pet: pet)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "pawprint.fill")
                            .font(.caption.bold())
                            .foregroundStyle(BZCColors.richGold)
                        Text("Be Zoo Care")
                            .font(.headline.bold())
                            .foregroundStyle(BZCColors.richGold)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Be Zoo Care")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    let allPurchased = subscriptionManager.isPurchased(.expertPack)
                        && subscriptionManager.isPurchased(.guardianPack)
                    Button("Store", systemImage: "crown.fill") { showStore = true }
                        .symbolRenderingMode(.hierarchical)
                        .tint(BZCColors.richGold)
                        .opacity(allPurchased ? 0 : 1)
                        .frame(minWidth: BZCLayout.minTapTarget, minHeight: BZCLayout.minTapTarget)
                }
            }
        }
        .sheet(isPresented: $showStore) { BZCStoreView() }
    }

    // MARK: - Sections

    private var headerSection: some View {
        BZCHomeHeaderView(
            petCount: activePets.count,
            tier: progress.currentTier,
            careStreak: progress.careStreakDays,
            totalPoints: progress.totalPoints
        )
    }

    private var weeklyOverviewSection: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            HStack {
                Label("7-Day Activity", systemImage: "chart.bar.fill")
                    .font(.headline.bold())
                    .foregroundStyle(BZCColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
                let total = weeklyActivity.reduce(0) { $0 + $1.count }
                Text("\(total) logged this week")
                    .font(.caption)
                    .foregroundStyle(BZCColors.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            BZCWeeklyBarChart(days: weeklyActivity)
        }
        .padding(BZCLayout.cardPadding)
        .background(glassCard())
    }

    private var wellnessSummarySection: some View {
        BZCWellnessSummaryCard(pets: activePets)
    }

    private var quickCareSection: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            HStack {
                Label("Quick Care Log", systemImage: "bolt.fill")
                    .font(.headline.bold())
                    .foregroundStyle(BZCColors.textPrimary)
                Spacer()
                let todayTotal = quickLogPet?.careActivities
                    .filter { Calendar.current.isDateInToday($0.date) }.count ?? 0
                if todayTotal > 0 {
                    Label("\(todayTotal) today", systemImage: "checkmark.circle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(BZCColors.emeraldGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(BZCColors.emeraldGreen.opacity(0.12), in: Capsule())
                }
            }

            // Pet chip switcher
            if activePets.count > 1 {
                ScrollView(.horizontal) {
                    HStack(spacing: BZCLayout.spacingSmall) {
                        ForEach(activePets.indices, id: \.self) { i in
                            Button {
                                withAnimation(BZCMotion.springDefault) { quickLogPetIndex = i }
                            } label: {
                                Text(activePets[i].name)
                                    .font(.caption.bold())
                                    .foregroundStyle(quickLogPetIndex == i ? BZCColors.darkBackground : BZCColors.textSecondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        quickLogPetIndex == i
                                            ? AnyShapeStyle(BZCColors.gradientGold)
                                            : AnyShapeStyle(BZCColors.glassBackground),
                                        in: Capsule()
                                    )
                            }
                            .buttonStyle(.plain)
                            .sensoryFeedback(.selection, trigger: quickLogPetIndex)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            } else if let pet = quickLogPet {
                Label(pet.name, systemImage: pet.species.symbolName)
                    .font(.caption.bold())
                    .foregroundStyle(BZCColors.textSecondary)
            }

            let quickTypes: [BZCCareType] = [
                .feeding, .water, .exercise, .grooming,
                .playtime, .training, .brushing, .enrichment
            ]
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: BZCLayout.spacingSmall), count: 4),
                spacing: BZCLayout.spacingSmall
            ) {
                ForEach(quickTypes, id: \.self) { type in
                    BZCQuickCareButton(
                        type: type,
                        isEnabled: quickLogPet != nil,
                        todayCount: quickLogPet?.careActivities
                            .filter { $0.type == type && Calendar.current.isDateInToday($0.date) }.count ?? 0
                    ) {
                        if let pet = quickLogPet {
                            pet.careActivities.append(BZCCareActivity(type: type))
                            progress.recordCareActivity()
                            lastLoggedType = type
                        }
                    }
                }
            }

            if let last = lastLoggedType {
                HStack(spacing: BZCLayout.spacingSmall) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(BZCColors.emeraldGreen)
                        .font(.caption)
                    Text("\(last.rawValue) logged for \(quickLogPet?.name ?? "your pet")")
                        .font(.caption)
                        .foregroundStyle(BZCColors.textSecondary)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if activePets.isEmpty {
                BZCEmptyStateRow(
                    icon: "pawprint.fill",
                    iconColor: BZCColors.textTertiary,
                    title: "No pets yet",
                    subtitle: "Add a pet in the Pets tab to start logging care"
                )
            }
        }
        .padding(BZCLayout.cardPadding)
        .background(glassCard())
        .animation(BZCMotion.springDefault, value: lastLoggedType?.rawValue)
        .sensoryFeedback(.impact(weight: .light), trigger: lastLoggedType)
    }

    private var aiMentorPreviewSection: some View {
        BZCHomeAIMentorCard { appNav.selectedTab = .aiMentor }
    }

    private var todaysScheduleSection: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            HStack {
                Label("Today's Schedule", systemImage: "calendar.badge.clock")
                    .font(.headline.bold())
                    .foregroundStyle(BZCColors.textPrimary)
                Spacer()
                if !todaysReminders.isEmpty {
                    Text("\(todaysReminders.count) upcoming")
                        .font(.caption)
                        .foregroundStyle(BZCColors.textTertiary)
                        .lineLimit(1)
                }
            }

            if todaysReminders.isEmpty {
                BZCEmptyStateRow(
                    icon: "checkmark.seal.fill",
                    iconColor: BZCColors.emeraldGreen,
                    title: "All clear for today",
                    subtitle: "Add reminders in a pet's profile to see upcoming tasks here"
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(todaysReminders.enumerated()), id: \.offset) { index, pair in
                        Button { selectedPet = pair.0 } label: {
                            BZCScheduleRow(pet: pair.0, reminder: pair.1)
                        }
                        .buttonStyle(.plain)
                        if index < todaysReminders.count - 1 {
                            Divider().background(BZCColors.glassBorder)
                        }
                    }
                }
            }
        }
        .padding(BZCLayout.cardPadding)
        .background(glassCard())
    }

    private var petsQuickAccessSection: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            HStack {
                sectionHeader("Your Pets", icon: "pawprint.fill")
                Spacer()
                Button("See All") { appNav.selectedTab = .pets }
                    .font(.caption.bold())
                    .foregroundStyle(BZCColors.richGold)
            }
            ScrollView(.horizontal) {
                LazyHStack(spacing: BZCLayout.spacingDefault) {
                    ForEach(activePets.prefix(6)) { pet in
                        Button { selectedPet = pet } label: {
                            BZCPetCardView(pet: pet).frame(width: 220)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, BZCLayout.paddingDefault)
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal, -BZCLayout.paddingDefault)
        }
    }

    private var emptyPetsSection: some View {
        Button { appNav.selectedTab = .pets } label: {
            VStack(spacing: BZCLayout.spacingDefault) {
                Image(systemName: "plus.circle.dashed")
                    .font(.system(size: 40))
                    .foregroundStyle(BZCColors.richGold)
                Text("Add Your First Pet")
                    .font(.headline.bold())
                    .foregroundStyle(BZCColors.textPrimary)
                Text("Tap here to open the Pets tab and add your first animal companion.")
                    .font(.subheadline)
                    .foregroundStyle(BZCColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                Label("Go to Pets", systemImage: "arrow.right.circle.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(BZCColors.darkBackground)
                    .padding(.horizontal, BZCLayout.paddingDefault)
                    .padding(.vertical, 10)
                    .background(BZCColors.gradientGold, in: Capsule())
            }
            .padding(BZCLayout.cardPadding)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                    .fill(BZCColors.glassBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                            .strokeBorder(BZCColors.richGold.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            HStack {
                Label("Recent Activity", systemImage: "clock.fill")
                    .font(.headline.bold())
                    .foregroundStyle(BZCColors.textPrimary)
                Spacer()
                if !recentActivities.isEmpty {
                    Text("\(recentActivities.count) shown")
                        .font(.caption)
                        .foregroundStyle(BZCColors.textTertiary)
                        .lineLimit(1)
                }
            }

            if recentActivities.isEmpty {
                BZCEmptyStateRow(
                    icon: "clock.badge.questionmark",
                    iconColor: BZCColors.textTertiary,
                    title: "No activities yet",
                    subtitle: "Use Quick Care above to start logging. Every tap earns Guardian Points"
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(recentActivities.enumerated()), id: \.offset) { index, pair in
                        Button { selectedPet = pair.0 } label: {
                            BZCActivityFeedRow(pet: pair.0, activity: pair.1)
                        }
                        .buttonStyle(.plain)
                        if index < recentActivities.count - 1 {
                            Divider().background(BZCColors.glassBorder)
                        }
                    }
                }
            }
        }
        .padding(BZCLayout.cardPadding)
        .background(glassCard())
    }

    private var healthAlertsSection: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            HStack {
                Label("Health Alerts", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline.bold())
                    .foregroundStyle(BZCColors.richGold)
                Spacer()
                Text("\(expiringVaccinations.count) item\(expiringVaccinations.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(BZCColors.textTertiary)
            }

            VStack(spacing: 0) {
                ForEach(Array(expiringVaccinations.prefix(3).enumerated()), id: \.offset) { index, pair in
                    Button { selectedPet = pair.0 } label: {
                        HStack(spacing: BZCLayout.spacingDefault) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(pair.1.isExpired ? BZCColors.errorRed : BZCColors.richGold)
                                .frame(width: 4, height: 44)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(pair.1.name)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(BZCColors.textPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                                Text(pair.0.name)
                                    .font(.caption)
                                    .foregroundStyle(BZCColors.textSecondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(pair.1.isExpired ? "Expired" : "Expiring")
                                    .font(.caption2.bold())
                                    .foregroundStyle(pair.1.isExpired ? BZCColors.errorRed : BZCColors.richGold)
                                if let expires = pair.1.expiresAt {
                                    Text(expires, format: .dateTime.day().month().year())
                                        .font(.caption2)
                                        .foregroundStyle(BZCColors.textTertiary)
                                }
                            }

                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(BZCColors.textTertiary)
                        }
                        .padding(.vertical, BZCLayout.spacingSmall)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < min(3, expiringVaccinations.count) - 1 {
                        Divider().background(BZCColors.glassBorder)
                    }
                }
            }
        }
        .padding(BZCLayout.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                .fill(BZCColors.richGold.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                        .strokeBorder(BZCColors.richGold.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var guardianProgressSection: some View {
        Button { appNav.selectedTab = .dashboard } label: {
            BZCGuardianProgressCard(progress: progress)
        }
        .buttonStyle(.plain)
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            sectionHeader("Care Insights", icon: "lightbulb.fill")
            HStack(spacing: BZCLayout.spacingDefault) {
                if let top = topCareTypeThisWeek {
                    BZCInsightTile(
                        icon: top.systemIcon,
                        iconColor: top.guideMascot.accentColor,
                        label: "Most Logged",
                        value: top.rawValue
                    )
                }
                BZCInsightTile(
                    icon: "figure.2.arms.open",
                    iconColor: BZCColors.royalPurple,
                    label: "All Time",
                    value: "\(progress.totalCareActivities) care logs"
                )
            }
            HStack(spacing: BZCLayout.spacingDefault) {
                BZCInsightTile(
                    icon: "pawprint.fill",
                    iconColor: BZCColors.emeraldGreen,
                    label: "In Your Care",
                    value: "\(activePets.count) pet\(activePets.count == 1 ? "" : "s")"
                )
                BZCInsightTile(
                    icon: "book.fill",
                    iconColor: Color(red: 0.35, green: 0.55, blue: 0.95),
                    label: "Articles Read",
                    value: "\(progress.articlesRead.count)"
                )
            }
        }
    }

    private var mascotGridSection: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            HStack {
                sectionHeader("Your Care Guides", icon: "person.3.fill")
                Spacer()
                Button("Learn More") { appNav.selectedTab = .education }
                    .font(.caption.bold())
                    .foregroundStyle(BZCColors.richGold)
            }
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: BZCLayout.spacingDefault), count: 5),
                spacing: BZCLayout.spacingDefault
            ) {
                ForEach(BZCMascot.allCases) { mascot in
                    Button { appNav.selectedTab = .education } label: {
                        BZCMascotView(mascot: mascot, size: 56, showName: true, isCompact: true)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.headline.bold())
            .foregroundStyle(BZCColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func glassCard() -> some View {
        RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
            .fill(BZCColors.glassBackground)
            .overlay(
                RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                    .strokeBorder(BZCColors.glassBorder, lineWidth: 1)
            )
    }
}

// MARK: - Header View

struct BZCHomeHeaderView: View {
    let petCount: Int
    let tier: BZCGuardianTier
    let careStreak: Int
    let totalPoints: Int

    var body: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Date.now, format: .dateTime.weekday(.wide).day().month())
                        .font(.caption)
                        .foregroundStyle(BZCColors.textTertiary)
                    Text(tier.displayName)
                        .font(.title2.bold())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [BZCColors.warmGold, BZCColors.richGold],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(tier.accentColor.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Circle()
                        .strokeBorder(
                            AngularGradient(
                                colors: [tier.accentColor, tier.accentColor.opacity(0.3), tier.accentColor],
                                center: .center
                            ),
                            lineWidth: 2.5
                        )
                        .frame(width: 56, height: 56)
                    Image(systemName: tier.symbolName)
                        .font(.title3)
                        .foregroundStyle(tier.accentColor)
                }
            }

            HStack(spacing: BZCLayout.spacingSmall) {
                statChip(icon: "pawprint.fill", value: "\(petCount)", label: petCount == 1 ? "Pet" : "Pets", color: BZCColors.royalPurple)
                statChip(icon: "flame.fill", value: "\(careStreak)d", label: "Streak", color: BZCColors.warmGold)
                statChip(icon: "hexagon.fill", value: "\(totalPoints)", label: "pts", color: BZCColors.richGold)
            }
        }
        .padding(BZCLayout.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                .fill(BZCColors.gradientPurple)
                .overlay(
                    RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                        .strokeBorder(BZCColors.richGold.opacity(0.3), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Guardian tier: \(tier.displayName). \(petCount) pets. \(careStreak) day streak. \(totalPoints) points.")
    }

    private func statChip(icon: String, value: String, label: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
            Text(value)
                .font(.caption.bold())
                .foregroundStyle(BZCColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(label)
                .font(.caption2)
                .foregroundStyle(BZCColors.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(BZCColors.glassBackground, in: Capsule())
    }
}

// MARK: - Weekly Bar Chart

struct BZCWeeklyBarChart: View {
    let days: [(date: Date, count: Int)]

    private var maxCount: Int { max(days.map(\.count).max() ?? 1, 1) }

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(days.indices, id: \.self) { i in
                let day = days[i]
                let isToday = Calendar.current.isDateInToday(day.date)
                let barH = day.count > 0
                    ? max(CGFloat(day.count) / CGFloat(maxCount) * 64, 8)
                    : 3

                VStack(spacing: 4) {
                    if day.count > 0 {
                        Text("\(day.count)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(isToday ? BZCColors.richGold : BZCColors.textTertiary)
                    } else {
                        Color.clear.frame(height: 12)
                    }

                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            isToday
                                ? AnyShapeStyle(BZCColors.gradientGold)
                                : AnyShapeStyle(BZCColors.royalPurple.opacity(day.count > 0 ? 0.55 : 0.2))
                        )
                        .frame(height: barH)
                        .animation(BZCMotion.springDefault, value: day.count)

                    Text(day.date, format: .dateTime.weekday(.narrow))
                        .font(.system(size: 10))
                        .foregroundStyle(isToday ? BZCColors.richGold : BZCColors.textTertiary)
                        .fontWeight(isToday ? .bold : .regular)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 88)
    }
}

// MARK: - Quick Care Button

struct BZCQuickCareButton: View {
    let type: BZCCareType
    let isEnabled: Bool
    let todayCount: Int
    var onTap: () -> Void

    @State private var pressed = false

    var body: some View {
        Button {
            guard isEnabled else { return }
            withAnimation(BZCMotion.springBouncy) { pressed = true }
            Task {
                try? await Task.sleep(for: .milliseconds(120))
                withAnimation(BZCMotion.springDefault) { pressed = false }
            }
            onTap()
        } label: {
            VStack(spacing: 5) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: type.systemIcon)
                        .font(.title3)
                        .foregroundStyle(isEnabled ? type.guideMascot.accentColor : BZCColors.textTertiary)
                        .frame(width: 44, height: 44)
                        .background(
                            (isEnabled ? type.guideMascot.accentColor : BZCColors.glassBackground)
                                .opacity(isEnabled ? 0.18 : 1),
                            in: RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusSmall)
                        )

                    if todayCount > 0 {
                        Text("\(todayCount)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 16, height: 16)
                            .background(BZCColors.emeraldGreen, in: Circle())
                            .offset(x: 6, y: -6)
                    }
                }

                Text(type.rawValue.split(separator: " ").first.map(String.init) ?? type.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(isEnabled ? BZCColors.textSecondary : BZCColors.textTertiary)
                    .lineLimit(1)
            }
            .scaleEffect(pressed ? 0.86 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(
            "Log \(type.rawValue)\(todayCount > 0 ? ", \(todayCount) time\(todayCount == 1 ? "" : "s") today" : "")"
        )
    }
}

// MARK: - Schedule Row

struct BZCScheduleRow: View {
    let pet: BZCPet
    let reminder: BZCReminder

    var body: some View {
        HStack(spacing: BZCLayout.spacingDefault) {
            Image(systemName: reminder.careType.systemIcon)
                .font(.body)
                .foregroundStyle(reminder.careType.guideMascot.accentColor)
                .frame(width: 32, height: 32)
                .background(reminder.careType.guideMascot.accentColor.opacity(0.15), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(BZCColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(pet.name)
                    .font(.caption)
                    .foregroundStyle(BZCColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(reminder.dueDate, format: .dateTime.hour().minute())
                    .font(.caption.bold())
                    .foregroundStyle(reminder.isOverdue ? BZCColors.errorRed : BZCColors.textPrimary)
                Group {
                    if Calendar.current.isDateInToday(reminder.dueDate) {
                        Text("Today")
                    } else {
                        Text(reminder.dueDate, format: .dateTime.day().month())
                    }
                }
                .font(.caption2)
                .foregroundStyle(BZCColors.textTertiary)
            }

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(BZCColors.textTertiary)
        }
        .padding(.vertical, BZCLayout.spacingSmall)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(reminder.title) for \(pet.name)\(reminder.isOverdue ? ", overdue" : "")")
    }
}

// MARK: - Activity Feed Row

struct BZCActivityFeedRow: View {
    let pet: BZCPet
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
                Text(pet.name)
                    .font(.caption)
                    .foregroundStyle(BZCColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(activity.date, format: .relative(presentation: .named))
                .font(.caption)
                .foregroundStyle(BZCColors.textTertiary)

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(BZCColors.textTertiary)
        }
        .padding(.vertical, BZCLayout.spacingSmall)
        .contentShape(Rectangle())
    }
}

// MARK: - Empty State Row

struct BZCEmptyStateRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: BZCLayout.spacingDefault) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 44, height: 44)
                .background(iconColor.opacity(0.12), in: RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusSmall))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(BZCColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(BZCColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }

            Spacer()
        }
        .padding(.vertical, BZCLayout.spacingSmall)
    }
}

// MARK: - Wellness Summary Card

struct BZCWellnessSummaryCard: View {
    let pets: [BZCPet]

    private var averageWellness: Double {
        guard !pets.isEmpty else { return 0 }
        return pets.map(\.wellnessScore).reduce(0, +) / Double(pets.count)
    }

    private var totalCareToday: Int {
        pets.reduce(0) { $0 + $1.todaysCareCount }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            HStack(spacing: BZCLayout.spacingLarge) {
                BZCWellnessRingView(score: averageWellness, size: 72)

                VStack(alignment: .leading, spacing: BZCLayout.spacingSmall) {
                    Text("Wellness Overview")
                        .font(.headline.bold())
                        .foregroundStyle(BZCColors.textPrimary)

                    Label(
                        "\(totalCareToday) \(totalCareToday == 1 ? "activity" : "activities") today",
                        systemImage: "checkmark.circle.fill"
                    )
                    .font(.subheadline)
                    .foregroundStyle(BZCColors.emeraldGreen)

                    Label(
                        "\(Int(averageWellness * 100))% average wellness",
                        systemImage: "waveform.path.ecg"
                    )
                    .font(.caption)
                    .foregroundStyle(BZCColors.textSecondary)
                }

                Spacer()
            }

            if pets.count > 1 {
                Divider().background(BZCColors.glassBorder)

                VStack(spacing: BZCLayout.spacingSmall) {
                    ForEach(pets.prefix(3)) { pet in
                        HStack(spacing: BZCLayout.spacingDefault) {
                            Text(pet.name)
                                .font(.caption.bold())
                                .foregroundStyle(BZCColors.textSecondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                                .frame(width: 64, alignment: .leading)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(BZCColors.glassBackground).frame(height: 6)
                                    Capsule()
                                        .fill(wellnessColor(for: pet.wellnessScore))
                                        .frame(width: geo.size.width * pet.wellnessScore, height: 6)
                                        .animation(BZCMotion.springDefault, value: pet.wellnessScore)
                                }
                            }
                            .frame(height: 6)

                            Text("\(Int(pet.wellnessScore * 100))%")
                                .font(.caption2.bold())
                                .foregroundStyle(BZCColors.textTertiary)
                                .frame(width: 34, alignment: .trailing)
                        }
                    }
                }
            }
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

    private func wellnessColor(for score: Double) -> Color {
        if score >= 0.7 { return BZCColors.emeraldGreen }
        if score >= 0.4 { return BZCColors.richGold }
        return BZCColors.errorRed
    }
}

// MARK: - AI Mentor Preview Card

struct BZCHomeAIMentorCard: View {
    var onTap: () -> Void

    @State private var isGlowing = false
    @State private var visiblePromptIndex = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let promptExamples = [
        "How often should I groom my dog?",
        "Why does my cat knock things over?",
        "How much water should my rabbit drink?",
        "How do I train my bird to talk?",
        "What signs show my pet is stressed?",
        "How do I introduce a new pet?"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            HStack {
                BZCMascotView(mascot: .fox, size: 48, showName: false, isAnimated: true)

                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Animal Mentor")
                        .font(.headline.bold())
                        .foregroundStyle(BZCColors.textPrimary)
                    Label("100% offline · On-device AI", systemImage: "lock.shield.fill")
                        .font(.caption)
                        .foregroundStyle(BZCColors.emeraldGreen)
                }

                Spacer()

                Image(systemName: "chevron.right.circle.fill")
                    .foregroundStyle(BZCColors.richGold)
                    .font(.title3)
            }

            Text("\"\(promptExamples[visiblePromptIndex])\"")
                .font(.subheadline.italic())
                .foregroundStyle(BZCColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .animation(BZCMotion.easeDefault, value: visiblePromptIndex)
                .accessibilityLabel("Example question: \(promptExamples[visiblePromptIndex])")

            HStack {
                Spacer()
                Button(action: onTap) {
                    Label("Ask a question", systemImage: "mic.fill")
                        .font(.caption.bold())
                        .foregroundStyle(BZCColors.darkBackground)
                        .padding(.horizontal, BZCLayout.paddingDefault)
                        .padding(.vertical, BZCLayout.paddingSmall)
                        .background(BZCColors.gradientGold, in: Capsule())
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(BZCLayout.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.95, green: 0.45, blue: 0.18).opacity(0.12), BZCColors.glassBackground],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                        .strokeBorder(Color(red: 0.95, green: 0.45, blue: 0.18).opacity(isGlowing ? 0.5 : 0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color(red: 0.95, green: 0.45, blue: 0.18).opacity(isGlowing ? 0.15 : 0), radius: 12)
        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isGlowing)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .onAppear { guard !reduceMotion else { return }; isGlowing = true }
        .task {
            guard !reduceMotion else { return }
            repeat {
                do { try await Task.sleep(for: .seconds(3)) } catch { return }
                withAnimation(BZCMotion.easeDefault) {
                    visiblePromptIndex = (visiblePromptIndex + 1) % promptExamples.count
                }
            } while true
        }
    }
}

// MARK: - Guardian Progress Card

struct BZCGuardianProgressCard: View {
    let progress: BZCGuardianProgress

    var body: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            HStack {
                Label("Zoo Guardian Journey", systemImage: "crown.fill")
                    .font(.headline.bold())
                    .foregroundStyle(BZCColors.richGold)
                Spacer()
                Text("\(progress.totalPoints) pts")
                    .font(.caption.bold())
                    .foregroundStyle(BZCColors.textSecondary)
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(BZCColors.textTertiary)
            }

            HStack(spacing: BZCLayout.spacingDefault) {
                ZStack {
                    Circle()
                        .fill(progress.currentTier.accentColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: progress.currentTier.symbolName)
                        .font(.body)
                        .foregroundStyle(progress.currentTier.accentColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(progress.currentTier.displayName)
                        .font(.subheadline.bold())
                        .foregroundStyle(BZCColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    if let next = progress.nextTier {
                        Text("\(progress.pointsToNextTier) pts to \(next.displayName)")
                            .font(.caption)
                            .foregroundStyle(BZCColors.textTertiary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    } else {
                        Text("Maximum tier reached")
                            .font(.caption)
                            .foregroundStyle(BZCColors.emeraldGreen)
                            .lineLimit(1)
                    }
                }

                Spacer()

                HStack(spacing: 4) {
                    ForEach(BZCGuardianTier.allCases, id: \.self) { tier in
                        Circle()
                            .fill(progress.currentTier.rawValue >= tier.rawValue
                                  ? AnyShapeStyle(tier.accentColor)
                                  : AnyShapeStyle(BZCColors.glassBackground))
                            .frame(width: 8, height: 8)
                            .overlay(Circle().strokeBorder(BZCColors.glassBorder, lineWidth: 0.5))
                    }
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(BZCColors.glassBackground).frame(height: 8)
                    Capsule()
                        .fill(BZCColors.gradientGold)
                        .frame(width: geometry.size.width * progress.progressToNextTier, height: 8)
                        .animation(BZCMotion.springDefault, value: progress.progressToNextTier)
                }
            }
            .frame(height: 8)

            HStack {
                Label(
                    "\(progress.unlockedAchievements.count) / \(BZCAchievement.allAchievements.count) achievements",
                    systemImage: "trophy.fill"
                )
                .font(.caption)
                .foregroundStyle(BZCColors.richGold)
                Spacer()
                if progress.careStreakDays > 0 {
                    Label("\(progress.careStreakDays)d streak", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(BZCColors.warmGold)
                }
            }

            if !progress.unlockedAchievements.isEmpty {
                Divider().background(BZCColors.glassBorder)

                ScrollView(.horizontal) {
                    HStack(spacing: BZCLayout.spacingSmall) {
                        ForEach(progress.unlockedAchievements.prefix(8), id: \.id) { achievement in
                            VStack(spacing: 3) {
                                Image(systemName: achievement.category.symbolName)
                                    .font(.caption)
                                    .foregroundStyle(BZCColors.richGold)
                                    .frame(width: 32, height: 32)
                                    .background(BZCColors.richGold.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                                Text(achievement.title)
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundStyle(BZCColors.textTertiary)
                                    .lineLimit(1)
                                    .frame(width: 44)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .padding(BZCLayout.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                .fill(BZCColors.glassBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                        .strokeBorder(BZCColors.richGold.opacity(0.25), lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Insight Tile

struct BZCInsightTile: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingSmall) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(iconColor)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.12), in: RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusSmall))

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(BZCColors.textTertiary)
                Text(value)
                    .font(.subheadline.bold())
                    .foregroundStyle(BZCColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(BZCLayout.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: BZCLayout.cornerRadius)
                .fill(BZCColors.glassBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: BZCLayout.cornerRadius)
                        .strokeBorder(BZCColors.glassBorder, lineWidth: 1)
                )
        )
    }
}

// MARK: - ViewModel stub

@Observable
final class BZCHomeViewModel {
    // Lightweight view state — all data flows from SwiftData @Query
}

#Preview {
    BZCHomeView()
        .modelContainer(for: [BZCPet.self], inMemory: true)
        .environment(SubscriptionManager())
        .environment(BZCGuardianProgress())
        .environment(BZCAppNavigation())
}
