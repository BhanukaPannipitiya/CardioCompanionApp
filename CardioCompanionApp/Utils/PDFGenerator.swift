import Foundation
import PDFKit
import UIKit

class PDFGenerator {
    static func generateHealthReport(
        healthScore: Int,
        currentStreak: Int,
        improvement: Int,
        heartRate: Double,
        oxygenLevel: Double,
        bloodPressure: String,
        symptomData: [SymptomOccurrence],
        startDate: Date,
        endDate: Date
    ) -> Data? {
        // Create PDF document
        let pdfMetaData = [
            kCGPDFContextCreator: "CardioCompanion",
            kCGPDFContextAuthor: "CardioCompanion Health Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            let titleBottom = addTitle(pageRect: pageRect)
            let dateBottom = addDateRange(pageRect: pageRect, top: titleBottom, startDate: startDate, endDate: endDate)
            let scoreBottom = addHealthScore(pageRect: pageRect, top: dateBottom, score: healthScore, streak: currentStreak, improvement: improvement)
            let vitalsBottom = addVitalSigns(pageRect: pageRect, top: scoreBottom, heartRate: heartRate, oxygenLevel: oxygenLevel, bloodPressure: bloodPressure)
            let symptomsBottom = addSymptoms(pageRect: pageRect, top: vitalsBottom, symptoms: symptomData)
            addRecommendations(pageRect: pageRect, top: symptomsBottom)
        }
        
        return data
    }
    
    private static func addTitle(pageRect: CGRect) -> CGFloat {
        let titleFont = UIFont.boldSystemFont(ofSize: 24.0)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont
        ]
        let attributedTitle = NSAttributedString(
            string: "Health Report",
            attributes: titleAttributes
        )
        let titleStringSize = attributedTitle.size()
        let titleStringRect = CGRect(
            x: (pageRect.width - titleStringSize.width) / 2.0,
            y: 36,
            width: titleStringSize.width,
            height: titleStringSize.height
        )
        attributedTitle.draw(in: titleStringRect)
        
        return titleStringRect.maxY
    }
    
    private static func addDateRange(pageRect: CGRect, top: CGFloat, startDate: Date, endDate: Date) -> CGFloat {
        let dateFont = UIFont.systemFont(ofSize: 14.0)
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: dateFont
        ]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let dateString = "Period: \(dateFormatter.string(from: startDate)) to \(dateFormatter.string(from: endDate))"
        let attributedDate = NSAttributedString(
            string: dateString,
            attributes: dateAttributes
        )
        let dateStringSize = attributedDate.size()
        let dateStringRect = CGRect(
            x: (pageRect.width - dateStringSize.width) / 2.0,
            y: top + 20,
            width: dateStringSize.width,
            height: dateStringSize.height
        )
        attributedDate.draw(in: dateStringRect)
        
        return dateStringRect.maxY
    }
    
    private static func addHealthScore(pageRect: CGRect, top: CGFloat, score: Int, streak: Int, improvement: Int) -> CGFloat {
        let sectionTop = top + 40
        let font = UIFont.systemFont(ofSize: 16.0)
        let boldFont = UIFont.boldSystemFont(ofSize: 16.0)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: boldFont
        ]
        
        // Health Score
        let scoreTitle = NSAttributedString(
            string: "Overall Health Score: ",
            attributes: boldAttributes
        )
        let scoreValue = NSAttributedString(
            string: "\(score)",
            attributes: textAttributes
        )
        
        let scoreTitleRect = CGRect(
            x: 72,
            y: sectionTop,
            width: scoreTitle.size().width,
            height: scoreTitle.size().height
        )
        let scoreValueRect = CGRect(
            x: scoreTitleRect.maxX,
            y: sectionTop,
            width: scoreValue.size().width,
            height: scoreValue.size().height
        )
        
        scoreTitle.draw(in: scoreTitleRect)
        scoreValue.draw(in: scoreValueRect)
        
        // Streak
        let streakTitle = NSAttributedString(
            string: "Current Streak: ",
            attributes: boldAttributes
        )
        let streakValue = NSAttributedString(
            string: "\(streak) days",
            attributes: textAttributes
        )
        
        let streakTitleRect = CGRect(
            x: 72,
            y: sectionTop + 24,
            width: streakTitle.size().width,
            height: streakTitle.size().height
        )
        let streakValueRect = CGRect(
            x: streakTitleRect.maxX,
            y: sectionTop + 24,
            width: streakValue.size().width,
            height: streakValue.size().height
        )
        
        streakTitle.draw(in: streakTitleRect)
        streakValue.draw(in: streakValueRect)
        
        // Improvement
        let improvementTitle = NSAttributedString(
            string: "Improvement: ",
            attributes: boldAttributes
        )
        let improvementValue = NSAttributedString(
            string: "\(improvement)% this month",
            attributes: textAttributes
        )
        
        let improvementTitleRect = CGRect(
            x: 72,
            y: sectionTop + 48,
            width: improvementTitle.size().width,
            height: improvementTitle.size().height
        )
        let improvementValueRect = CGRect(
            x: improvementTitleRect.maxX,
            y: sectionTop + 48,
            width: improvementValue.size().width,
            height: improvementValue.size().height
        )
        
        improvementTitle.draw(in: improvementTitleRect)
        improvementValue.draw(in: improvementValueRect)
        
        return improvementValueRect.maxY
    }
    
    private static func addVitalSigns(pageRect: CGRect, top: CGFloat, heartRate: Double, oxygenLevel: Double, bloodPressure: String) -> CGFloat {
        let sectionTop = top + 40
        let font = UIFont.systemFont(ofSize: 16.0)
        let boldFont = UIFont.boldSystemFont(ofSize: 16.0)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: boldFont
        ]
        
        // Section Title
        let sectionTitle = NSAttributedString(
            string: "Vital Signs Summary",
            attributes: boldAttributes
        )
        let sectionTitleRect = CGRect(
            x: 72,
            y: sectionTop,
            width: sectionTitle.size().width,
            height: sectionTitle.size().height
        )
        sectionTitle.draw(in: sectionTitleRect)
        
        // Heart Rate
        let heartRateTitle = NSAttributedString(
            string: "Heart Rate: ",
            attributes: boldAttributes
        )
        let heartRateValue = NSAttributedString(
            string: "\(Int(heartRate)) BPM",
            attributes: textAttributes
        )
        
        let heartRateTitleRect = CGRect(
            x: 72,
            y: sectionTop + 24,
            width: heartRateTitle.size().width,
            height: heartRateTitle.size().height
        )
        let heartRateValueRect = CGRect(
            x: heartRateTitleRect.maxX,
            y: sectionTop + 24,
            width: heartRateValue.size().width,
            height: heartRateValue.size().height
        )
        
        heartRateTitle.draw(in: heartRateTitleRect)
        heartRateValue.draw(in: heartRateValueRect)
        
        // Oxygen Level
        let oxygenTitle = NSAttributedString(
            string: "Oxygen Level: ",
            attributes: boldAttributes
        )
        let oxygenValue = NSAttributedString(
            string: "\(Int(oxygenLevel))%",
            attributes: textAttributes
        )
        
        let oxygenTitleRect = CGRect(
            x: 72,
            y: sectionTop + 48,
            width: oxygenTitle.size().width,
            height: oxygenTitle.size().height
        )
        let oxygenValueRect = CGRect(
            x: oxygenTitleRect.maxX,
            y: sectionTop + 48,
            width: oxygenValue.size().width,
            height: oxygenValue.size().height
        )
        
        oxygenTitle.draw(in: oxygenTitleRect)
        oxygenValue.draw(in: oxygenValueRect)
        
        // Blood Pressure
        let bpTitle = NSAttributedString(
            string: "Blood Pressure: ",
            attributes: boldAttributes
        )
        let bpValue = NSAttributedString(
            string: "\(bloodPressure) mmHg",
            attributes: textAttributes
        )
        
        let bpTitleRect = CGRect(
            x: 72,
            y: sectionTop + 72,
            width: bpTitle.size().width,
            height: bpTitle.size().height
        )
        let bpValueRect = CGRect(
            x: bpTitleRect.maxX,
            y: sectionTop + 72,
            width: bpValue.size().width,
            height: bpValue.size().height
        )
        
        bpTitle.draw(in: bpTitleRect)
        bpValue.draw(in: bpValueRect)
        
        return bpValueRect.maxY
    }
    
    private static func addSymptoms(pageRect: CGRect, top: CGFloat, symptoms: [SymptomOccurrence]) -> CGFloat {
        let sectionTop = top + 40
        let font = UIFont.systemFont(ofSize: 16.0)
        let boldFont = UIFont.boldSystemFont(ofSize: 16.0)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: boldFont
        ]
        
        // Section Title
        let sectionTitle = NSAttributedString(
            string: "Symptoms Summary",
            attributes: boldAttributes
        )
        let sectionTitleRect = CGRect(
            x: 72,
            y: sectionTop,
            width: sectionTitle.size().width,
            height: sectionTitle.size().height
        )
        sectionTitle.draw(in: sectionTitleRect)
        
        var currentY = sectionTop + 24
        
        for symptom in symptoms {
            let symptomText = NSAttributedString(
                string: "\(symptom.name): \(symptom.count) occurrences",
                attributes: textAttributes
            )
            
            let symptomRect = CGRect(
                x: 72,
                y: currentY,
                width: symptomText.size().width,
                height: symptomText.size().height
            )
            
            symptomText.draw(in: symptomRect)
            currentY += 24
        }
        
        return currentY
    }
    
    private static func addRecommendations(pageRect: CGRect, top: CGFloat) {
        let sectionTop = top + 40
        let font = UIFont.systemFont(ofSize: 16.0)
        let boldFont = UIFont.boldSystemFont(ofSize: 16.0)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: boldFont
        ]
        
        // Section Title
        let sectionTitle = NSAttributedString(
            string: "Recommendations",
            attributes: boldAttributes
        )
        let sectionTitleRect = CGRect(
            x: 72,
            y: sectionTop,
            width: sectionTitle.size().width,
            height: sectionTitle.size().height
        )
        sectionTitle.draw(in: sectionTitleRect)
        
        // Recommendations
        let recommendations = [
            "Continue Regular Monitoring: Keep monitoring your vital signs daily for optimal health tracking",
            "Consult with Doctor: Schedule a follow-up appointment to discuss your blood pressure readings",
            "Stay Hydrated: Increase water intake to help with your occasional headaches"
        ]
        
        var currentY = sectionTop + 24
        
        for recommendation in recommendations {
            let recommendationText = NSAttributedString(
                string: "• \(recommendation)",
                attributes: textAttributes
            )
            
            let recommendationRect = CGRect(
                x: 72,
                y: currentY,
                width: pageRect.width - 144,
                height: 100
            )
            
            recommendationText.draw(in: recommendationRect)
            currentY += 48
        }
    }
} 