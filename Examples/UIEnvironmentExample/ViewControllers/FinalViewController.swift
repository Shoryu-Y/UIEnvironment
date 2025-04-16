import UIEnvironment
import SwiftUI
import UIKit

final class FinalViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let childViewController = ChildViewController()
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false

        addChild(childViewController)
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

    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Final"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

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

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        view.backgroundColor = theme.backgroundColor
        titleLabel.font = theme.titleFont
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        view.backgroundColor = theme.backgroundColor
//        titleLabel.font = theme.titleFont
//    }
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
