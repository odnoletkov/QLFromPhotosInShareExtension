import UIKit
import Social
import QuickLook
import CoreServices

var once = false

var resolved = 0

class ShareViewController: UINavigationController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(rootViewController: RootController())

        if !once {
            let dynamicColor = UIColor { trait in
                UIColor { trait in
                    UIColor { trait in
//                        print("read \(trait)")
                        resolved += 1
                        print("resolved \(resolved)")
                        return UIColor.black
                    }
                }
            }

            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: dynamicColor]
            UINavigationBar.appearance().largeTitleTextAttributes = UINavigationBar.appearance().titleTextAttributes
            once = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RootController: UIViewController {
    override func viewDidLoad() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let controller = CarouselViewController()
            controller.navigationItem.rightBarButtonItem = .init(systemItem: .close, primaryAction: .init { [weak self] _ in
                self?.extensionContext?.completeRequest(returningItems: nil)
            })
            let navigationController = UINavigationController(rootViewController: controller)
            navigationController.modalPresentationStyle = .formSheet
            self.present(navigationController, animated: true)
        }
    }

    // Fix presented controller not dismissed during SE tear down
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentedViewController?.dismiss(animated: false)
    }
}

class CarouselViewController: UIViewController {

    let shareController = ShareContentViewController()

    override func viewDidLoad() {
        shareController.view.translatesAutoresizingMaskIntoConstraints = true
        shareController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        shareController.view.frame = view.bounds
        view.addSubview(shareController.view)
        addChild(shareController)
        shareController.didMove(toParent: self)
    }
}

class PlainController: UIViewController {
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

class ShareContentViewController: QLPreviewController, QLPreviewControllerDataSource {

    var items: [NSURL] = [] {
        didSet {
            reloadData()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        items.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        items[index]
    }

    override func viewDidLoad() {
        dataSource = self

        Task {
            var urls: [NSURL] = []
            let providers = (extensionContext!.inputItems as! [NSExtensionItem])
                .compactMap(\.attachments)
                .flatMap { $0 }
            for provider in providers {
                if let url = try? await provider.loadItem(forTypeIdentifier: UTType.gif.identifier) as? NSURL {
                    urls.append(url)
                } else if let url = try? await provider.loadItem(forTypeIdentifier: UTType.image.identifier) as? NSURL {
                    urls.append(url)
                }
            }
            self.items = urls
        }
    }
}
