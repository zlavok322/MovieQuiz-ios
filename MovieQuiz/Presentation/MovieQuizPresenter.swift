//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Слава Шестаков on 05.12.2022.
//

import UIKit

final class MovieQuizPresenter: UIViewController {
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    private var currentQuestionIndex: Int = 0
    let questionsAmount: Int = 10
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
