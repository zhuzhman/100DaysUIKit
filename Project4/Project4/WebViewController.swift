//
//  WebViewController.swift
//  Project4
//
//  Created by Mikhail Zhuzhman on 20.05.2024.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    var selectedWebsite: (String?, String?)
    var webView: WKWebView!
    var progressView: UIProgressView!
//    var files = [String]()
//    //    var websites = ["apple.com", "hackingwithswift.com"]
//    var websites = [String]()
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        let fm = FileManager.default
//        let path = Bundle.main.resourcePath!
//        let items = try! fm.contentsOfDirectory(atPath: path)
//        
//        for item in items {
//            if item.hasPrefix("websites.json") {
//                files.append(item)
//            }
//        }
//        
//        if files.count == 1 {
//            if let fileUrl = Bundle.main.url(forResource: files[0], withExtension: nil) {
//                do {
//                    let data = try Data(contentsOf: fileUrl)
//                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
//                    
//                    if let jsonDict = jsonObject as? [String: Any],
//                       let websitesArray = jsonDict["websites"] as? [String] {
//                        websites += websitesArray
//                    }
//                } catch {
//                    print("Error decoding JSON:", error)
//                }
//            } else {
//                print("Expected JSON file not found in bundle")
//            }
//        } else {
//            print(files.count < 1 ? "There is no JSON files in the bundle" : "There are more then one JSON file in bundle. Sorry, cannot choose.")
//            title = "Error, there are no websites to load"
//        }
//        
//        if files.count == 1 {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
            
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let back = UIBarButtonItem(barButtonSystemItem: .rewind, target: webView, action: #selector(webView.goBack))
            let forward = UIBarButtonItem(barButtonSystemItem: .fastForward, target: webView, action: #selector(webView.goForward))
            let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
            
            progressView = UIProgressView(progressViewStyle: .default)
            progressView.sizeToFit()
            let progressButton = UIBarButtonItem(customView: progressView)
            
            toolbarItems = [progressButton, spacer, back, forward, refresh]
            navigationController?.isToolbarHidden = false
            
            webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
            
            //        let url = URL(string: "https://" + websites[1])!
            //            guard let url = URL(string: "https://" + websites[1] ) else { return }
            //            webView.load(URLRequest(url: url))
//            openPage(action: UIAlertAction(title: websites[1], style: .default, handler: openPage))
        openPage(action: UIAlertAction(title: selectedWebsite.0, style: .default, handler: openPage))
            
            webView.allowsBackForwardNavigationGestures = true
//        }
    }
    
    @objc func openTapped() {
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
        
//        for website in websites {
        ac.addAction(UIAlertAction(title: selectedWebsite.0, style: .default, handler: openPage))
//        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
    func openPage(action: UIAlertAction) {
        guard let actionTitle = action.title else { return }
        guard let url = URL(string: "https://" + actionTitle) else { return }
        webView.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        if let host = url?.host {
            //            for website in websites {
            //                if host.contains(website) {
            if let selectedWebsite = selectedWebsite.0 {
                if host.contains(selectedWebsite) {
                    decisionHandler(.allow)
                    return
                }
            }
        }
//        }
        decisionHandler(.cancel)
        
        showAlert()
    }
    
    func showAlert() {
        let ac = UIAlertController(title: "URL is not allowed", message: "The site you are trying to reach is not allowed.", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Close", style: .default))
        
        present(ac, animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
