import SwiftUI

struct GroupsView: View {
    @State private var groups: [DecisionGroup] = []
    @State private var showingCreateGroup = false
    @State private var selectedGroup: DecisionGroup?
    
    var body: some View {
        ZStack {
            Color.bunkerBackground.ignoresSafeArea()
            
            if groups.isEmpty {
                emptyState
            } else {
                groupList
            }
        }
        .navigationTitle("Groups")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCreateGroup = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.bunkerPrimary)
                }
            }
        }
        .sheet(isPresented: $showingCreateGroup) {
            CreateGroupSheet(groups: $groups)
        }
        .sheet(item: $selectedGroup) { group in
            GroupDetailSheet(group: group, groups: $groups)
        }
        .onAppear {
            loadGroups()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "folder")
                .font(.system(size: 56))
                .foregroundStyle(Color.bunkerTextTertiary)
            
            Text("No groups yet")
                .font(.bunkerHeading2)
                .foregroundStyle(Color.bunkerTextPrimary)
            
            Text("Organize your decisions\ninto themed groups.")
                .font(.bunkerBody)
                .foregroundStyle(Color.bunkerTextSecondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingCreateGroup = true
            } label: {
                Text("Create Group")
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
    
    private var groupList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.sm) {
                ForEach(groups) { group in
                    GroupRow(group: group)
                        .onTapGesture {
                            selectedGroup = group
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                groups.removeAll { $0.id == group.id }
                                saveGroups()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.sm)
        }
    }
    
    private func loadGroups() {
        groups = (try? UserDefaults.standard.getGroups()) ?? []
    }
    
    private func saveGroups() {
        try? UserDefaults.standard.saveGroups(groups)
    }
}

struct GroupRow: View {
    let group: DecisionGroup
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: group.iconName)
                .font(.title2)
                .foregroundStyle(Color(hex: group.color))
                .frame(width: 40, height: 40)
                .background(Color(hex: group.color).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(group.name)
                    .font(.bunkerHeading3)
                    .foregroundStyle(Color.bunkerTextPrimary)
                
                Text("\(group.decisionCount) decisions")
                    .font(.bunkerCaption)
                    .foregroundStyle(Color.bunkerTextSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerTextTertiary)
        }
        .padding(Spacing.md)
        .background(Color.bunkerSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.bunkerDivider, lineWidth: 1)
        )
    }
}

struct CreateGroupSheet: View {
    @Binding var groups: [DecisionGroup]
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedIcon = "folder"
    @State private var selectedColor = "4A90D9"
    
    private let colors = ["4A90D9", "68D391", "F6AD55", "FC8181", "B794F4", "38B2AC", "F6E05E", "FC8181"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bunkerBackground.ignoresSafeArea()
                
                VStack(spacing: Spacing.lg) {
                    // Preview
                    HStack(spacing: Spacing.md) {
                        Image(systemName: selectedIcon)
                            .font(.title)
                            .foregroundStyle(Color(hex: selectedColor))
                            .frame(width: 56, height: 56)
                            .background(Color(hex: selectedColor).opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading) {
                            Text(name.isEmpty ? "Group Name" : name)
                                .font(.bunkerHeading2)
                                .foregroundStyle(name.isEmpty ? Color.bunkerTextTertiary : Color.bunkerTextPrimary)
                            
                            Text("0 decisions")
                                .font(.bunkerCaption)
                                .foregroundStyle(Color.bunkerTextSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding(Spacing.md)
                    .background(Color.bunkerSurfaceCard)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Name field
                    TextField("Group name", text: $name)
                        .textFieldStyle(.plain)
                        .padding(Spacing.sm)
                        .background(Color.bunkerSurfaceCard)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(Color.bunkerTextPrimary)
                    
                    // Icon picker
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Icon")
                            .font(.bunkerCaption)
                            .foregroundStyle(Color.bunkerTextSecondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: Spacing.sm) {
                            ForEach(DecisionGroupIcon.icons, id: \.name) { icon in
                                Button {
                                    selectedIcon = icon.name
                                } label: {
                                    Image(systemName: icon.name)
                                        .font(.body)
                                        .frame(width: 44, height: 44)
                                        .background(selectedIcon == icon.name ? Color.bunkerPrimary.opacity(0.2) : Color.bunkerSurfaceCard)
                                        .foregroundStyle(selectedIcon == icon.name ? Color.bunkerPrimary : Color.bunkerTextSecondary)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                    
                    // Color picker
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Color")
                            .font(.bunkerCaption)
                            .foregroundStyle(Color.bunkerTextSecondary)
                        
                        HStack(spacing: Spacing.sm) {
                            ForEach(colors, id: \.self) { color in
                                Button {
                                    selectedColor = color
                                } label: {
                                    Circle()
                                        .fill(Color(hex: color))
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColor == color ? Color.white : Color.clear, lineWidth: 3)
                                        )
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(Spacing.md)
            }
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.bunkerTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let group = DecisionGroup(name: name, iconName: selectedIcon, color: selectedColor)
                        groups.append(group)
                        saveGroups()
                        dismiss()
                    }
                    .foregroundStyle(Color.bunkerPrimary)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveGroups() {
        try? UserDefaults.standard.saveGroups(groups)
    }
}

struct GroupDetailSheet: View {
    let group: DecisionGroup
    @Binding var groups: [DecisionGroup]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bunkerBackground.ignoresSafeArea()
                
                VStack(spacing: Spacing.lg) {
                    // Header
                    HStack(spacing: Spacing.md) {
                        Image(systemName: group.iconName)
                            .font(.title)
                            .foregroundStyle(Color(hex: group.color))
                            .frame(width: 64, height: 64)
                            .background(Color(hex: group.color).opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        VStack(alignment: .leading) {
                            Text(group.name)
                                .font(.bunkerHeading1)
                                .foregroundStyle(Color.bunkerTextPrimary)
                            
                            Text("\(group.decisionCount) decisions")
                                .font(.bunkerBodySmall)
                                .foregroundStyle(Color.bunkerTextSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding(Spacing.md)
                    .background(Color.bunkerSurfaceCard)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    if group.decisionCount == 0 {
                        Spacer()
                        Text("No decisions in this group yet.\nAdd decisions to this group from the decision list.")
                            .font(.bunkerBody)
                            .foregroundStyle(Color.bunkerTextSecondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    } else {
                        // Decisions in this group
                        Text("Decisions")
                            .font(.bunkerHeading3)
                            .foregroundStyle(Color.bunkerTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                    }
                }
                .padding(Spacing.md)
            }
            .navigationTitle("Group")
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

#Preview {
    NavigationStack {
        GroupsView()
    }
    .preferredColorScheme(.dark)
}
