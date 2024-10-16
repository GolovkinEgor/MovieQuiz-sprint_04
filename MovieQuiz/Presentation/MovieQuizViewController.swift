import UIKit

final class MovieQuizViewController: UIViewController,QuestionFactoryDelegate{
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService:StatisticServiceProtocol?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    override func viewDidLoad(){
        print(NSHomeDirectory())
        UserDefaults.standard.set(true, forKey: "viewDidLoad")

    
        super.viewDidLoad()
        statisticService = StatisticService()
        
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        delegating()
        questionFactory.requestNextQuestion()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true // 2
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer) 
        // 3
        
    }
    
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false // 2
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer) 
        
    }
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
     
        
    }
    private func disableButton(button: UIButton) {
            button.isEnabled = false
        }

        private func enableButton(button: UIButton) {
            button.isEnabled = true
        }
    private  func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")// 4
        return questionStep
    }
    private func show(quiz result: QuizResultsViewModel) {
        let alert = AlertModel(
            title: result.title,
            message: result.text,
            buttonText:  result.buttonText){[weak self] in
                
                guard let self = self else {return}
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
                
            }
        alertPresenter?.showAlert(model: alert)
        
    }
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    private func showAnswerResult(isCorrect: Bool) {
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
        
        if currentQuestionIndex == questionsAmount - 1 {
            var text =  "Ваш результат \(correctAnswers)/\(questionsAmount)\n"
            if let statisticService = statisticService{
                statisticService.store(correct: correctAnswers, total: questionsAmount)
                text = "Ваш результат \(correctAnswers)/\(questionsAmount)\nКоличество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString)\nСредняя точность \(String(format: "%.2f", statisticService.totalAccuracy))%" 
            }
            
        
            let  viewModel = QuizResultsViewModel( // 2
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel) // 3
        } else {
            currentQuestionIndex += 1
            imageView.layer.borderColor = UIColor.clear.cgColor
            questionFactory?.requestNextQuestion()
        }
        }
    private func delegating() {
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        let alertPresenter = AlertPresenter()
        alertPresenter.setup(delegate: self)
        self.alertPresenter = alertPresenter
    }
}
