//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Golovkin Egor on 30.09.2024.
//


import UIKit
class AlertPresenter: AlertPresenterProtocol{
    private weak var delegate : UIViewController?
    
    func showAlert(model: AlertModel){
        let alert = UIAlertController(
            title:  model.title,
            message: model.message,
            preferredStyle: .alert)
        let action = UIAlertAction(title:  model.buttonText, style: .default) {  _  in
            model.completion()
        }
        alert.addAction(action)
        
        delegate?.present(alert, animated: true, completion: nil)
    }
    func setup(delegate: UIViewController){
        self.delegate = delegate
        
    }
}
