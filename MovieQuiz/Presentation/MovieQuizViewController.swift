import UIKit

final class MovieQuizViewController: UIViewController,QuestionFactoryDelegate{
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenter?
    private var statisticService:StatisticServiceProtocol?
     let presenter  = MovieQuizPresenter()
    
    private var correctAnswers = 0
    private var movieLoader: MoviesLoading = MoviesLoader()
    
    override func viewDidLoad(){
        print(NSHomeDirectory())
        UserDefaults.standard.set(true, forKey: "viewDidLoad")
                
                
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        delegating()
        showLoadingIndicator()
        questionFactory?.loadData()
     
        presenter.viewController = self
        
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
           presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
       }
    
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
     presenter.noButtonClicked()
    
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
        
        
    }
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
        
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    private func disableButton(button: UIButton) {
        button.isEnabled = false
    }
    
    private func enableButton(button: UIButton) {
        button.isEnabled = true
    }

    
    private func show(quiz result: QuizResultsViewModel) {
        statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
        let alertModel = AlertModel(
                    title: result.title,
                    message: result.text,
                    buttonText: result.buttonText) { [weak self] in
                        guard let self = self else { return }
                      
                        
                    }
        alertPresenter?.showAlert(model: alertModel, id: "Game result")
        
    }
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
     func showAnswerResult(isCorrect: Bool) {
        if isCorrect { // 1
            correctAnswers += 1 // 2
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self]  in
            guard let self = self else {return}
            
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        
        if presenter.isLastQuestion() {
            var text =  "Ваш результат \(correctAnswers)/\(presenter.questionsAmount)\n"
            if let statisticService = statisticService{
                statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
                text = "Ваш результат \(correctAnswers)/\(presenter.questionsAmount)\nКоличество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString)\nСредняя точность \(String(format: "%.2f", statisticService.totalAccuracy))%"
            }
            
            
            let  viewModel = QuizResultsViewModel( // 2
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel) // 3
        }
        else {
            presenter.switchToNextQuestion()
            imageView.layer.borderColor = UIColor.clear.cgColor
            questionFactory?.requestNextQuestion()
        }
    }

    private func delegating() {
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        let alertPresenter = AlertPresenter()
        alertPresenter.setup(delegate: self)
        self.alertPresenter = alertPresenter
        statisticService = StatisticService()
    }
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    private func hideLoadingIndicator(){
        activityIndicator.isHidden = true
    }
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.showAlert( model: model, id: nil)
    }
}
