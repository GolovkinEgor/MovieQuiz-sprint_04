//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Golovkin Egor on 11.11.2024.
//
import UIKit
import Foundation
final class MovieQuizPresenter:QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
     let questionsAmount: Int = 10
         var correctAnswers: Int = 0
         var currentQuestion: QuizQuestion?
        private var questionFactory: QuestionFactoryProtocol?
        private var statisticService: StatisticServiceProtocol?
         weak var viewController: MovieQuizViewController?
        private var currentQuestionIndex: Int = 0
        
    init(viewController: MovieQuizViewController) {
            self.viewController = viewController
            
            questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            questionFactory?.loadData()
            viewController.showLoadingIndicator()
        }
    func yesButtonClicked() {
           didAnswer(isYes: true)
       }
    func noButtonClicked() {
            didAnswer(isYes: false)
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
    func restartGame(){
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
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
    
        func didAnswer(isCorrect: Bool) {
           if isCorrect {
               correctAnswers += 1
           }
       }
       
       
        func didAnswer(isYes: Bool) {
           guard let currentQuestion = currentQuestion else {
               return
           }
           
           let givenAnswer = isYes
           
           viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
       }
   }

