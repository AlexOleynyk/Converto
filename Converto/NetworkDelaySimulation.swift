import Foundation

func simulateNetworkDelay(
    delayInSeconds: TimeInterval = .random(in: 0.5...1.5),
    completion: @escaping () -> Void
) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
        completion()
    }
}
