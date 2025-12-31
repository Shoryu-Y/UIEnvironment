import Foundation
import os

#if DEBUG
    enum Logger {
        @available(iOS 14, *)
        static let logger = os.Logger()

        static func warning(_ message: String) {
            if #available(iOS 14, *) {
                logger.warning("\(message)")
            } else {
                print(message)
            }
        }
    }
#endif
