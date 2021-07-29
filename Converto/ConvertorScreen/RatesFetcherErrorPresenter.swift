protocol RatesFetcherErrorView {
    func display(errorMessage: String)
}

final class RatesFetcherErrorPresenter {

    var erorrView: RatesFetcherErrorView?
    
    func show(error: ApiRequest.Error) {
        switch error {
        case .connectivity:
            erorrView?.display(errorMessage: "Can't connect to network")
        case .decodingFailure:
            erorrView?.display(errorMessage: "Something went wrong")
        }
    }
}
