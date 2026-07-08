import SwiftUI
internal import WebKit
import Combine

enum ACKNavAction {
    case none
    case home
    case back
    case forward
    case reload
}

final class ACKNavigationState: ObservableObject {

    @Published var canGoBack    = false
    @Published var canGoForward = false
    @Published var isLoading    = false
    @Published var lastError: URLError?
    @Published var navAction: ACKNavAction = .none

    weak var webView: WKWebView?
    var homeRequest: URLRequest?
}
