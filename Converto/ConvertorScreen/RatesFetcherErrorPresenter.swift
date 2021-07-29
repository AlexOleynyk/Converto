protocol RatesFetcherErrorView {
    func display(errorMessage: String)
}

final class RatesFetcherErrorPresenter {

    var errorView: RatesFetcherErrorView?
    
    func show(error: ApiRequest.Error) {
        switch error {
        case .connectivity:
            errorView?.display(errorMessage: "Can't connect to network")
        case .decodingFailure:
            errorView?.display(errorMessage: "Something went wrong")
        }
    }
}
