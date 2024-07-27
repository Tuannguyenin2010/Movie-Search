import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var movie: Movie?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Start the activity indicator
        activityIndicator.startAnimating()
        
        // Hide UI elements initially
        titleLabel.isHidden = true
        posterImageView.isHidden = true
        descriptionLabel.isHidden = true
        ratingLabel.isHidden = true
        yearLabel.isHidden = true
        
        // Load movie details
        if let movie = movie {
            titleLabel.text = movie.Title
            ratingLabel.text = movie.imdbRating ?? "N/A"
            yearLabel.text = movie.Year
            descriptionLabel.text = movie.Plot ?? "N/A"
            if let url = URL(string: movie.Poster) {
                downloadImage(from: url) { [weak self] in
                    // Stop the activity indicator and show UI elements
                    self?.activityIndicator.stopAnimating()
                    self?.titleLabel.isHidden = false
                    self?.posterImageView.isHidden = false
                    self?.descriptionLabel.isHidden = false
                    self?.ratingLabel.isHidden = false
                    self?.yearLabel.isHidden = false
                }
            } else {
                // If there's no poster URL, stop the activity indicator and show UI elements
                activityIndicator.stopAnimating()
                titleLabel.isHidden = false
                descriptionLabel.isHidden = false
                ratingLabel.isHidden = false
                yearLabel.isHidden = false
            }
        }
    }

    func downloadImage(from url: URL, completion: @escaping () -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.posterImageView.image = UIImage(data: data)
                completion()
            }
        }.resume()
    }
}
