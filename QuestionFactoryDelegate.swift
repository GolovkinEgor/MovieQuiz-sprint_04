//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Golovkin Egor on 29.09.2024.
//

import Foundation
protocol QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
