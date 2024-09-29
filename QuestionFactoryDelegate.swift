//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Golovkin Egor on 29.09.2024.
//

import Foundation
protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
    
}
