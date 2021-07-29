# Converto App

##  Main Idea: Separation with Clean Architecture

Project widely uses Dependency Injection with initializers and sometimes with Property injection.

## Converter screen composition diagram

![](https://github.com/AlexOleynyk/Converto/blob/master/ReadmeResources/Converto.png)

## Features

- SPM for dependecies
- Own UI layer with separate pachage to ensure reusability for UI components across screens (and teams in future)
- Snapshot tests for UI (**important:** requires iPhone 8 simulator for test run, because snaphot tests are decive-dependent)
- Dark theme support
- SwiftLint integrated
- SwiftGen integrated for Assets 
    - [ ] TODO: Add generation for localization strings
- Project follows Clean arcitechure. This way Data Base or network layer can be rewriten from strach without changes to `Domain` layer. 

## Handling test requirenments

### The addition of a new functionality or an existing change should not require rewriting the entire system

- Project separated into layers, and almost all components follow Single responsibility pronciple. So we can add new behaviour or extend current with ease. For example, last change was made for removing fractions from `JPY` currency, since they do not have "cents" (as far as I know). So this change was done only on `Application level`, without changes to `Domain`. But, this change was possible also on `Domain` level if needed. Since currency and exchange is generic logic, and removing fracions can be treated as app-specific, I decided implement it in `App layer`. 

### Adding new currency should be easy

- `Currency` is a `struct`, so we can add any currency we want. Or fetch them from `backend` in runtime. And since no one component creates `Currency` inside `Domain` layer, is is up to cliend (in out case `Application`) how to use it.  In our case we have custom procession for `JPY` currency as mentioned before. 

### Provide for the possibility of expanding the calculation of a more flexible commission. It is possible to come up with various new rules, for example - every tenth conversion is free, conversion of up to 200 Euros is free of charge etc.

- Project uses `Decorator` pattern to provide polimorphic behaviour and composition to achive higher goals with simple components. We can add new decorator ho handle this behaviour and then add it into composition chaing. For example: 

```swift
final class CountBasedGetExchangeFeeUseCaseDecorator: GetExchangeFeeUseCase {

    private let countFetcher: TransactionCountFetcher
    private let count: Int
    private let decoratee: GetExchangeFeeUseCase

    init(
        countFetcher: TransactionCountFetcher,
        count: Int,
        decoratee: GetExchangeFeeUseCase
    ) {
        self.countFetcher = countFetcher
        self.count = count
        self.decoratee = decoratee
    }

    func get(sourceBalance: Balance, targetBalance: Balance, amount: Decimal, completion: @escaping (Money) -> Void) {
        countFetcher.count(for: targetBalance) { [weak self] count in
            guard let self = self else { return }
            if count % self.count == 0 { return completion(.init(amount: 0, currency: sourceBalance.money.currency)) }
            self.decoratee.get(sourceBalance: sourceBalance, targetBalance: targetBalance, amount: amount, completion: completion)
        }
    }
}

// and then in `ConvertorFeatureComposer`
...
getFeeUseCase: CountBasedGetExchangeFeeUseCaseDecorator(
    countFetcher: countFetcher,
    count: 10,
    decoratee: PercentBasedGetExchangeFeeUseCase(percent: 0.007)
)
...
```

## How to run 

- Open `Converto.xcworkspace`
- Selet `Converto` target
- Wait for SPM to resolve dependencies
- Press run 

### Environment used for development

Xcode 12.5
Swift 5
