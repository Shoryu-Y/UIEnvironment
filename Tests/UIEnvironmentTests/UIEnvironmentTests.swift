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

@Test func environmentStackTest() async throws {
    let rootView = await RootViewController()
    let targetView = await TargetViewController()
    let navigationController = await UIEnvironmentNavigationController(rootViewController: rootView)

    // 初期状態：RootViewControllerのみがスタックに存在
    await #expect(rootView.testValue.result == 0)
    await #expect(navigationController.environmentValuesStack.count == 1)
    await #expect(navigationController.topViewController === rootView)

    // RootViewControllerの環境値を設定
    await navigationController.environment(
        \.testValue,
        rootView.testValue.incremented()
    )
    await #expect(rootView.testValue.result == 1)

    // pushViewController時、UIViewControllerに対応した`UIEnvironmentValues`が作成される
    await navigationController.pushViewController(targetView, animated: false)

    // pushViewController後の状態を確認
    await #expect(
        navigationController.topViewController === targetView,
        "pushView後、topViewControllerはTargetViewControllerである"
    )
    await #expect(
        navigationController.environmentValuesStack.count == 2,
        "RootViewControllerとTargetViewControllerの2つのUIEnvironmentValuesが存在する"
    )
    await #expect(rootView.testValue.result == 1)
    await #expect(targetView.testValue.result == 1)

    // 各ViewControllerに対応する環境値が正しく設定されていることを確認
    await #expect(rootView.testValue.result == 1)
    await #expect(targetView.testValue.result == 1)

    // 現在のtopViewController（TargetViewController）に対応した環境値を変更
    await targetView.environment(
        \.testValue,
        navigationController.environmentValues.testValue.incremented()
    )

    // TargetViewControllerの環境値は変更されたが、RootViewControllerの環境値は変更されていない
    await #expect(navigationController.environmentValuesStack[rootView.hash]!.testValue.result == 1)
    await #expect(navigationController.environmentValuesStack[targetView.hash]!.testValue.result == 2)
    await #expect(targetView.testValue.result == 2)
}

@Test func popNavigationTest() async throws {
    let rootView = await RootViewController()
    let targetView = await TargetViewController()
    let navigationController = await UIEnvironmentNavigationController(rootViewController: rootView)

    // 2つのViewControllerをpush
    await navigationController.pushViewController(targetView, animated: false)

    // 環境値を異なる値に設定
    await navigationController.environment(\.testValue, TestValue(result: 5))

    await #expect(navigationController.environmentValuesStack.count == 2)
    await #expect(navigationController.topViewController === targetView)
    await #expect(targetView.testValue.result == 5)

    let poppedViewController = await navigationController.popViewController(animated: false)
    await navigationController.navigationController(navigationController, didShow: rootView, animated: false)

    #expect(poppedViewController === targetView)
    await #expect(navigationController.topViewController === rootView)
    await #expect(navigationController.environmentValuesStack.count == 1)
    await #expect(rootView.testValue.result == 0)
}
