import Foundation
import UIKit
import PDFKit

/// R5: Export service for JSON, PDF, and share formats
final class ExportService: @unchecked Sendable {
    static let shared = ExportService()

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

    @MainActor
    func exportToPDF(decision: Decision, outcomes: [Outcome]) -> Data? {
        let pageWidth: CGFloat = 612  // US Letter
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50

        let pdfMetaData: [String: Any] = [
            kCGPDFContextCreator as String: "Bunker",
            kCGPDFContextAuthor as String: "Bunker App",
            kCGPDFContextTitle as String: decision.title
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData

        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            context.beginPage()

            var yOffset: CGFloat = margin

            // Title
            let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
            let titleColor = UIColor(red: 0.29, green: 0.56, blue: 0.85, alpha: 1.0)
            let titleRect = CGRect(x: margin, y: yOffset, width: pageWidth - 2 * margin, height: 40)
            (decision.title as NSString).draw(in: titleRect, withAttributes: [
                .font: titleFont,
                .foregroundColor: titleColor
            ])
            yOffset += 45

            // Description
            if !decision.description.isEmpty {
                let descFont = UIFont.systemFont(ofSize: 12)
                let descColor = UIColor.darkGray
                let descRect = CGRect(x: margin, y: yOffset, width: pageWidth - 2 * margin, height: 40)
                (decision.description as NSString).draw(in: descRect, withAttributes: [
                    .font: descFont,
                    .foregroundColor: descColor
                ])
                yOffset += 35
            }

            // Meta info
            let metaFont = UIFont.systemFont(ofSize: 10)
            let metaColor = UIColor.gray
            let metaText = "Stake: \(decision.stake.rawValue) | Reversibility: \(decision.reversibility.rawValue) | Time Horizon: \(decision.timeHorizon.rawValue)"
            let metaRect = CGRect(x: margin, y: yOffset, width: pageWidth - 2 * margin, height: 15)
            (metaText as NSString).draw(in: metaRect, withAttributes: [
                .font: metaFont,
                .foregroundColor: metaColor
            ])
            yOffset += 30

            // Divider
            let dividerPath = UIBezierPath()
            dividerPath.move(to: CGPoint(x: margin, y: yOffset))
            dividerPath.addLine(to: CGPoint(x: pageWidth - margin, y: yOffset))
            UIColor.lightGray.setStroke()
            dividerPath.stroke()
            yOffset += 20

            // Criteria Section
            let sectionFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
            let sectionColor = UIColor(red: 0.29, green: 0.56, blue: 0.85, alpha: 1.0)
            ("Criteria (\(decision.criteria.count))" as NSString).draw(at: CGPoint(x: margin, y: yOffset), withAttributes: [
                .font: sectionFont,
                .foregroundColor: sectionColor
            ])
            yOffset += 25

            let criteriaFont = UIFont.systemFont(ofSize: 11)
            let criteriaColor = UIColor.black
            for criteria in decision.criteria {
                let text = "• \(criteria.name) (weight: \(criteria.importance)/10)"
                let rect = CGRect(x: margin + 10, y: yOffset, width: pageWidth - 2 * margin - 10, height: 18)
                (text as NSString).draw(in: rect, withAttributes: [.font: criteriaFont, .foregroundColor: criteriaColor])
                yOffset += 18
            }
            yOffset += 15

            // Options Section
            ("Options (\(decision.options.count))" as NSString).draw(at: CGPoint(x: margin, y: yOffset), withAttributes: [
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
                ("Recommended Outcome" as NSString).draw(at: CGPoint(x: margin, y: yOffset), withAttributes: [
                    .font: sectionFont,
                    .foregroundColor: sectionColor
                ])
                yOffset += 25

                if let top = outcomes.first {
                    let outcomeFont = UIFont.systemFont(ofSize: 12, weight: .medium)
                    let outcomeText = "Recommended: \(top.option) — Score: \(String(format: "%.2f", top.weightedScore)) | Confidence: \(Int(top.confidence))%"
                    let outcomeRect = CGRect(x: margin + 10, y: yOffset, width: pageWidth - 2 * margin - 10, height: 20)
                    (outcomeText as NSString).draw(in: outcomeRect, withAttributes: [.font: outcomeFont, .foregroundColor: criteriaColor])
                    yOffset += 30

                    // Score breakdown
                    let breakdownFont = UIFont.systemFont(ofSize: 10)
                    let breakdownColor = UIColor.gray
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
            let footerFont = UIFont.systemFont(ofSize: 8)
            let footerColor = UIColor.lightGray
            let footerText = "Generated by Bunker | \(Date().formatted(date: .abbreviated, time: .shortened))"
            let footerRect = CGRect(x: margin, y: yOffset, width: pageWidth - 2 * margin, height: 15)
            (footerText as NSString).draw(in: footerRect, withAttributes: [
                .font: footerFont,
                .foregroundColor: footerColor
            ])
        }

        return data
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

    // MARK: - Notion Export

    nonisolated func exportToNotionBlocks(decision: Decision, outcomes: [Outcome]) -> [[String: Any]] {
        var blocks: [[String: Any]] = []

        // Title
        blocks.append([
            "object": "block",
            "type": "heading_1",
            "heading_1": ["rich_text": [["text": ["content": decision.title]]]]
        ])

        // Description
        if !decision.description.isEmpty {
            blocks.append([
                "object": "block",
                "type": "paragraph",
                "paragraph": ["rich_text": [["text": ["content": decision.description]]]]
            ])
        }

        // Criteria
        blocks.append([
            "object": "block",
            "type": "heading_2",
            "heading_2": ["rich_text": [["text": ["content": "Criteria"]]]]
        ])
        for criteria in decision.criteria {
            blocks.append([
                "object": "block",
                "type": "bulleted_list_item",
                "bulleted_list_item": [
                    "rich_text": [["text": ["content": "\(criteria.name) (weight: \(criteria.importance)/10)"]]]
                ]
            ])
        }

        // Options
        blocks.append([
            "object": "block",
            "type": "heading_2",
            "heading_2": ["rich_text": [["text": ["content": "Options"]]]]
        ])
        for option in decision.options {
            blocks.append([
                "object": "block",
                "type": "numbered_list_item",
                "numbered_list_item": [
                    "rich_text": [["text": ["content": option]]]
                ]
            ])
        }

        // Outcomes
        if let top = outcomes.first {
            blocks.append([
                "object": "block",
                "type": "heading_2",
                "heading_2": ["rich_text": [["text": ["content": "Recommendation"]]]]
            ])
            blocks.append([
                "object": "block",
                "type": "callout",
                "callout": [
                    "rich_text": [["text": ["content": "\(top.option) — Score: \(String(format: "%.1f", top.weightedScore)) | Confidence: \(Int(top.confidence))%"]]],
                    "icon": ["emoji": "check"]
                ]
            ])
        }

        return blocks
    }
}

// MARK: - Export Models

struct DecisionExport: Codable {
    let decision: Decision
    let outcomes: [Outcome]
    let exportedAt: Date
}
