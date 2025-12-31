import UIEnvironment
import UIKit

final class ThemeEditModalViewController: UIViewController {
    @UIEnvironment(\.theme) private var theme

    var onEndEditing: ((Theme) -> Void)?

    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Edit Theme.title"
        textField.textColor = .black
        return textField
    }()

    let colorPickerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Pick Theme.backgroundColor", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        textField.delegate = self

        colorPickerButton.addAction(
            .init { [weak self] _ in
                guard let self else { return }

                let viewController = UIColorPickerViewController()
                viewController.delegate = self
                self.present(viewController, animated: true)
            },
            for: .touchUpInside
        )

        let stackView = UIStackView(arrangedSubviews: [
            textField,
            colorPickerButton
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center

        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

extension ThemeEditModalViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }

        var theme = theme
        theme.title = text

        onEndEditing?(theme)
    }
}

extension ThemeEditModalViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        var theme = theme
        theme.backgroundColor = color
        onEndEditing?(theme)
    }
}
