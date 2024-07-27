import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var movies: [Movie] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchTextField.delegate = self
    }

    @IBAction func searchButtonTapped(_ sender: UIButton) {
        guard let searchText = searchTextField.text, !searchText.isEmpty else { return }
        fetchMovies(searchText: searchText)
        searchTextField.resignFirstResponder()  // Dismiss the keyboard when the search button is tapped
    }

    func fetchMovies(searchText: String) {
        let urlString = "http://www.omdbapi.com/?s=\(searchText)&apikey=29eb3dea"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else { return }
            do {
                let response = try JSONDecoder().decode(MovieResponse.self, from: data)
                self.movies = response.Search
                self.fetchDetailsForMovies()
            } catch {
                print(error)
            }
        }.resume()
    }

    func fetchDetailsForMovies() {
        let group = DispatchGroup()

        for (index, movie) in movies.enumerated() {
            group.enter()
            fetchMovieDetails(imdbID: movie.imdbID) { movieDetails in
                if let movieDetails = movieDetails {
                    self.movies[index] = movieDetails
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }

    func fetchMovieDetails(imdbID: String, completion: @escaping (Movie?) -> Void) {
        let urlString = "http://www.omdbapi.com/?i=\(imdbID)&apikey=29eb3dea"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else { return }
            do {
                let movieDetails = try JSONDecoder().decode(Movie.self, from: data)
                DispatchQueue.main.async {
                    completion(movieDetails)
                }
            } catch {
                print(error)
                completion(nil)
            }
        }.resume()
    }

    // UITableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableViewCell
        let movie = movies[indexPath.row]
        cell.titleLabel.text = movie.Title
        cell.yearLabel.text = "Release year: \(movie.Year)"
        cell.ratingLabel.text = "Rating: \(movie.imdbRating ?? "N/A")"

        if let posterURL = URL(string: movie.Poster) {
            URLSession.shared.dataTask(with: posterURL) { (data, response, error) in
                if let data = data, error == nil {
                    DispatchQueue.main.async {
                        cell.posterImageView.image = UIImage(data: data)
                        
                    }
                }
            }.resume()
        } else {
            cell.posterImageView.image = nil
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let movie = movies[indexPath.row]
            fetchMovieDetails(imdbID: movie.imdbID) { movieDetails in
                guard let movieDetails = movieDetails else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.performSegue(withIdentifier: "showDetails", sender: movieDetails)
                }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            if let detailsVC = segue.destination as? DetailsViewController, let movie = sender as? Movie {
                detailsVC.movie = movie
                
            }
        }
    }

    // UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  // Dismiss the keyboard
        return true
    }
}
