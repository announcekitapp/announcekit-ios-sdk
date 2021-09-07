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
    public var userID: String?
    public var name: String?
    public var language: String?
    public var isBoostersEnabled: Bool = false
    public var user: [String: Any]?
    public var customFields: [String: Any]?

    public init(
        widget: String,
        userID: String? = nil,
        name: String? = nil,
        language: String? = nil,
        isBoostersEnabled: Bool = false,
        user: [String : Any]? = nil,
        customFields: [String : Any]? = nil
    ) {
        self.widget = widget
        self.userID = userID
        self.name = name
        self.language = language
        self.isBoostersEnabled = isBoostersEnabled
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

public struct AnnounceKitLauncherButtonSettings {

    public var title: String?
    public var unreadCount: Int = 0
    public var titleFont: UIFont?
    public var badgeTitleFont: UIFont = .systemFont(ofSize: 12.0)
    public var badgeBackgroundColor: UIColor = .systemRed
    public var titleColor: UIColor?
    public var badgeTitleColor: UIColor?
    public var badgeVerticalOffset: CGFloat = -2.0
    public var badgeHorizontalOffset: CGFloat = 2.0

    public init(
        title: String? = nil,
        titleFont: UIFont? = nil,
        badgeTitleFont: UIFont = .systemFont(ofSize: 12.0),
        badgeBackgroundColor: UIColor = .systemRed,
        titleColor: UIColor? = nil,
        badgeTitleColor: UIColor? = nil
    ) {

        self.title = title
        self.titleFont = titleFont
        self.badgeTitleFont = badgeTitleFont
        self.badgeBackgroundColor = badgeBackgroundColor
        self.titleColor = titleColor
        self.badgeTitleColor = badgeTitleColor
    }
}

open class AnnounceKitLauncherButton: UIButton {

    private var badgeButton: UIButton?

    public var buttonSettings: AnnounceKitLauncherButtonSettings? {
        didSet {
            commonInit()
        }
    }

    private var hasTitle: Bool {

        guard let title = buttonSettings?.title else { return false }

        return !title.isEmpty
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {

        if let settings = buttonSettings {
            if !hasTitle {
                backgroundColor = settings.badgeBackgroundColor
                setTitleColor(settings.badgeTitleColor ?? .white, for: .normal)
                setTitle(String(settings.unreadCount), for: .normal)
                titleLabel?.font = settings.badgeTitleFont
                layer.cornerRadius = bounds.height / 2.0
                contentEdgeInsets = UIEdgeInsets(top: 2.0, left: 5.0, bottom: 2.0, right: 5.0)
            } else {
                clipsToBounds = false
                if badgeButton == nil {
                    let badge = UIButton(type: .custom)
                    addSubview(badge)
                    badgeButton = badge
                }
                badgeButton?.setTitle(String(settings.unreadCount), for: .normal)
                badgeButton?.backgroundColor = settings.badgeBackgroundColor
                badgeButton?.setTitleColor(settings.badgeTitleColor, for: .normal)
                badgeButton?.titleLabel?.font = settings.badgeTitleFont
                badgeButton?.contentEdgeInsets = UIEdgeInsets(top: 2.0, left: 5.0, bottom: 2.0, right: 5.0)
                setTitleColor(settings.titleColor ?? .black, for: .normal)
                titleLabel?.font = settings.titleFont ?? .systemFont(ofSize: 18.0)
                backgroundColor = .clear
                layer.cornerRadius = .zero
                setTitle(settings.title, for: .normal)
                contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
                setNeedsDisplay()
                badgeButton?.sizeToFit()
                if let badgeButton = badgeButton {
                    badgeButton.frame = CGRect(
                        x: bounds.width,
                        y: 0,
                        width: badgeButton.bounds.width < badgeButton.bounds.height ? badgeButton.bounds.height : badgeButton.bounds.width,
                        height: badgeButton.bounds.height
                    )
                }
            }
        } else {
            backgroundColor = .systemRed
            titleLabel?.font = .systemFont(ofSize: 12.0)
            setTitleColor(.white, for: .normal)
            setTitle("", for: .normal)
            layer.cornerRadius = bounds.height / 2.0
            contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        }
    }

    open override func layoutSubviews() {

        super.layoutSubviews()

        if let badgeButton = badgeButton {
            badgeButton.sizeToFit()
            badgeButton.frame = CGRect(
                x: bounds.width - (badgeButton.bounds.width / 2) + (buttonSettings?.badgeHorizontalOffset ?? 0.0),
                y: 0 + (buttonSettings?.badgeVerticalOffset ?? 0.0),
                width: badgeButton.bounds.width < badgeButton.bounds.height ? badgeButton.bounds.height : badgeButton.bounds.width,
                height: badgeButton.bounds.height
            )
            badgeButton.layer.cornerRadius = badgeButton.bounds.height / 2.0
        }
    }
}

open class AnnounceKitClient {

    private var contentController = AKContentController()
    private var webView: WKWebView!

    private var isOpen: Bool = false

    var unreadCount: Int = 0

    fileprivate var launcherCompletion: ((AnnounceKitLauncherButton) -> ())?
    fileprivate var launcherSettings: AnnounceKitLauncherButtonSettings?

    public weak var viewControllerToPresent: UIViewController?

    public weak var delegate: AnnounceKitDelegate? {
        didSet {
            messenger.delegate = delegate
        }
    }

    private let messenger: AKMessenger

    public var settings: AnnounceKitSettings? {
        didSet {
            self.configure()
        }
    }

    public init(withSettings settings: AnnounceKitSettings, viewControllerToPresent: UIViewController? = nil) {
        self.settings = settings
        self.viewControllerToPresent = viewControllerToPresent
        self.messenger = AKMessenger()

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
        displayContent()
    }

    private func configureWebView() {

        let configuration = WKWebViewConfiguration()
        if #available(iOS 14.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        configuration.preferences.javaScriptEnabled = true
        contentController.add(messenger, name: AKMessageType.eventTrigger)
        contentController.add(messenger, name: AKMessageType.updateUnreadCount)
        contentController.add(messenger, name: AKMessageType.logHandler)
        configuration.userContentController = contentController

        configuration.allowsInlineMediaPlayback = true
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        self.webView.setNeedsLayout()
        configure()
    }

    private func configure() {

        guard let scriptURL = Bundle(for: AnnounceKitClient.self).url(forResource: "widget", withExtension: "html") else { return }

        self.webView.load(URLRequest(url: scriptURL))
    }

    private func createPushFunction() -> String? {

        guard let settings = self.settings else {
            print("AnnounceKit settings is missing")
            return nil
        }

        var config: [String: Any] = [
            "widget": "https://announcekit.app/widgets/v2/\(settings.widget)",
            "selector": ".announcekit-widget"
        ]

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
            return """
                    announcekit.push(
                        \(jsonString)
                    );
                    """
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }

    public func displayContent() {

        if let showContentScript = createPushFunction() {
            self.webView.evaluateJavaScript(showContentScript)
        }
    }

    @objc fileprivate func buttonTapped(_ sender: UIButton) {

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
}

private enum AKMessageType {

    static let updateUnreadCount = "updateUnreadCount"
    static let logHandler = "logHandler"
    static let errorHandler = "errorHandler"
    static let eventTrigger = "eventTrigger"
}

private enum AKEventName: String {

    case initialize = "init"
    case widgetInit = "widget-init"
    case widgetOpen = "widget-open"
    case widgetClose = "widget-close"
}

private class AKMessenger: NSObject, WKScriptMessageHandler {

    weak var client: AnnounceKitClient?

    weak var delegate: AnnounceKitDelegate?

    override init() {
        super.init()
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {

        switch message.name {
        case AKMessageType.updateUnreadCount:
            guard let dict = message.body as? [String: Any],
                  let unread = dict["unread"] as? Int,
                  let view = client else {
                return
            }

            view.unreadCount = unread
            delegate?.announceKitView(view, didUpdateUnreadCount: unread, widget: view.settings?.widget ?? "")
        case AKMessageType.logHandler:
            print(message.name)
            print("\(message.body)")
        case AKMessageType.eventTrigger:
            guard let dict = message.body as? [String: Any] else {
                print("error parsing event payload: \(message.name)")
                return
            }
            handleEventTrigger(withInfo: dict)
        case AKMessageType.errorHandler:
            print("\(message.body)")
        default:
            print("error – unknown \(message.name)")
        }
    }

    private func handleEventTrigger(withInfo info: [String: Any]) {

        guard let eventName = info["event"] as? String,
              let event = AKEventName(rawValue: eventName),
              let widget = info["widget"] as? [String: Any],
              let widgetID = widget["widget"] as? String,
              let view = client else {
            print("event name is missing: \(info)")
            return
        }

        switch event {
        case .initialize:
            delegate?.announceKitView(view, didInitialize: widgetID)
        case .widgetInit:
            delegate?.announceKitView(view, didInitializeWidget: widgetID)

            if view.launcherCompletion != nil {
                let button = AnnounceKitLauncherButton(frame: .zero)
                var launcherSettings = view.launcherSettings ?? AnnounceKitLauncherButtonSettings()
                launcherSettings.unreadCount = view.unreadCount
                button.buttonSettings = launcherSettings
                button.addTarget(view, action: #selector(AnnounceKitClient.buttonTapped(_:)), for: .touchUpInside)
                view.launcherCompletion?(button)
                view.launcherCompletion = nil
            }
        case .widgetOpen:
            delegate?.announceKitView(view, didOpenWidget: widgetID)
        case .widgetClose:
            view.viewControllerToPresent?.dismiss(animated: true, completion: nil)
            delegate?.announceKitView(view, didCloseWidget: widgetID)
        }
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage,
        replyHandler: @escaping (Any?, String?) -> Void
    ) {

        print(message.name)
        print(message.body)
    }
}

private class AKContentController: WKUserContentController {}
