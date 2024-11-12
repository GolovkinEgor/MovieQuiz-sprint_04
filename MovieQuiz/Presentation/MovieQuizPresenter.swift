import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let questionsAmount: Int = 10
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var currentQuestionIndex: Int = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - Public Methods
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // повторная загрузка данных
    func reloadData() {
        questionFactory?.loadData()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
    
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        // скрываем индикатор загрузки
        viewController?.hideLoadingIndicator()
        // показываем следующий вопрос
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    //MARK: - Privates Methods
    
    private func makeResultsMessage() -> String {
        var text = "Ваш результат: \(correctAnswers)/\(self.questionsAmount)\n"
        if let statisticService = statisticService {
            // сохраняем результаты
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            text += """
                    Количество сыгранных квизов: \(statisticService.gamesCount)
                    Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                   """
        }
        return text
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            // идем в состояние "результат квиза"
            let text = makeResultsMessage()
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен",
                text: text,
                buttonText: "Сыграть еще раз")
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            // идем в состояние "следующий вопрос"
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrect: isCorrect)

        viewController?.highLightImageBorder(isCorrectAnswer: isCorrect)
        
        // задержка при показе вопроса 1 сек
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
            
        }
    }
    
    // метод, который подсчитывает правильные ответы
    private func didAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    // метод, проверяющий правильность ответов
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
