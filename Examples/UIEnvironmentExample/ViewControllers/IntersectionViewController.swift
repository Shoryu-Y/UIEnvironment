import UIEnvironment
import UIKit

final class IntersectionViewController: UIViewController {
    @UIEnvironment(\.theme) private var theme

    let titleLabel = UILabel()

    let themeEditButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit Theme", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        environment(\.theme, Theme(
            title: "Intersection",
            titleFont: .boldSystemFont(ofSize: 24),
            backgroundColor: .secondarySystemBackground
        ))

        view.backgroundColor = theme.backgroundColor

        titleLabel.font = theme.titleFont
        titleLabel.text = theme.title

        var configuration = UIButton.Configuration.plain()
        configuration.title = "Next"
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(
            .init { [weak self] _ in
                self?.navigationController?.pushViewController(NextViewController(), animated: true)
            },
            for: .touchUpInside
        )

        themeEditButton.addAction(
            .init { [weak self]_ in
                let viewController = ThemeEditModalViewController()
                viewController.onEndEditing = { [weak self] theme in
                    self?.environment(\.theme, theme)
                }
                self?.presentWithEnvironment(viewController, animated: true)
            },
            for: .touchUpInside
        )

        let stackView = UIStackView(arrangedSubviews: [titleLabel, button, themeEditButton])
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        view.backgroundColor = theme.backgroundColor
    }
}
