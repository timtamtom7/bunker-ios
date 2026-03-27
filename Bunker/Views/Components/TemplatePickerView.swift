import SwiftUI

struct TemplatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (DecisionTemplate) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.md) {
                    Text("Choose a template to get started faster, or start from scratch.")
                        .font(.bunkerBodySmall)
                        .foregroundStyle(Color.bunkerTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.md)
                        .padding(.top, Spacing.sm)

                    ForEach(DecisionTemplate.templates) { template in
                        TemplatePickerCard(template: template) {
                            onSelect(template)
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.xl)
            }
            .background(Color.bunkerBackground)
            .navigationTitle("Decision Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct TemplatePickerCard: View {
    let template: DecisionTemplate
    let onSelect: () -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: template.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(Color.bunkerPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.bunkerPrimary.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(template.name)
                            .font(.bunkerHeading3)
                            .foregroundStyle(Color.bunkerTextPrimary)

                        Text(template.description ?? "")
                            .font(.bunkerCaption)
                            .foregroundStyle(Color.bunkerTextSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    HStack(spacing: Spacing.xxs) {
                        Label("\(template.options.count)", systemImage: "square.stack.3d.up")
                            .font(.bunkerLabel)
                            .foregroundStyle(Color.bunkerTextTertiary)

                        Label("\(template.criteria.count)", systemImage: "slider.horizontal.3")
                            .font(.bunkerLabel)
                            .foregroundStyle(Color.bunkerTextTertiary)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.bunkerCaption)
                        .foregroundStyle(Color.bunkerTextTertiary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                    .background(Color.bunkerDivider)

                // Criteria preview
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("Criteria")
                        .font(.bunkerLabel)
                        .foregroundStyle(Color.bunkerTextTertiary)

                    ForEach(template.criteria.prefix(4)) { criteria in
                        HStack {
                            Text(criteria.name)
                                .font(.bunkerCaption)
                                .foregroundStyle(Color.bunkerTextPrimary)

                            Spacer()

                            Text("Weight: \(criteria.importance)")
                                .font(.bunkerCaption)
                                .foregroundStyle(Color.bunkerPrimary)
                        }
                    }

                    if template.criteria.count > 4 {
                        Text("+\(template.criteria.count - 4) more criteria")
                            .font(.bunkerCaption)
                            .foregroundStyle(Color.bunkerTextTertiary)
                    }
                }

                // Options preview
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("Options")
                        .font(.bunkerLabel)
                        .foregroundStyle(Color.bunkerTextTertiary)

                    ForEach(template.options.prefix(3), id: \.self) { option in
                        HStack {
                            Image(systemName: "square.stack.3d.up.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.bunkerPrimary)

                            Text(option)
                                .font(.bunkerCaption)
                                .foregroundStyle(Color.bunkerTextPrimary)
                        }
                    }

                    if template.options.count > 3 {
                        Text("+\(template.options.count - 3) more options")
                            .font(.bunkerCaption)
                            .foregroundStyle(Color.bunkerTextTertiary)
                    }
                }

                // Stake info
                HStack {
                    Label(template.stake.rawValue, systemImage: "exclamationmark.triangle")
                        .font(.bunkerLabel)
                        .foregroundStyle(Color(hex: template.stake.color))

                    Label(template.reversibility.rawValue, systemImage: "arrow.uturn.backward")
                        .font(.bunkerLabel)
                        .foregroundStyle(Color.bunkerTextTertiary)

                    Label(template.timeHorizon.rawValue, systemImage: "clock")
                        .font(.bunkerLabel)
                        .foregroundStyle(Color.bunkerTextTertiary)
                }

                Button {
                    onSelect()
                } label: {
                    Text("Use This Template")
                        .font(.bunkerBody)
                        .foregroundStyle(Color.bunkerBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.bunkerPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.top, Spacing.xxs)
            }
        }
        .padding(Spacing.md)
        .background(Color.bunkerSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.bunkerDivider, lineWidth: 1)
        )
    }
}

#Preview {
    TemplatePickerView { _ in }
        .preferredColorScheme(.dark)
}
