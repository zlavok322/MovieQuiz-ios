//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Слава Шестаков on 02.11.2022.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    
    weak var delegate: QuestionFactoryDelegate?
    
    private var movies: [MostPopularMovie] = []
    
    private enum RandomRating: CaseIterable {
        case more
        case lower
    }
    
    private enum ApiKeyError: Error {
        case errorMessage(String)
        case imageError(String)
    }
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    let errorMessage = mostPopularMovies.errorMessage
                    if errorMessage.isEmpty {
                        self.movies = mostPopularMovies.items
                        self.delegate?.didLoadDataFromServer()
                    } else {
                        self.delegate?.didFailToLoadData(with: ApiKeyError.errorMessage(errorMessage))
                    }
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async {
                    let imageError = "Unable to load image"
                    self.delegate?.didFailToLoadData(with: ApiKeyError.imageError(imageError))
                }
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let randomRating: Int = .random(in: 5...9)
            
            let valueRating: RandomRating = .allCases.randomElement()!
            
            let text: String
            let correctAnswer: Bool
            
            switch valueRating {
            case .more:
                text = "Рейтинг этого фильма больше чем \(randomRating)?"
                correctAnswer = Int(rating) >= randomRating
            case .lower:
                text = "Рейтинг этого фильма меньше чем \(randomRating)?"
                correctAnswer = Int(rating) < randomRating
            }
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
} 
