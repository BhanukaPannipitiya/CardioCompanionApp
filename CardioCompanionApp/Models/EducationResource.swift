import Foundation

enum ResourceCategory: String, Codable, CaseIterable {
    case recovery = "Recovery"
    case nutrition = "Nutrition"
    case exercise = "Exercise"
    case medication = "Medication"
}

enum ResourceType: String, Codable {
    case article = "Article"
    case video = "Video"
    case guide = "Guide"
}

struct EducationResource: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let category: ResourceCategory
    let type: ResourceType
    let isFeatured: Bool
    let imageURL: URL?
    let videoURL: URL?
    let content: String
    
    static let sampleResources = [
        EducationResource(
            id: UUID(),
            title: "First Week After Cardiac Surgery",
            description: "What to expect and how to manage your recovery in the first critical week.",
            category: .recovery,
            type: .guide,
            isFeatured: true,
            imageURL: URL(string: "https://images.unsplash.com/photo-1631815589968-fdb09a223b1e"),
            videoURL: nil,
            content: """
            Recovery after cardiac surgery is a crucial period that requires careful attention and following specific guidelines. Here's what you need to know:

            First 24-48 Hours:
            - Rest is essential
            - Follow breathing exercises
            - Move only as directed by medical staff
            - Report any unusual symptoms

            Days 3-7:
            - Gradually increase activity
            - Continue breathing exercises
            - Take medications as prescribed
            - Monitor your incision site
            - Follow dietary restrictions

            Important Warning Signs:
            - Fever above 100.4°F (38°C)
            - Increased pain or redness at incision site
            - Shortness of breath
            - Irregular heartbeat
            - Excessive sweating

            Contact your healthcare provider immediately if you experience any warning signs.
            """
        ),
        EducationResource(
            id: UUID(),
            title: "Pain Management Techniques",
            description: "Safe and effective ways to manage post-surgical pain",
            category: .recovery,
            type: .article,
            isFeatured: false,
            imageURL: URL(string: "https://images.unsplash.com/photo-1576091160550-2173dba999ef"),
            videoURL: nil,
            content: """
            Managing post-surgical pain effectively is crucial for your recovery. Here are proven techniques:

            1. Medication Management:
               - Take prescribed medications as directed
               - Don't skip doses
               - Keep track of timing

            2. Non-Medication Techniques:
               - Deep breathing exercises
               - Gentle movement
               - Cold/heat therapy
               - Relaxation techniques

            3. Lifestyle Adjustments:
               - Proper positioning
               - Regular rest periods
               - Gradual activity increase

            Always consult your healthcare provider before changing your pain management routine.
            """
        ),
        EducationResource(
            id: UUID(),
            title: "Heart-Healthy Diet Guide",
            description: "Essential nutrition tips for cardiac health",
            category: .nutrition,
            type: .guide,
            isFeatured: false,
            imageURL: URL(string: "https://images.unsplash.com/photo-1490645935967-10de6ba17061"),
            videoURL: nil,
            content: """
            A heart-healthy diet is essential for your recovery and long-term health:

            Key Principles:
            1. Reduce Sodium Intake
               - Limit to 2,000mg per day
               - Avoid processed foods
               - Read food labels carefully

            2. Choose Healthy Fats
               - Use olive oil
               - Eat fatty fish
               - Include nuts and seeds

            3. Increase Fiber Intake
               - Whole grains
               - Fresh vegetables
               - Legumes

            4. Protein Selection
               - Lean meats
               - Fish
               - Plant-based options

            5. Portion Control
               - Use smaller plates
               - Measure servings
               - Listen to hunger cues

            Remember to consult your nutritionist for personalized advice.
            """
        ),
        EducationResource(
            id: UUID(),
            title: "Safe Exercise Routines",
            description: "Recommended exercises for cardiac recovery",
            category: .exercise,
            type: .video,
            isFeatured: false,
            imageURL: URL(string: "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b"),
            videoURL: URL(string: "https://example.com/exercise-video.mp4"),
            content: """
            Exercise is crucial for cardiac recovery, but it must be done safely:

            Phase 1: Initial Recovery
            - Breathing exercises
            - Ankle pumps
            - Light stretching
            - Short walks

            Phase 2: Building Strength
            - Longer walks
            - Light resistance bands
            - Seated exercises
            - Balance training

            Phase 3: Increasing Endurance
            - Extended walking
            - Light cardio
            - Moderate resistance training
            - Flexibility work

            Always:
            - Start slowly
            - Listen to your body
            - Follow medical guidance
            - Stop if you feel unwell

            Track your progress and celebrate small improvements!
            """
        )
    ]
} 