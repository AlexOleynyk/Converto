import Foundation

func simulateNetworkDelay(delayInSeconds: TimeInterval = 1, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
        completion()
    }
}
