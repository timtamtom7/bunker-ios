import SwiftUI

struct TemplatesView: View {
    @State private var templates: [DecisionTemplate] = []
    @State private var showingCreateTemplate = false
    @State private var selectedTemplate: DecisionTemplate?
    
    var body: some View {
        ZStack {
            Color.bunkerBackground.ignoresSafeArea()
            
            if templates.isEmpty {
                emptyState
            } else {
                templateList
            }
        }
        .navigationTitle("Templates")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCreateTemplate = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.bunkerPrimary)
                }
            }
        }
        .sheet(isPresented: $showingCreateTemplate) {
            CreateTemplateSheet(templates: $templates)
        }
        .sheet(item: $selectedTemplate) { template in
            TemplateDetailSheet(template: template) { updated in
                if let index = templates.firstIndex(where: { $0.id == updated.id }) {
                    templates[index] = updated
                    saveTemplates()
                }
            }
        }
        .onAppear {
            loadTemplates()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "doc.on-doc")
                .font(.system(size: 56))
                .foregroundStyle(Color.bunkerTextTertiary)
            
            Text("No templates yet")
                .font(.bunkerHeading2)
                .foregroundStyle(Color.bunkerTextPrimary)
            
            Text("Save your decision structure as\na reusable template.")
                .font(.bunkerBody)
                .foregroundStyle(Color.bunkerTextSecondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingCreateTemplate = true
            } label: {
                Text("Create Template")
                    .font(.bunkerBodySmall)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.bunkerBackground)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.bunkerPrimary)
                    .clipShape(Capsule())
            }
        }
        .padding(Spacing.xl)
    }
    
    private var templateList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                // Default templates
                if !templates.filter({ $0.usageCount == 0 }).isEmpty {
                    templateSection(title: "Suggested", templates: templates.filter { $0.usageCount == 0 })
                }
                
                // Your templates
                if !templates.filter({ $0.usageCount > 0 }).isEmpty {
                    templateSection(title: "My Templates", templates: templates.filter { $0.usageCount > 0 })
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.sm)
        }
    }
    
    private func templateSection(title: String, templates: [DecisionTemplate]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.bunkerHeading3)
                .foregroundStyle(Color.bunkerTextSecondary)
            
            ForEach(templates) { template in
                TemplateCard(template: template) {
                    selectedTemplate = template
                }
            }
        }
    }
    
    private func loadTemplates() {
        templates = (try? UserDefaults.standard.getTemplates()) ?? DecisionTemplate.templates
        if templates.isEmpty {
            templates = DecisionTemplate.templates
            saveTemplates()
        }
    }
    
    private func saveTemplates() {
        try? UserDefaults.standard.saveTemplates(templates)
    }
}

struct TemplateCard: View {
    let template: DecisionTemplate
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text(template.name)
                        .font(.bunkerHeading3)
                        .foregroundStyle(Color.bunkerTextPrimary)
                    
                    Spacer()
                    
                    Text("\(template.criteria.count) criteria")
                        .font(.bunkerCaption)
                        .foregroundStyle(Color.bunkerTextTertiary)
                }
                
                if let description = template.description {
                    Text(description)
                        .font(.bunkerBodySmall)
                        .foregroundStyle(Color.bunkerTextSecondary)
                        .lineLimit(2)
                }
                
                // Criteria preview
                HStack(spacing: Spacing.xs) {
                    ForEach(template.criteria.prefix(3)) { criteria in
                        Text(criteria.name)
                            .font(.bunkerCaption)
                            .foregroundStyle(Color.bunkerPrimary)
                            .padding(.horizontal, Spacing.xs)
                            .padding(.vertical, 2)
                            .background(Color.bunkerPrimary.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    if template.criteria.count > 3 {
                        Text("+\(template.criteria.count - 3)")
                            .font(.bunkerCaption)
                            .foregroundStyle(Color.bunkerTextTertiary)
                    }
                }
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.bunkerSurfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.bunkerDivider, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct CreateTemplateSheet: View {
    @Binding var templates: [DecisionTemplate]
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var criteriaTemplates: [CriteriaTemplate] = []
    @State private var newCriteriaName = ""
    @State private var newCriteriaImportance = 5
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bunkerBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        nameSection
                        descriptionSection
                        criteriaSection
                        Spacer(minLength: Spacing.xl)
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.bunkerTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let template = DecisionTemplate(
                            name: name,
                            description: description.isEmpty ? nil : description,
                            criteria: criteriaTemplates
                        )
                        templates.append(template)
                        saveTemplates()
                        dismiss()
                    }
                    .foregroundStyle(Color.bunkerPrimary)
                    .disabled(name.isEmpty || criteriaTemplates.isEmpty)
                }
            }
        }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Template Name")
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerTextSecondary)
            TextField("e.g. Career Move", text: $name)
                .textFieldStyle(.plain)
                .padding(Spacing.sm)
                .background(Color.bunkerSurfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(Color.bunkerTextPrimary)
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Description (optional)")
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerTextSecondary)
            TextField("Brief description", text: $description)
                .textFieldStyle(.plain)
                .padding(Spacing.sm)
                .background(Color.bunkerSurfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(Color.bunkerTextPrimary)
        }
    }

    private var criteriaSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Criteria")
                .font(.bunkerHeading3)
                .foregroundStyle(Color.bunkerTextPrimary)

            ForEach(criteriaTemplates) { criteria in
                criteriaRow(criteria)
            }

            addCriteriaRow
        }
    }

    private func criteriaRow(_ criteria: CriteriaTemplate) -> some View {
        HStack {
            Text(criteria.name)
                .font(.bunkerBody)
                .foregroundStyle(Color.bunkerTextPrimary)
            Spacer()
            Text("w:\(criteria.importance)")
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerPrimary)
            Button {
                criteriaTemplates.removeAll { $0.id == criteria.id }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color.bunkerTextTertiary)
            }
        }
        .padding(Spacing.sm)
        .background(Color.bunkerSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var addCriteriaRow: some View {
        HStack {
            TextField("Criteria name", text: $newCriteriaName)
                .textFieldStyle(.plain)
                .foregroundStyle(Color.bunkerTextPrimary)
            Stepper("\(newCriteriaImportance)", value: $newCriteriaImportance, in: 1...10)
                .labelsHidden()
            Button {
                let criteria = CriteriaTemplate(name: newCriteriaName, importance: newCriteriaImportance)
                criteriaTemplates.append(criteria)
                newCriteriaName = ""
                newCriteriaImportance = 5
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Color.bunkerPrimary)
            }
            .disabled(newCriteriaName.isEmpty)
        }
        .padding(Spacing.sm)
        .background(Color.bunkerSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func saveTemplates() {
        try? UserDefaults.standard.saveTemplates(templates)
    }
}

struct TemplateDetailSheet: View {
    let template: DecisionTemplate
    let onUpdate: (DecisionTemplate) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var updatedTemplate: DecisionTemplate
    
    init(template: DecisionTemplate, onUpdate: @escaping (DecisionTemplate) -> Void) {
        self.template = template
        self.onUpdate = onUpdate
        _updatedTemplate = State(initialValue: template)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bunkerBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Header
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(updatedTemplate.name)
                                .font(.bunkerHeading1)
                                .foregroundStyle(Color.bunkerTextPrimary)
                            
                            if let description = updatedTemplate.description {
                                Text(description)
                                    .font(.bunkerBody)
                                    .foregroundStyle(Color.bunkerTextSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Spacing.md)
                        .background(Color.bunkerSurfaceCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Criteria
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Criteria (\(updatedTemplate.criteria.count))")
                                .font(.bunkerHeading3)
                                .foregroundStyle(Color.bunkerTextSecondary)

                            ForEach(updatedTemplate.criteria) { criteria in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.bunkerPrimary)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(criteria.name)
                                            .font(.bunkerBody)
                                            .foregroundStyle(Color.bunkerTextPrimary)
                                        
                                        if let guidance = criteria.guidance {
                                            Text(guidance)
                                                .font(.bunkerCaption)
                                                .foregroundStyle(Color.bunkerTextTertiary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text("weight: \(criteria.importance)")
                                        .font(.bunkerCaption)
                                        .foregroundStyle(Color.bunkerPrimary)
                                }
                                .padding(Spacing.sm)
                                .background(Color.bunkerSurfaceCard)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        
                        Spacer(minLength: Spacing.xl)
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.bunkerPrimary)
                }
            }
        }
    }
}

// MARK: - UserDefaults Extensions

extension UserDefaults {
    private static let templatesKey = "bunker_decision_templates"
    
    func getTemplates() throws -> [DecisionTemplate]? {
        guard let data = data(forKey: Self.templatesKey) else { return nil }
        return try JSONDecoder().decode([DecisionTemplate].self, from: data)
    }
    
    func saveTemplates(_ templates: [DecisionTemplate]) throws {
        let data = try JSONEncoder().encode(templates)
        set(data, forKey: Self.templatesKey)
    }
    
    private static let groupsKey = "bunker_decision_groups"
    
    func getGroups() throws -> [DecisionGroup]? {
        guard let data = data(forKey: Self.groupsKey) else { return nil }
        return try JSONDecoder().decode([DecisionGroup].self, from: data)
    }
    
    func saveGroups(_ groups: [DecisionGroup]) throws {
        let data = try JSONEncoder().encode(groups)
        set(data, forKey: Self.groupsKey)
    }
    
    private static let sharedKey = "bunker_shared_decisions"
    
    func getSharedDecisions() throws -> [SharedDecision]? {
        guard let data = data(forKey: Self.sharedKey) else { return nil }
        return try JSONDecoder().decode([SharedDecision].self, from: data)
    }
    
    func saveSharedDecisions(_ shared: [SharedDecision]) throws {
        let data = try JSONEncoder().encode(shared)
        set(data, forKey: Self.sharedKey)
    }
}

#Preview {
    NavigationStack {
        TemplatesView()
    }
    .preferredColorScheme(.dark)
}
