//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Golovkin Egor on 30.09.2024.
//

import Foundation
struct AlertModel{
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}