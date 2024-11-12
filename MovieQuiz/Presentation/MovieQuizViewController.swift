import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var movieLoader: MoviesLoading = MoviesLoader()
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenterProtocol?

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        firstSetup()
        showLoadingIndicator()
        
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
        
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
        
    }
    
    
    func highLightImageBorder(isCorrectAnswer: Bool) {
        // рисуем рамку
        imageView.layer.masksToBounds = true
        // толщина рамки
        imageView.layer.borderWidth = 8
        // изменение цвета
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        // скругление углов
        imageView.layer.cornerRadius = 20
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    
    // метод для показа результатов раунда квиза
     func show(quiz result: QuizResultsViewModel) {
        
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText) { [weak self] in
                guard let self = self else { return }
              
                self.presenter?.restartGame()
            }
         alertPresenter?.showAlert(model: alertModel, id: "Game result")
    }
    
    // настройка делегатов
    private func firstSetup() {
        presenter = MovieQuizPresenter(viewController: self)
        let alertPresenter = AlertPresenter()
        alertPresenter.setup(delegate: self)
        self.alertPresenter = alertPresenter
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            showLoadingIndicator()
            // пробуем еще раз загрузить данные
            self.presenter?.reloadData()
            self.presenter?.restartGame()
        }
        alertPresenter?.showAlert(model: model, id: nil)
    }
    
}
