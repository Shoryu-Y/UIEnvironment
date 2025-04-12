import UIEnvironment
import UIKit

final class NextViewController: UIViewController {
    @UIEnvironment(\.theme) private var theme: Theme

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = theme.backgroundColor

        let titleLabel = UILabel()
        titleLabel.font = theme.titleFont
        titleLabel.text = "Next"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        var configuration = UIButton.Configuration.plain()
        configuration.title = "Next"
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(
            .init { [weak self] _ in
                self?.navigationController?.pushViewController(FinalViewController(), animated: true)
            },
            for: .touchUpInside
        )

        let stackView = UIStackView(arrangedSubviews: [titleLabel, button])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.heightAnchor.constraint(lessThanOrEqualToConstant: 100),
        ])
    }
}
