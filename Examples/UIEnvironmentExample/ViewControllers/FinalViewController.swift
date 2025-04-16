import UIEnvironment
import SwiftUI
import UIKit

final class FinalViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let childViewController = ChildViewController()
        addChild(childViewController)
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            childViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            childViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            childViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

final class ChildViewController: UIViewController {
    @UIEnvironment(\.theme) private var theme

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = theme.backgroundColor

        let titleLabel = UILabel()
        titleLabel.text = "Final"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = theme.titleFont

        var configuration = UIButton.Configuration.plain()
        configuration.title = "Present"
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(
            .init { [weak self] _ in
                self?.presentWithEnvironment(PresentedViewController(), animated: true)
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

final class PresentedViewController: UIViewController {
    @UIEnvironment(\.theme) private var theme

    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Presented"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = theme.backgroundColor
        titleLabel.font = theme.titleFont

        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
