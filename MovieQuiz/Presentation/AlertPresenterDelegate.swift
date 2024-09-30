//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Golovkin Egor on 30.09.2024.
//

import Foundation
protocol AlertPresenterDelegate: AnyObject{
    func installAlertModel() -> AlertModel
    func ShowNextQuestionOrResult()
    
}
