
import UIKit
import Alamofire
import SafariServices
import StoreKit
import AVFoundation
import SnapKit

class HomeController: UIViewController, UIDocumentInteractionControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var no_internetLabel: UILabel!
    @IBOutlet weak var no_internet: UIImageView!
    @IBOutlet weak var webViewContainer: UIView!
    var webView: SFSafariViewController!
    var refreshControl:UIRefreshControl?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var webURL = Configuration.URL
    private var orientation = Configuration.ORIENTATION
    private var statusBarColor = Configuration.STATUS_BAR_COLOR
    private var statusBarTextMode = Configuration.STATUS_BAR_TEXT_COLOR
    private var isPulled = false
    private var wasOffline = false
    private var refreshURL:URL = URL(string: Configuration.URL)!
    private var appCount = UserDefaults.standard.integer(forKey: "count")
    public var launchURL:Any?
    private var isLaunchURL = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
// MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deepLinking()
        
        wasOffline = !isConnected()
        rateDialogAppearance()
    }
    
    func pushLaunchURL(){
        launchURL = UserDefaults.standard.object(forKey: "launchURL")
        if launchURL != nil {
            print("not nil")
            webURL = launchURL as! String
            UserDefaults.standard.set(nil, forKey: "launchURL")
            isLaunchURL = true
        }else{
            print("url is nil")
        }
    }
    
    func deepLinking(){
      
        let isAllowed = UserDefaults.standard.bool(forKey: "isAllowed")
        print("Allowed: \(isAllowed)")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationReceived(_:)), name: Notification.Name("FCMToken"), object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FCMToken"), object: nil)
    }
    
    @objc func notificationReceived(_ notification: Notification) {
        print("Notification received");
        if let token = notification.userInfo?["token"] as? String {
           print("Token: \(token)")
          // set url and open webview
            let newUrl : String = "\(webURL)&player_id=\(token)";
            print("New Url: \(newUrl)");
            UserDefaults.standard.set(newUrl, forKey: "launchURL")
            pushLaunchURL()
            webContainerLoad()
        }
    }
    
    func webContainerLoad(){
        setWebView()
        print(webURL)
        pullToRefresh()
    }
    
    func rateDialogAppearance(){
        if Configuration.RATE_DIALOG{
            let count = Configuration.RATE_DIALOG_AFTER_APP_LAUNCHES
            if appCount >= count {
                if #available( iOS 10.3,*){
                    SKStoreReviewController.requestReview()
                }
                appCount = 1
                UserDefaults.standard.set(appCount, forKey: "count")
            }
            else{
                appCount = appCount + 1
                UserDefaults.standard.set(appCount, forKey: "count")
            }
        }
    }
    
    func loadWebview(url: URL) {
        if #available(iOS 11.0, *) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            self.webView = SFSafariViewController(url: url, configuration: config)
        } else {
            // Fallback on earlier versions
            self.webView = SFSafariViewController(url: url, entersReaderIfAvailable: true)
        }
        webView.delegate = self
    }

// MARK: - Setting up the webview
    
    func setWebView(){
        let url = createURL(url: webURL)

        if isConnected() {
            no_internet.isHidden = true
            no_internetLabel.isHidden = true
            self.loadWebview(url: url)
            activityNavigator()
        } else if !((Configuration.URL).localizedCaseInsensitiveContains("http")) {
            no_internet.isHidden = true
            no_internetLabel.isHidden = true
            self.loadWebview(url: url)
            activityNavigator()
        } else {
            no_internet.isHidden = false
            no_internetLabel.isHidden = false
            return
        }

        self.addChild(self.webView)

        self.webViewContainer.addSubview(webView.view)
        self.webView.view.frame = self.webViewContainer!.bounds
        self.webView.view.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top)//.offset(-44)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.view.snp.bottom)//.offset(80)
        }

        self.webView.didMove(toParent: self)
        
        activityIndicator.color = Configuration.LOADING_SIGN_COLOR
        self.webViewContainer.bringSubviewToFront(activityIndicator)
    }
    
    
// MARK: - Pull to refresh code
    
        func pullToRefresh(){
            self.view.backgroundColor = statusBarColor
            if Configuration.PULL_TO_REFRESH {
                    self.refreshControl = UIRefreshControl.init()
                    refreshControl!.bounds = CGRect(x: 0, y: ((refreshControl!.bounds.size.height)+30), width: refreshControl!.bounds.size.width, height: refreshControl!.bounds.size.height)
                        refreshControl?.tintColor = Configuration.LOADING_SIGN_COLOR
                    
                    refreshControl!.addTarget(self, action:#selector(refreshControlClicked), for: UIControl.Event.valueChanged)
//                self.webView.view.scrollView.addSubview(self.refreshControl!)
            }
        }
        
// Pull to refresh method
        @objc func refreshControlClicked(){
            isPulled = true
            print("refresh method called")
            if isConnected() {
                no_internetLabel.isHidden = true
                no_internet.isHidden = true
                
                if wasOffline == true {webContainerLoad();wasOffline = false}else{self.setWebView()}
                self.setWebView()
            }
            else{refreshControl?.endRefreshing()}
        }

    func activityNavigator(){
        if Configuration.LOADING_SIGN {
            webViewContainer.bringSubviewToFront(activityIndicator)
            activityIndicator.startAnimating()
            activityIndicator.hidesWhenStopped = true
        }
    }

    func downloadFile(shareURL: URL){
        print("show share option")
            FileDownload.download(url: shareURL) { (fileUrl) in
            let controller = UIDocumentInteractionController(url: fileUrl)
            controller.delegate = self
            controller.presentPreview(animated: true)
                self.activityIndicator.stopAnimating()
        }
    }
 
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

// URL Setting
    func createURL(url: String) -> URL{
        if !(url.localizedCaseInsensitiveContains("http")){
            let arr = url.split(separator: ".")
        
            return Bundle.main.url(forResource: String(arr[0]), withExtension: String(arr[1]))!
        }else{
            return URL(string: url)!
        }
    }
// Orientation Setup
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        switch orientation {
        case 0:
            return .portrait
        case 1:
            return .landscape
        case 2:
            return .all
        default:
            return .all
        }
    }
    
// Status Bar Text Color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        switch statusBarTextMode {
        case 0:
            return .lightContent
        case 1:
            return .default
        default:
            return .default
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
// Check for internet connection
    func isConnected() -> Bool{
        let connection = ConnectionCheck()
        return connection.checkReachable()
    }
   
}

extension HomeController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        activityIndicator.stopAnimating()
        refreshControl?.endRefreshing()
        isPulled = false
    }
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        activityIndicator.stopAnimating()
        refreshControl?.endRefreshing()
        isPulled = false
    }
    
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        activityIndicator.startAnimating()
        return []
    }
    
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        print("url: ", URL)
    }
    
    func safariViewController(_ controller: SFSafariViewController, excludedActivityTypesFor URL: URL, title: String?) -> [UIActivity.ActivityType] {
        print("url", URL)
        return []
    }
}





