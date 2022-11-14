import Combine
import UIKit

final class ViewController: UIViewController {

    private var cancellable: Set<AnyCancellable> = []

    // MARK: Outlets
    @IBOutlet var signUpButton: UIButton!

    // MARK: - Actions

    @IBAction func emailDidChange(_ sender: UITextField) {
        emailCurrentValueSubject.send(sender.text ?? "")
    }

    @IBAction func passwordDidChange(_ sender: UITextField) {
        passwordCurrentValueSubject.send(sender.text ?? "")
    }

    @IBAction func passwordConfirmationDidChange(_ sender: UITextField) {
        passwordCurrentSameValueSubject.send(sender.text ?? "")
    }

    @IBAction func agreeSwitchDidChange(_ sender: UISwitch) {
        switchValueSubject.send(sender.isOn)
    }

    @IBAction func signUpTapped(_ sender: UIButton) { showAlert() }

    // MARK: - Subjects

    private let emailCurrentValueSubject = CurrentValueSubject<String, Never>("")
    private let passwordCurrentValueSubject = CurrentValueSubject<String, Never>("")
    private let passwordCurrentSameValueSubject = CurrentValueSubject<String, Never>("")
    private let switchValueSubject = CurrentValueSubject<Bool, Never>(false)

    // MARK: - Publishers

    private var isFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest4(isEmailValidPublisher, isPasswordValidPublisher, isPasswordTheSamePublisher, switchValueSubject)
            .map { $0.0 && $0.1 && $0.2 && $0.3 }
            .eraseToAnyPublisher()
    }

    private var formattedEmailPublisher: AnyPublisher<String, Never> {
        emailCurrentValueSubject
            .map { $0.lowercased() }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .eraseToAnyPublisher()
    }

    private var isEmailValidPublisher: AnyPublisher<Bool, Never> {
        formattedEmailPublisher
            .map { [weak self] in self?.isEmailValid($0) }
            .replaceNil(with: false)
            .eraseToAnyPublisher()
    }

    private var isPasswordValidPublisher: AnyPublisher<Bool, Never> {
        passwordCurrentValueSubject
            .map { $0.count > 8 && $0 != "password" }
            .eraseToAnyPublisher()
    }

    private var isPasswordTheSamePublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(passwordCurrentValueSubject, passwordCurrentSameValueSubject)
            .map { $0.compare($1) == .orderedSame }
            .eraseToAnyPublisher()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        isFormValidPublisher
            .assign(to: \.isEnabled, on: signUpButton)
            .store(in: &cancellable)
    }

    // MARK: - Setups
    // MARK: - Helpers

    private func showAlert() {
        let alert = UIAlertController(title: "Welcome!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func isEmailValid(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }

}
