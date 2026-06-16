import SwiftUI

struct BZCChatInputBar: View {
    @Bindable var mentor: BZCAnimalCareMentor
    @FocusState private var isInputFocused: Bool

    private var canSend: Bool {
        !mentor.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !mentor.isGenerating
    }

    var body: some View {
        HStack(spacing: BZCLayout.spacingSmall) {
            TextField("Ask about animal care…", text: $mentor.inputText, axis: .vertical)
                .focused($isInputFocused)
                .lineLimit(1...4)
                .foregroundStyle(BZCColors.textPrimary)
                .submitLabel(.send)
                .onSubmit {
                    guard canSend else { return }
                    Task { await mentor.send() }
                }
                .padding(.horizontal, BZCLayout.paddingDefault)
                .padding(.vertical, BZCLayout.paddingSmall)
                .background(BZCColors.glassBackground, in: RoundedRectangle(cornerRadius: 22))
                .overlay {
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(
                            isInputFocused ? BZCColors.richGold.opacity(0.5) : BZCColors.glassBorder,
                            lineWidth: 1
                        )
                        .animation(BZCMotion.easeDefault, value: isInputFocused)
                }

            Button {
                Task { await mentor.send() }
            } label: {
                Image(systemName: mentor.isGenerating ? "hourglass" : "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(canSend ? BZCColors.richGold : BZCColors.textTertiary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .disabled(!canSend)
            .frame(width: BZCLayout.minTapTarget, height: BZCLayout.minTapTarget)
            .sensoryFeedback(.impact(weight: .medium), trigger: mentor.isGenerating)
        }
        .padding(BZCLayout.paddingDefault)
        .background(.ultraThinMaterial)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") { isInputFocused = false }
                        .font(.subheadline.bold())
                        .foregroundStyle(BZCColors.richGold)
                }
            }
        }
    }
}
