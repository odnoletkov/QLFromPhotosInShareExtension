import UIKit
import Social
import QuickLook
import CoreServices

class ShareViewController: UINavigationController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(rootViewController: ShareContentViewController())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ShareContentViewController: QLPreviewController, QLPreviewControllerDataSource {

    var items: [NSURL] = [] {
        didSet {
            reloadData()
        }
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        items.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        items[index]
    }

    override func viewDidLoad() {
        reloadData()
        dataSource = self

        Task {
            var urls: [NSURL] = []
            let providers = (extensionContext!.inputItems as! [NSExtensionItem])
                .compactMap(\.attachments)
                .flatMap { $0 }
            for provider in providers {
                urls.append(try! await provider.loadItem(forTypeIdentifier: UTType.gif.identifier) as! NSURL)
            }
            self.items = urls
        }
    }
}
