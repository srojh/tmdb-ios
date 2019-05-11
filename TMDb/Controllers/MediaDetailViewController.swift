//
//  MediaDetailViewController.swift
//  TMDb
//
//  Created by Santiago Rojas on 5/4/19.
//  Copyright © 2019 Santiago Rojas. All rights reserved.
//

import UIKit
import Kingfisher

class MediaDetailViewController: UIViewController {
    
    let activityView = UIActivityIndicatorView(style: .gray)
    let fadeView = UIView()
    
    var mediaType: TMDbMediaType!
    var mediaData: MediaListResult!
    var media: Media!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var mediaImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDetailedData() {
            DispatchQueue.main.async {
                guard let view = self.view as? MediaDetailView else {
                    return
                }
                view.mediaImage.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/w500\(self.media.posterPath ?? "")"), placeholder: UIImage(named: "Media Placeholder"))
                view.backdropImage.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/original\(self.media.backdropPath ?? "")"))
                self.descriptionLabel.text = self.media.overview
                let genres = self.media.genres
                if !genres.isEmpty {
                    var genreString = ""
                    genres.forEach { genreString += "\($0.name), "}
                    genreString.removeLast()
                    genreString.removeLast()
                    view.genresLabel.text = genreString
                }
                else { view.genresLabel.text = nil }
                
                
                let productionCompanies = self.media.productionCompanies
                if !productionCompanies.isEmpty {
                    view.productionCompaniesLabel.text = productionCompanies[0].name
                } else {
                    view.productionCompaniesLabel.text = nil
                }
                view.averageScoreLabel.text = "\( self.media.voteAverage) ★"
                view.voteCountLabel.text = "\(self.media.voteCount) " + "Votes".localizedString
                view.popularityLabel.text = String(format:"%.1f",self.media.popularity.value ?? "No data".localizedString)
                if self.mediaType == .movie, let media = self.media as? Movie {
                    view.dateLabel.text = String(media.releaseDate?.split(separator: "-")[0] ?? "")
                    if !media.spokenLanguages.isEmpty {
                        view.originalLanguageLabel.text = media.spokenLanguages[0].name
                    }
                    view.runtimeLabel.text = "\(media.runtime.value ?? 0) min"
                    view.seasonsSection.isHidden = true
                    view.episodesSection.isHidden = true
                } else if self.mediaType == .tvShow, let media = self.media as? TVShow {
                    view.dateLabel.text = media.status
                    view.originalLanguageLabel.text = media.originalLanguage
                    if !media.episodeRunTime.isEmpty {
                        view.runtimeLabel.text = "\(media.episodeRunTime[0]) min"
                    } else {view.runtimeLabel.text = "?"}
                    
                    view.seasonsLabel.text = "\(media.numberOfSeasons.value ?? 0)"
                    view.episodesLabel.text = "\(media.numberOfEpisodes.value ?? 0)"
                }
                
                UIView.animate(withDuration: 1, delay: 1, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                    self.fadeView.alpha = 0
                    self.activityView.stopAnimating()
                    self.fadeView.removeFromSuperview()
                }, completion: nil)
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = mediaData.title ?? mediaData.name
        
        if media == nil {
            fadeView.frame = view.frame
            fadeView.backgroundColor = UIColor(named: "Background")
            fadeView.alpha = 1
            
            view.addSubview(fadeView)
            view.addSubview(activityView)
            activityView.hidesWhenStopped = true
            activityView.center = view.center
            activityView.color = UIColor(named: "Main")
            activityView.startAnimating()
        }
    }
    
    private func getDetailedData(completionHandler: @escaping () -> Void) {
        TMDbServices.shared.getMediaDetail(mediaType: mediaType, id: mediaData.id) { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    let title = "Warning".localizedString
                    let action = UIAlertAction(title: "OK".localizedString, style: .default)
                    let alertController = UIAlertController(title: title, message: error.reason, preferredStyle: .alert)
                    alertController.addAction(action)
                    self.present(alertController, animated: true)
                }
            case .success(let response):
                self.media = response
                completionHandler()
            }
        }
    }
    
    @IBAction func expandDescription(_ sender: UIButton) {
        if descriptionLabel.numberOfLines == 0 {
            sender.setTitle("more".localizedString, for: .normal)
            descriptionLabel.numberOfLines = 3
        } else {
            sender.setTitle("less".localizedString, for: .normal)
            descriptionLabel.numberOfLines = 0
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
