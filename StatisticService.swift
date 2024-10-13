
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Golovkin Egor on 06.10.2024.
//

import Foundation
// Расширяем при объявлении
final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case correctAnswer
        case bestGame
        case gamesCount
    }
    enum BestGame{
        case correct
        case total
        case date
    }
    var gamesCount: Int{
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue,forKey:  Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult{
        get{
            let correct = storage.integer(forKey: Keys.bestGame.rawValue)
            let total = storage.integer(forKey: Keys.bestGame.rawValue)
            let data = storage.object(forKey: Keys.bestGame.rawValue)as? Date ?? Date()
            let best = GameResult(correct:  correct, total: total, date:  data)
            return best
            
        }
        set{
            storage.set(newValue.correct, forKey: Keys.bestGame.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGame.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGame.rawValue)
            
        }
    }
    private var correctAnswers: Int{
        get{
            storage.integer(forKey: Keys.correctAnswer.rawValue)
        }
        set{
            storage.set(newValue, forKey: Keys.correctAnswer.rawValue)
        }
    }
    
    var totalAccuracy: Double{
        if correctAnswers > 0  && gamesCount>0{
            return (Double(correctAnswers))/(Double(gamesCount))*10
                    }
        else{
            return 0
        }
            
        
        }
    
    
    func store(correct count: Int, total amount: Int) {
        correctAnswers += count
        gamesCount += 1
        let newGame = GameResult(correct: count, total: amount, date: Date())
        if newGame.isBetterThan(bestGame){
            bestGame = newGame
          
        }
    }
    
  
}

