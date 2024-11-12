import UIKit

final class MovieQuizViewController: UIViewController,QuestionFactoryDelegate{
    let presenter  = MovieQuizPresenter()
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    private var questionFactory: QuestionFactoryProtocol?
    
    
    private var alertPresenter: AlertPresenter?
    private var statisticService:StatisticServiceProtocol?
    
    
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
        
        presenter.yesButtonClicked()
    }
    
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        
        presenter.noButtonClicked()
        
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
    
    
    func show(quiz result: QuizResultsViewModel) {
        statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText) { [weak self] in
                guard let self = self else { return }
                
                
            }
        alertPresenter?.showAlert(model: alertModel, id: "Game result")
        
    }
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    func showAnswerResult(isCorrect: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }
        func showNextQuestionOrResults() {
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

