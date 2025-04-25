import Foundation

class NewsService {
    static let shared = NewsService()
    private let apiKey = "226de3d264f64973a2d016c0a3eb48fd"
    private let baseURL = "https://newsapi.org/v2"
    
    private init() {}
    
    func fetchCardiologyNews(completion: @escaping (Result<[NewsArticle], Error>) -> Void) {
        let queryItems = [
            URLQueryItem(name: "q", value: "cardiology OR heart health OR cardiac surgery"),
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "sortBy", value: "publishedAt")
        ]
        
        var urlComponents = URLComponents(string: "\(baseURL)/everything")!
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let response = try decoder.decode(NewsResponse.self, from: data)
                completion(.success(response.articles))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct NewsResponse: Codable {
    let articles: [NewsArticle]
}

struct NewsArticle: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String?
    let url: URL
    let publishedAt: Date
    let source: Source
    
    struct Source: Codable {
        let name: String
    }
    
    var publishedDate: Date {
        publishedAt
    }
    
    var sourceName: String {
        source.name
    }
} 