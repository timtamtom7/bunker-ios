import Foundation
import AppKit

/// macOS export service for JSON and PDF
@MainActor final class MacExportService: ObservableObject {
    static let shared = MacExportService()

    private init() {}

    // MARK: - JSON Export

    func exportToJSON(decision: Decision, outcomes: [Outcome]) -> Data? {
        let export = DecisionExport(
            decision: decision,
            outcomes: outcomes,
            exportedAt: Date()
        )
        return try? JSONEncoder().encode(export)
    }

    func exportToJSON(decisions: [Decision]) -> Data? {
        let exports = decisions.map { DecisionExport(decision: $0, outcomes: [], exportedAt: Date()) }
        return try? JSONEncoder().encode(exports)
    }

    // MARK: - PDF Export

    func exportToPDF(decision: Decision, outcomes: [Outcome]) -> Data? {
        let pageWidth: CGFloat = 612  // US Letter
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50

        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let pdfData = NSMutableData()

        guard let consumer = CGDataConsumer(data: pdfData as CFMutableData),
              let context = CGContext(consumer: consumer, mediaBox: nil, nil) else {
            return nil
        }

        var mediaBox = pageRect
        context.beginPage(mediaBox: &mediaBox)

        var yOffset: CGFloat = margin

        // Title
        let titleFont = NSFont.systemFont(ofSize: 24, weight: .bold)
        let titleColor = NSColor(red: 0.29, green: 0.56, blue: 0.85, alpha: 1.0)
        let titleRect = CGRect(x: margin, y: yOffset, width: pageWidth - 2 * margin, height: 40)
        (decision.title as NSString).draw(in: titleRect, withAttributes: [
            .font: titleFont,
            .foregroundColor: titleColor
        ])
        yOffset += 45

        // Description
        if !decision.description.isEmpty {
            let descFont = NSFont.systemFont(ofSize: 12)
            let descColor = NSColor.darkGray
            let descRect = CGRect(x: margin, y: yOffset, width: pageWidth - 2 * margin, height: 40)
            (decision.description as NSString).draw(in: descRect, withAttributes: [
                .font: descFont,
                .foregroundColor: descColor
            ])
            yOffset += 35
        }

        // Meta info
        let metaFont = NSFont.systemFont(ofSize: 10)
        let metaColor = NSColor.gray
        let metaText = "Stake: \(decision.stake.rawValue) | Reversibility: \(decision.reversibility.rawValue) | Time Horizon: \(decision.timeHorizon.rawValue)"
        let metaRect = CGRect(x: margin, y: yOffset, width: pageWidth - 2 * margin, height: 15)
        (metaText as NSString).draw(in: metaRect, withAttributes: [
            .font: metaFont,
            .foregroundColor: metaColor
        ])
        yOffset += 30

        // Divider
        let dividerPath = NSBezierPath()
        dividerPath.move(to: NSPoint(x: margin, y: yOffset))
        dividerPath.line(to: NSPoint(x: pageWidth - margin, y: yOffset))
        NSColor.lightGray.setStroke()
        dividerPath.stroke()
        yOffset += 20

        // Criteria Section
        let sectionFont = NSFont.systemFont(ofSize: 14, weight: .semibold)
        let sectionColor = NSColor(red: 0.29, green: 0.56, blue: 0.85, alpha: 1.0)
        ("Criteria (\(decision.criteria.count))" as NSString).draw(at: NSPoint(x: margin, y: yOffset), withAttributes: [
            .font: sectionFont,
            .foregroundColor: sectionColor
        ])
        yOffset += 25

        let criteriaFont = NSFont.systemFont(ofSize: 11)
        let criteriaColor = NSColor.black
        for criteria in decision.criteria {
            let text = "• \(criteria.name) (weight: \(criteria.importance)/10)"
            let rect = CGRect(x: margin + 10, y: yOffset, width: pageWidth - 2 * margin - 10, height: 18)
            (text as NSString).draw(in: rect, withAttributes: [.font: criteriaFont, .foregroundColor: criteriaColor])
            yOffset += 18
        }
        yOffset += 15

        // Options Section
        ("Options (\(decision.options.count))" as NSString).draw(at: NSPoint(x: margin, y: yOffset), withAttributes: [
            .font: sectionFont,
            .foregroundColor: sectionColor
        ])
        yOffset += 25

        for option in decision.options {
            let text = "• \(option)"
            let rect = CGRect(x: margin + 10, y: yOffset, width: pageWidth - 2 * margin - 10, height: 18)
            (text as NSString).draw(in: rect, withAttributes: [.font: criteriaFont, .foregroundColor: criteriaColor])
            yOffset += 18
        }

        // Outcomes
        if !outcomes.isEmpty {
            yOffset += 20
            ("Recommended Outcome" as NSString).draw(at: NSPoint(x: margin, y: yOffset), withAttributes: [
                .font: sectionFont,
                .foregroundColor: sectionColor
            ])
            yOffset += 25

            if let top = outcomes.first {
                let outcomeFont = NSFont.systemFont(ofSize: 12, weight: .medium)
                let outcomeText = "Recommended: \(top.option) — Score: \(String(format: "%.2f", top.weightedScore)) | Confidence: \(Int(top.confidence))%"
                let outcomeRect = CGRect(x: margin + 10, y: yOffset, width: pageWidth - 2 * margin - 10, height: 20)
                (outcomeText as NSString).draw(in: outcomeRect, withAttributes: [.font: outcomeFont, .foregroundColor: criteriaColor])
                yOffset += 30

                // Score breakdown
                let breakdownFont = NSFont.systemFont(ofSize: 10)
                let breakdownColor = NSColor.gray
                for item in top.scoreBreakdown {
                    let text = "  \(item.criteriaName): weight=\(item.criteriaWeight), score=\(item.optionScore), weighted=\(String(format: "%.2f", item.weightedValue))"
                    let rect = CGRect(x: margin + 10, y: yOffset, width: pageWidth - 2 * margin - 10, height: 15)
                    (text as NSString).draw(in: rect, withAttributes: [.font: breakdownFont, .foregroundColor: breakdownColor])
                    yOffset += 15
                }
            }
        }

        // Footer
        yOffset = pageHeight - margin
        let footerFont = NSFont.systemFont(ofSize: 8)
        let footerColor = NSColor.lightGray
        let footerText = "Generated by Bunker | \(Date().formatted(date: .abbreviated, time: .shortened))"
        let footerRect = CGRect(x: margin, y: yOffset, width: pageWidth - 2 * margin, height: 15)
        (footerText as NSString).draw(in: footerRect, withAttributes: [
            .font: footerFont,
            .foregroundColor: footerColor
        ])

        context.endPage()
        context.closePDF()

        return pdfData as Data
    }

    // MARK: - Share Text

    func shareText(decision: Decision, outcomes: [Outcome]) -> String {
        var text = "Decision: \(decision.title)\n"
        if !decision.description.isEmpty {
            text += "\(decision.description)\n"
        }
        text += "\nCriteria (\(decision.criteria.count)):\n"
        for criteria in decision.criteria {
            text += "- \(criteria.name) [weight: \(criteria.importance)/10]\n"
        }
        text += "\nOptions (\(decision.options.count)):\n"
        for (i, option) in decision.options.enumerated() {
            text += "\(i + 1). \(option)\n"
        }
        if let top = outcomes.first {
            text += "\nRecommended: \(top.option) (Score: \(String(format: "%.1f", top.weightedScore)) | Confidence: \(Int(top.confidence))%)\n"
        }
        text += "\nMade with Bunker"
        return text
    }
}

// Import shared models
import Foundation

struct DecisionExport: Codable {
    let decision: Decision
    let outcomes: [Outcome]
    let exportedAt: Date
}
