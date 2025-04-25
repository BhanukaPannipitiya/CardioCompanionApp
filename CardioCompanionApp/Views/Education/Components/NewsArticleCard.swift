import SwiftUI

struct NewsArticleCard: View {
    let article: NewsArticle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.headline)
                .foregroundColor(.white)
            
            if let description = article.description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }
            
            HStack {
                Text(article.sourceName)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                Text(article.publishedDate, style: .date)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding()
        .background(Color.blue)
        .cornerRadius(12)
    }
} 