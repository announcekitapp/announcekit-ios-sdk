//
//  AKBadgeView.swift
//  AnnounceKit
//
//  Created by Seyfeddin Bassarac on 30.06.2021.
//

import UIKit
import WebKit

public struct AnnounceKitSettings {

    public var widget: String
    public var name: String?
    public var language: String?
    public var user: [String: Any]?
    public var customFields: [String: Any]?

    public init(
        widget: String,
        name: String? = nil,
        language: String? = nil,
        user: [String : Any]? = nil,
        customFields: [String : Any]? = nil
    ) {
        self.widget = widget
        self.name = name
        self.language = language
        self.user = user
        self.customFields = customFields
    }
}

public protocol AnnounceKitDelegate: AnyObject {

    func announceKitView(
        _ client: AnnounceKitClient,
        didInitialize widget: String
    )
    func announceKitView(
        _ client: AnnounceKitClient,
        didInitializeWidget widget: String
    )
    func announceKitView(
        _ client: AnnounceKitClient,
        didOpenWidget widget: String
    )
    func announceKitView(
        _ client: AnnounceKitClient,
        didCloseWidget widget: String
    )
    func announceKitView(
        _ client: AnnounceKitClient,
        didUpdateUnreadCount count: Int,
        widget: String
    )
}

public extension AnnounceKitDelegate {

    func announceKitView(
        _ client: AnnounceKitClient,
        didInitialize widget: String
    ) {}
    func announceKitView(
        _ client: AnnounceKitClient,
        didInitializeWidget widget: String
    ) {}
    func announceKitView(
        _ client: AnnounceKitClient,
        didOpenWidget widget: String
    ) {}
    func announceKitView(
        _ client: AnnounceKitClient,
        didCloseWidget widget: String
    ) {}
    func announceKitView(
        _ client: AnnounceKitClient,
        didUpdateUnreadCount count: Int,
        widget: String
    ) {}
}

open class AnnounceKitClient : NSObject, WKNavigationDelegate {

    private var contentController: AKContentController
    private var webView: WKWebView!
    private var isWebViewLoaded = false
    private var pendingJavaScript: String?

    private var isOpen: Bool = false

    var unreadCount: Int = 0

    var launcherCompletion: ((AnnounceKitLauncherButton) -> ())?
    var launcherSettings: AnnounceKitLauncherButtonSettings?

    public weak var viewControllerToPresent: UIViewController?

    public weak var delegate: AnnounceKitDelegate? {
        didSet {
            messenger.delegate = delegate
        }
    }

    let messenger: AKMessenger

    public var settings: AnnounceKitSettings? {
        didSet {
            self.configure()
        }
    }

    public required init(
        withSettings settings: AnnounceKitSettings,
        viewControllerToPresent: UIViewController? = nil
    ) {
        self.settings = settings
        self.viewControllerToPresent = viewControllerToPresent
        self.messenger = AKMessenger()
        self.contentController = AKContentController()
        super.init()

        configureWebView()

        self.messenger.client = self
        self.messenger.delegate = delegate
    }

    public func prepareLauncher(
        launcherSettings: AnnounceKitLauncherButtonSettings?,
        completion: @escaping (AnnounceKitLauncherButton) -> ()
    ) {

        launcherCompletion = completion
        self.launcherSettings = launcherSettings
        configure()
        startWidget()
    }

    private func configureWebView() {

        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = true
        contentController.add(messenger, name: AKMessageType.eventTrigger)
        contentController.add(messenger, name: AKMessageType.updateUnreadCount)
        contentController.add(messenger, name: AKMessageType.logHandler)
        configuration.userContentController = contentController

        configuration.allowsInlineMediaPlayback = true
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        self.webView.navigationDelegate = self
        self.webView.setNeedsLayout()
        configure()
    }

    private func configure() {
        let widgetHTML = """
            <html>
                <head>
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                </head>
                 <body>
                     <div style="display: none" class="announcekit-widget"></div>
                  <script>
                    (function init() {
                        if (!window.webkit) return;

                        //log handler
                        console.log = function (msg) {
                            window.webkit.messageHandlers.logHandler.postMessage(JSON.stringify(msg));
                        };

                        //error handler
                        window.onerror = (msg, url, line, column, error) => {
                            const message = {
                                message: msg,
                                url: url,
                                line: line,
                                column: column,
                                error: JSON.stringify(error)
                            }
                            window.webkit.messageHandlers.errorHandler.postMessage(message);
                        };

                        window.onload = (event) => {
                            announcekit.on("*", function ({data, name, size}) {
                                console.log('AnnounceKit event', name)
                                switch (name) {
                                    case "init":
                                        window.webkit.messageHandlers.eventTrigger.postMessage({ widget: data.widget.conf, event: "init" });
                                    break;

                                    // Called for each widget after the widget has been successfully loaded.
                                    case "widget-init":
                                        window.webkit.messageHandlers.eventTrigger.postMessage({ widget: data.widget.conf, event: name });
                                    break;

                                    // Called for each widget after the widget has been opened.
                                    case "widget-open":

                                    // Called for each widget after the widget has been opened.
                                    case "widget-close":
                                    window.webkit.messageHandlers.eventTrigger.postMessage({ widget: data.widget.conf, event: name });
                                    break;

                                    // Called when unread post count of specified widget has been updated
                                    case "widget-unread":
                                    window.webkit.messageHandlers.updateUnreadCount.postMessage({ widget: data.widget.conf, unread: unread });
                                    break;

                                    // Called when the data state of the widget is changed
                                    // TODO: We can store all state for further usages
                                    case "widget-state":
                                    const counter = data.ui.unreadCount || 0;
                                    window.webkit.messageHandlers.updateUnreadCount.postMessage({ widget: data.widget.conf, unread: counter });
                                    break;

                                    default:
                                    break;
                                }
                            })
                        }
                    })()
                </script>
                <script src="https://cdn.announcekit.app/widget-v2.js"></script>
            </body>
            </html>

        """
        
        self.webView.loadHTMLString(widgetHTML, baseURL: URL(string:"https://announcekit.co"))
    }

    private func createPushFunction() -> String? {

        guard let settings = self.settings else {
            print("AnnounceKit settings is missing")
            return nil
        }

        var config: [String: Any] = [
            "widget": "https://announcekit.co/widgets/v2/\(settings.widget)",
            "selector": ".announcekit-widget",
            "boosters": false
        ]
        
        if let language = settings.language {
            config["lang"] = language
        }

        if let user = settings.user {
            config["user"] = user
        }

        if let customData = settings.customFields {
            config["data"] = customData
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: config, options: [])
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                print("Error creating json string")
                return nil
            }
            return "announcekit.push(\(jsonString));"
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }

    public func startWidget() {

        if let showContentScript = createPushFunction() {
            if isWebViewLoaded {
                self.webView.evaluateJavaScript(showContentScript, completionHandler: nil)
            } else {
                pendingJavaScript = showContentScript
            }
        }
    }

     public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isWebViewLoaded = true
        if let pendingScript = pendingJavaScript {
            self.webView.evaluateJavaScript(pendingScript, completionHandler: nil)
            pendingJavaScript = nil
        }
    }

    public func presentWidget() {

        let wkWebViewController = UIViewController()
        if let webView = self.webView {
            self.webView = webView
            wkWebViewController.view.addSubview(self.webView)
            self.webView.translatesAutoresizingMaskIntoConstraints = false
            if #available(iOS 11.0, *) {
                NSLayoutConstraint.activate([
                    self.webView.topAnchor.constraint(equalTo: wkWebViewController.view.safeAreaLayoutGuide.topAnchor),
                    self.webView.bottomAnchor.constraint(equalTo: wkWebViewController.view.safeAreaLayoutGuide.bottomAnchor),
                    self.webView.leadingAnchor.constraint(equalTo: wkWebViewController.view.safeAreaLayoutGuide.leadingAnchor),
                    self.webView.trailingAnchor.constraint(equalTo: wkWebViewController.view.safeAreaLayoutGuide.trailingAnchor),
                ])
            } else {
                NSLayoutConstraint.activate([
                    self.webView.topAnchor.constraint(equalTo: wkWebViewController.topLayoutGuide.bottomAnchor),
                    self.webView.bottomAnchor.constraint(equalTo: wkWebViewController.bottomLayoutGuide.topAnchor),
                    self.webView.leadingAnchor.constraint(equalTo: wkWebViewController.view.leadingAnchor),
                    self.webView.trailingAnchor.constraint(equalTo: wkWebViewController.view.trailingAnchor),
                ])
            }
        }

        if #available(iOS 13.0, *) {
            wkWebViewController.isModalInPresentation = true
        }

        wkWebViewController.modalPresentationStyle = .overFullScreen
        wkWebViewController.modalTransitionStyle = .crossDissolve

        self.webView.transform = CGAffineTransform(translationX: wkWebViewController.view.bounds.width, y: 0)

        viewControllerToPresent?.present(wkWebViewController, animated: true, completion: {
            UIView.animate(withDuration: 0.3) {
                self.webView.evaluateJavaScript("announcekit.widgets[0].open()", completionHandler: nil)
                self.webView.transform = .identity
            }
        })
    }

    @objc func buttonTapped(_ sender: UIButton) {

        presentWidget()
    }
}
