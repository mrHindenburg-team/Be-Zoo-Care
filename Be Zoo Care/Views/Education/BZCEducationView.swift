import SwiftUI

struct BZCEducationView: View {
    @Environment(BZCGuardianProgress.self) private var progress
    @State private var viewModel = BZCEducationViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                BZCColors.gradientBackground.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: BZCLayout.spacingLarge) {
                        mascotCategorySection
                        articleListSection
                    }
                    .padding(BZCLayout.paddingDefault)
                    .padding(.bottom, 80)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .searchable(text: $viewModel.searchText, prompt: "Search articles…")
            .navigationDestination(for: BZCEducationalArticle.ID.self) { id in
                if let article = BZCKnowledgeBase.all.first(where: { $0.id == id }) {
                    BZCArticleDetailView(article: article)
                        .onAppear {
                            progress.recordArticleRead(id)
                        }
                }
            }
        }
    }

    // MARK: - Sections

    private var mascotCategorySection: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            Label("Your Care Guides", systemImage: "star.fill")
                .font(.headline.bold())
                .foregroundStyle(BZCColors.textPrimary)

            ScrollView(.horizontal) {
                LazyHStack(spacing: BZCLayout.spacingDefault) {
                    ForEach(BZCMascot.allCases) { mascot in
                        Button(action: {
                            withAnimation(BZCMotion.springDefault) {
                                viewModel.selectedMascot = viewModel.selectedMascot == mascot ? nil : mascot
                            }
                        }) {
                            BZCMascotCategoryCard(
                                mascot: mascot,
                                isSelected: viewModel.selectedMascot == mascot,
                                articleCount: BZCKnowledgeBase.all.count(where: { $0.mascot == mascot })
                            )
                        }
                    }
                }
                .padding(.horizontal, BZCLayout.paddingDefault)
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal, -BZCLayout.paddingDefault)
        }
    }

    private var articleListSection: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            HStack {
                Label("Articles", systemImage: "books.vertical.fill")
                    .font(.headline.bold())
                    .foregroundStyle(BZCColors.textPrimary)
                Spacer()
                Text("\(viewModel.filteredArticles.count) article\(viewModel.filteredArticles.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(BZCColors.textTertiary)
            }

            if viewModel.filteredArticles.isEmpty {
                ContentUnavailableView.search
                    .foregroundStyle(BZCColors.textPrimary, BZCColors.textSecondary)
            } else {
                ForEach(viewModel.filteredArticles) { article in
                    NavigationLink(value: article.id) {
                        BZCArticleCard(article: article, isRead: progress.articlesRead.contains(article.id))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Mascot Category Card

struct BZCMascotCategoryCard: View {
    let mascot: BZCMascot
    let isSelected: Bool
    let articleCount: Int

    var body: some View {
        VStack(spacing: BZCLayout.spacingSmall) {
            BZCMascotView(mascot: mascot, size: 64, showName: false, isAnimated: isSelected)

            Text(mascot.displayName)
                .font(.caption.bold())
                .foregroundStyle(isSelected ? mascot.accentColor : BZCColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text("\(articleCount) articles")
                .font(.caption2)
                .foregroundStyle(BZCColors.textTertiary)
                .lineLimit(1)
        }
        .frame(width: 90)
        .padding(.vertical, BZCLayout.paddingSmall)
        .background(
            RoundedRectangle(cornerRadius: BZCLayout.cornerRadius)
                .fill(isSelected ? mascot.accentColor.opacity(0.15) : BZCColors.glassBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: BZCLayout.cornerRadius)
                        .strokeBorder(isSelected ? mascot.accentColor : BZCColors.glassBorder, lineWidth: 1)
                )
        )
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

// MARK: - Article Card

struct BZCArticleCard: View {
    let article: BZCEducationalArticle
    let isRead: Bool

    var body: some View {
        HStack(alignment: .top, spacing: BZCLayout.spacingDefault) {
            Image(systemName: article.mascot.symbolName)
                .font(.title3.bold())
                .foregroundStyle(article.mascot.accentColor)
                .frame(width: 44, height: 44)
                .background(article.mascot.accentColor.opacity(0.15), in: RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusSmall))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(article.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(BZCColors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    Spacer()
                    if article.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundStyle(BZCColors.richGold)
                    }
                    if isRead {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(BZCColors.emeraldGreen)
                    }
                }

                Text(article.summary)
                    .font(.caption)
                    .foregroundStyle(BZCColors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Label("\(article.readTimeMinutes) min read", systemImage: "clock")
                    .font(.caption2)
                    .foregroundStyle(BZCColors.textTertiary)
            }
        }
        .padding(BZCLayout.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: BZCLayout.cornerRadius)
                .fill(BZCColors.glassBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: BZCLayout.cornerRadius)
                        .strokeBorder(BZCColors.glassBorder, lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(article.title), \(article.readTimeMinutes) minute read\(isRead ? ", already read" : "")")
    }
}

// MARK: - Article Detail

struct BZCArticleDetailView: View {
    let article: BZCEducationalArticle

    var body: some View {
        ZStack {
            BZCColors.gradientBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: BZCLayout.spacingLarge) {
                    VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
                        HStack {
                            BZCMascotView(mascot: article.mascot, size: 60, showName: true)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Label("\(article.readTimeMinutes) min", systemImage: "clock")
                                    .font(.caption)
                                    .foregroundStyle(BZCColors.textTertiary)
                                if article.isPremium {
                                    Label("Premium", systemImage: "crown.fill")
                                        .font(.caption.bold())
                                        .foregroundStyle(BZCColors.richGold)
                                }
                            }
                        }

                        Text(article.title)
                            .font(.title2.bold())
                            .foregroundStyle(BZCColors.textPrimary)

                        Text(article.summary)
                            .font(.subheadline)
                            .foregroundStyle(BZCColors.textSecondary)

                        HStack {
                            ForEach(article.tags.prefix(4), id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption2.bold())
                                    .foregroundStyle(article.mascot.accentColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(article.mascot.accentColor.opacity(0.12), in: Capsule())
                            }
                        }
                    }
                    .padding(BZCLayout.cardPadding)
                    .background(
                        RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                            .fill(article.mascot.accentColor.opacity(0.10))
                            .overlay(
                                RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                                    .strokeBorder(article.mascot.accentColor.opacity(0.2), lineWidth: 1)
                            )
                    )

                    Text(article.content)
                        .font(.body)
                        .foregroundStyle(BZCColors.textSecondary)
                        .lineSpacing(6)
                        .padding(BZCLayout.cardPadding)
                        .background(BZCColors.glassBackground, in: RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge))
                }
                .padding(BZCLayout.paddingDefault)
                .padding(.bottom, 80)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

#Preview {
    BZCEducationView()
        .environment(BZCGuardianProgress())
}
