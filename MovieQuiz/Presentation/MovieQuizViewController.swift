import UIKit

final class MovieQuizViewController: UIViewController{
    
    
     var presenter : MovieQuizPresenter!
    
    
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    private var questionFactory: QuestionFactoryProtocol?
    
    
    private var alertPresenter: AlertPresenter?
    private var statisticService:StatisticServiceProtocol?
    
    
   
    private var movieLoader: MoviesLoading = MoviesLoader()
    
    override func viewDidLoad(){
        print(NSHomeDirectory())
        UserDefaults.standard.set(true, forKey: "viewDidLoad")
        
        
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        
        statisticService = StatisticService()
     
        
        
        
       
        presenter = MovieQuizPresenter(viewController: self)
        
    }
    
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
    
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
    func highLightImageBorder(isCorrect: Bool) {
          
           imageView.layer.masksToBounds = true
           
           imageView.layer.borderWidth = 8
           
           imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
           
           imageView.layer.cornerRadius = 20
       }
    
   
    
    private func disableButton(button: UIButton) {
        button.isEnabled = false
    }
    
    private func enableButton(button: UIButton) {
        button.isEnabled = true
    }
    
    
    func show(quiz result: QuizResultsViewModel) {
            
            let alertModel = AlertModel(
                title: result.title,
                message: result.text,
                buttonText: result.buttonText) { [weak self] in
                    guard let self = self else { return }
                  
                    self.presenter.restartGame()
                }
        alertPresenter?.showAlert(model: alertModel, id: "Game result")
        }
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
     func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isYes: isCorrect)
        highLightImageBorder(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            
            self.presenter.showNextQuestionOrResults()
        }
    }
        func showNextQuestionOrResults() {
            if presenter.isLastQuestion() {
                var text =  "Ваш результат \(presenter.correctAnswers)/\(presenter.questionsAmount)\n"
                if let statisticService = statisticService{
                    statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
                    text = "Ваш результат \(presenter.correctAnswers)/\(presenter.questionsAmount)\nКоличество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString)\nСредняя точность \(String(format: "%.2f", statisticService.totalAccuracy))%"
                }
                
                
                let  viewModel = QuizResultsViewModel( // 2
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть ещё раз")
                presenter.viewController?.show(quiz: viewModel) // 3
            }
            else {
                self.presenter.switchToNextQuestion()
                
                questionFactory?.requestNextQuestion()
            }
        }
        
        
       
         func showLoadingIndicator() {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
         func hideLoadingIndicator(){
            activityIndicator.isHidden = true
        }
         func showNetworkError(message: String) {
            hideLoadingIndicator()
            
            let model = AlertModel(title: "Ошибка",
                                   message: message,
                                   buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else { return }
                
                self.presenter.resetQuestionIndex()
                self.presenter.correctAnswers = 0
                
                self.questionFactory?.requestNextQuestion()
            }
            
            alertPresenter?.showAlert( model: model, id: nil)
        }
    }

