import SwiftUI
import SwiftData
import Charts

struct BZCDashboardView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(BZCGuardianProgress.self) private var progress
    @Query(sort: \BZCPet.name) private var pets: [BZCPet]

    @State private var viewModel = BZCDashboardViewModel()
    @State private var showStore = false
    @State private var selectedPet: BZCPet?

    private var activePets: [BZCPet] { pets.filter { !$0.isArchived } }

    var body: some View {
        NavigationStack {
            ZStack {
                BZCColors.gradientBackground.ignoresSafeArea()

                Group {
                    if activePets.isEmpty {
                        emptyState
                    } else {
                        dashboardContent
                    }
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !subscriptionManager.isPurchased(.expertPack) {
                        Button("Expert Pack", systemImage: "crown.fill") { showStore = true }
                            .tint(BZCColors.richGold)
                    }
                }
            }
        }
        .sheet(isPresented: $showStore) { BZCStoreView() }
    }

    // MARK: - Content

    private var dashboardContent: some View {
        ScrollView {
            LazyVStack(spacing: BZCLayout.spacingLarge) {
                overviewCards
                wellnessTrendChart
                achievementsSection
                guardianJourneySection
                upcomingRemindersSection
            }
            .padding(BZCLayout.paddingDefault)
            .padding(.bottom, 80)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Overview Cards

    private var overviewCards: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: BZCLayout.spacingDefault
        ) {
            BZCStatCard(
                title: "Avg Wellness",
                value: "\(Int(viewModel.overallWellness(for: activePets) * 100))%",
                icon: "heart.fill",
                color: BZCColors.emeraldGreen
            )
            BZCStatCard(
                title: "Care Today",
                value: "\(viewModel.totalActivitiesToday(for: activePets))",
                icon: "checkmark.circle.fill",
                color: BZCColors.royalPurple
            )
            BZCStatCard(
                title: "Care Streak",
                value: "\(progress.careStreakDays)d",
                icon: "flame.fill",
                color: BZCColors.richGold
            )
            BZCStatCard(
                title: "Guardian Pts",
                value: "\(progress.totalPoints)",
                icon: "crown.fill",
                color: BZCColors.warmGold
            )
        }
    }

    // MARK: - Chart

    private var wellnessTrendChart: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            Label("Weekly Activity", systemImage: "chart.bar.fill")
                .font(.headline.bold())
                .foregroundStyle(BZCColors.textPrimary)

            Picker("Pet", selection: $selectedPet) {
                Text("All Pets").tag(BZCPet?.none)
                ForEach(activePets) { pet in
                    Text(pet.name).tag(BZCPet?.some(pet))
                }
            }
            .pickerStyle(.segmented)
            .colorMultiply(BZCColors.royalPurple)

            let data = viewModel.weeklyData(for: selectedPet)

            if subscriptionManager.isPurchased(.expertPack) {
                Chart(data) { point in
                    BarMark(
                        x: .value("Day", point.day),
                        y: .value("Activities", point.activities)
                    )
                    .foregroundStyle(BZCColors.gradientPurple)
                    .cornerRadius(6)
                }
                .frame(height: 160)
                .chartYScale(domain: 0...10)
                .foregroundStyle(BZCColors.textTertiary)
            } else {
                BZCPremiumChartPlaceholder()
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

    // MARK: - Achievements

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            Label("Achievements (\(progress.unlockedAchievements.count)/\(BZCAchievement.allAchievements.count))", systemImage: "trophy.fill")
                .font(.headline.bold())
                .foregroundStyle(BZCColors.richGold)

            if progress.unlockedAchievements.isEmpty {
                Text("Complete care activities to earn your first achievement!")
                    .font(.subheadline)
                    .foregroundStyle(BZCColors.textTertiary)
                    .padding(.vertical, BZCLayout.paddingDefault)
            } else {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: BZCLayout.spacingSmall) {
                        ForEach(progress.unlockedAchievements) { achievement in
                            BZCAchievementBadge(achievement: achievement)
                        }
                    }
                    .padding(.horizontal, BZCLayout.paddingDefault)
                }
                .scrollIndicators(.hidden)
                .padding(.horizontal, -BZCLayout.paddingDefault)
            }
        }
        .padding(BZCLayout.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                .fill(BZCColors.glassBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                        .strokeBorder(BZCColors.richGold.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Guardian Journey

    private var guardianJourneySection: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            Label("Zoo Guardian Journey", systemImage: "crown.fill")
                .font(.headline.bold())
                .foregroundStyle(BZCColors.textPrimary)

            ForEach(BZCGuardianTier.allCases, id: \.self) { tier in
                BZCGuardianTierRow(
                    tier: tier,
                    isUnlocked: progress.totalPoints >= tier.pointsRequired,
                    isCurrent: progress.currentTier == tier
                )
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

    // MARK: - Reminders

    private var upcomingRemindersSection: some View {
        let reminders = viewModel.upcomingReminders(for: activePets)
        return Group {
            if !reminders.isEmpty {
                VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
                    Label("Upcoming Reminders", systemImage: "bell.fill")
                        .font(.headline.bold())
                        .foregroundStyle(BZCColors.textPrimary)

                    ForEach(Array(reminders.enumerated()), id: \.offset) { _, pair in
                        HStack {
                            Image(systemName: pair.1.careType.systemIcon)
                                .foregroundStyle(pair.1.careType.guideMascot.accentColor)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(pair.1.title)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(BZCColors.textPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                Text(pair.0.name)
                                    .font(.caption)
                                    .foregroundStyle(BZCColors.textSecondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text(pair.1.dueDate, format: .dateTime.day().month())
                                .font(.caption)
                                .foregroundStyle(pair.1.isOverdue ? BZCColors.errorRed : BZCColors.textTertiary)
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
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Data Yet", systemImage: "chart.bar.fill")
        } description: {
            Text("Add pets and start logging care activities to see your dashboard.")
        }
        .foregroundStyle(BZCColors.textPrimary, BZCColors.textSecondary)
    }
}

// MARK: - Stat Card

struct BZCStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingSmall) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.title2.bold())
                .foregroundStyle(BZCColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(.caption)
                .foregroundStyle(BZCColors.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(BZCLayout.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: BZCLayout.cornerRadius)
                .fill(color.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: BZCLayout.cornerRadius)
                        .strokeBorder(color.opacity(0.25), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

// MARK: - Premium Chart Placeholder

struct BZCPremiumChartPlaceholder: View {
    var body: some View {
        VStack(spacing: BZCLayout.spacingDefault) {
            Image(systemName: "crown.fill")
                .font(.title)
                .foregroundStyle(BZCColors.richGold)
            Text("Advanced Analytics")
                .font(.headline.bold())
                .foregroundStyle(BZCColors.textPrimary)
            Text("Unlock the Expert Pack to view detailed weekly charts and wellness trends.")
                .font(.caption)
                .foregroundStyle(BZCColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(BZCColors.richGold.opacity(0.05), in: RoundedRectangle(cornerRadius: BZCLayout.cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: BZCLayout.cornerRadius)
                .strokeBorder(BZCColors.richGold.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
        }
    }
}

// MARK: - Achievement Badge

struct BZCAchievementBadge: View {
    let achievement: BZCAchievement

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: achievement.category.symbolName)
                .font(.title3.bold())
                .foregroundStyle(BZCColors.richGold)
                .frame(width: 54, height: 54)
                .background(BZCColors.richGold.opacity(0.15), in: Circle())
                .overlay {
                    Circle().strokeBorder(BZCColors.richGold.opacity(0.4), lineWidth: 1.5)
                }

            Text(achievement.title)
                .font(.caption2.bold())
                .foregroundStyle(BZCColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(width: 70)
        }
        .accessibilityLabel("\(achievement.title) achievement, \(achievement.points) points")
    }
}

// MARK: - Guardian Tier Row

struct BZCGuardianTierRow: View {
    let tier: BZCGuardianTier
    let isUnlocked: Bool
    let isCurrent: Bool

    var body: some View {
        HStack(spacing: BZCLayout.spacingDefault) {
            Image(systemName: tier.symbolName)
                .font(.title3.bold())
                .foregroundStyle(isUnlocked ? tier.accentColor : BZCColors.textTertiary)
                .opacity(isUnlocked ? 1 : 0.4)

            VStack(alignment: .leading, spacing: 2) {
                Text(tier.displayName)
                    .font(.subheadline.bold())
                    .foregroundStyle(isUnlocked ? BZCColors.textPrimary : BZCColors.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("\(tier.pointsRequired) pts required")
                    .font(.caption)
                    .foregroundStyle(BZCColors.textTertiary)
                    .lineLimit(1)
            }

            Spacer()

            if isCurrent {
                Text("Current")
                    .font(.caption.bold())
                    .foregroundStyle(tier.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(tier.accentColor.opacity(0.15), in: Capsule())
            } else if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(BZCColors.emeraldGreen)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundStyle(BZCColors.textTertiary)
                    .font(.caption)
            }
        }
        .padding(.vertical, BZCLayout.spacingSmall)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(tier.displayName), \(isUnlocked ? "unlocked" : "locked"), \(tier.pointsRequired) points required")
    }
}

#Preview {
    BZCDashboardView()
        .modelContainer(for: [BZCPet.self], inMemory: true)
        .environment(SubscriptionManager())
        .environment(BZCGuardianProgress())
}
