import Testing
@testable import UIEnvironment
import UIKit

struct TestValue: Sendable {
    var result: Int

    func incremented() -> TestValue {
        return TestValue(result: result + 1)
    }
}

extension TestValue: UIEnvironmentKey {
    static let defaultValue = TestValue(result: 0)
}

extension UIEnvironmentValues {
    var testValue: TestValue {
        get { self[TestValue.self] }
        set { self[TestValue.self] = newValue }
    }
}

final class RootViewController: UIViewController {
    @UIEnvironment(\.testValue) var testValue
}

final class TargetViewController: UIViewController {
    @UIEnvironment(\.testValue) var testValue
}

@Test func example() async throws {
    let rootView = await RootViewController()
    let targetView = await TargetViewController()
    let navigationController = await UIEnvironmentNavigationController(rootViewController: rootView)

    await navigationController.environment(
        \.testValue,
         rootView.testValue.incremented()
    )

    await #expect(navigationController.environmentValuesStack.count == 1)
    await #expect(rootView.testValue.result == 1)

    // push時、UIViewControllerに対応した`UIEnvironmentValues`が作成される
    await navigationController.pushViewController(targetView, animated: true)

    // `RootViewController`と`TargetViewController`とで2つの`UIEnvironmentValues`が存在する
    await #expect(navigationController.environmentValuesStack.count == 2)
    await #expect(navigationController.environmentValuesStack[rootView.hash]!.testValue.result == 1)
    await #expect(navigationController.environmentValuesStack[targetView.hash]!.testValue.result == 1)

    // push先である`TargetViewController`に対応した`UIEnvironmentValues`の値を変更しても、push元の`RootViewController`の`UIEnvironmentValues`の値は変更されない
    await navigationController.environment(
        \.testValue,
         navigationController.environmentValues.testValue.incremented()
    )
//    await #expect(navigationController.environmentValuesStack[rootView.hash]!.testValue.result == 1)
//    await #expect(navigationController.environmentValuesStack[targetView.hash]!.testValue.result == 2)
}
