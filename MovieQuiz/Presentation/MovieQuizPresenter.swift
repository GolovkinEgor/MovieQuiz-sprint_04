//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Golovkin Egor on 11.11.2024.
//
import UIKit
import Foundation
final class MovieQuizPresenter {
    let questionsAmount: Int = 10
     var correctAnswers = 0
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
       weak var viewController: MovieQuizViewController?
    private var statisticService:StatisticServiceProtocol?
     var questionFactory: QuestionFactoryProtocol?
       
       func yesButtonClicked() {
           didAnswer(isYes: true)
       }
    func noButtonClicked() {
            didAnswer(isYes: false)
        }
    private func didAnswer(isYes : Bool){
        guard let currentQuestion = currentQuestion else{
            return
        }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
    }
        
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
        
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
     func showNextQuestionOrResults() {
        
        if self.isLastQuestion() {
            var text =  "Ваш результат \(correctAnswers)/\(self.questionsAmount)\n"
            if let statisticService = statisticService{
                statisticService.store(correct: correctAnswers, total: self.questionsAmount)
                text = "Ваш результат \(correctAnswers)/\(self.questionsAmount)\nКоличество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString)\nСредняя точность \(String(format: "%.2f", statisticService.totalAccuracy))%"
            }
            
            
            let  viewModel = QuizResultsViewModel( // 2
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel) // 3
        }
        else {
            self.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
    }
}
