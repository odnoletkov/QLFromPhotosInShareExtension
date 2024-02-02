import UIKit
import Social
import QuickLook
import CoreServices

class ShareViewController: UINavigationController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(rootViewController: RootController())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RootController: UIViewController {
    override func viewDidLoad() {
        DispatchQueue.main.async {
            let controller = CarouselViewController()
            controller.modalPresentationStyle = .formSheet
            controller.navigationItem.rightBarButtonItem = .init(systemItem: .close, primaryAction: .init { [weak self] _ in
                self?.extensionContext?.completeRequest(returningItems: nil)
            })
            self.present(UINavigationController(rootViewController: controller), animated: true)
        }
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
