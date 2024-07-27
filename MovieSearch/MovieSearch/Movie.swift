import Foundation

struct MovieResponse: Codable {
    let Search: [Movie]
}

struct Movie: Codable {
    let Title: String
    let Year: String
    let imdbID: String
    let Poster: String
    let imdbRating: String?
    let Plot: String?
}
