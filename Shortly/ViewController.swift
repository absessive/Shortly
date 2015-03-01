//
//  ViewController.swift
//  Shortly
//
//  Created by Ajit Chakrapani on 2/28/15.
//  Copyright (c) 2015 absessive. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate,
                                        NSURLConnectionDelegate,
                                        NSURLConnectionDataDelegate {

    @IBOutlet var urlField: UITextField!
    @IBOutlet var webView: UIWebView!
    @IBOutlet var shortenButton: UIBarButtonItem!
    @IBOutlet var shortLabel: UIBarButtonItem!
    @IBOutlet var clipboardButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loadLocation( AnyObject ) {
        var urlText = urlField.text
        
        if !urlText.hasPrefix("http:") && !urlText.hasPrefix("https:") {
            if !urlText.hasPrefix("//") {
                urlText = "//" + urlText
            }
            urlText = "http:" + urlText
        }
        
        let url = NSURL(string: urlText)!
        webView.loadRequest(NSURLRequest(URL: url))
    }
    
//MARK: URL Shortening
    
    let GoDaddyAccountKey = "c6626f8fc21c49acbfa14ff897d4feb9"
    var shortenURLConnection: NSURLConnection?
    var shortURLData: NSMutableData?
    
    @IBAction func shortenURL( AnyObject ) {
        if let toShorten = webView.request?.URL.absoluteString {
//            let encodedURL = toShorten.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            let encodedURL = toShorten
            let urlString = "http://api.x.co/Squeeze.svc/text/\(GoDaddyAccountKey)?url=\(encodedURL)"
            shortURLData = NSMutableData()
            let request = NSURLRequest(URL:NSURL(string:urlString)!)
            shortenURLConnection = NSURLConnection(request:request, delegate:self)
            shortenButton.enabled = false
        }
    }
    
    @IBAction func clipboardURL( AnyObject ) {
        let shortURLString = shortLabel.title
        let shortURL = NSURL(string: shortURLString!)
        UIPasteboard.generalPasteboard().URL = shortURL
    }

//MARK: NSURLConnectionDelegate
    
    func connection( connection: NSURLConnection!, didFailWithError error: NSError! ) {
            shortLabel.title = "failed"
            clipboardButton.enabled = false
            shortenButton.enabled = true
    }
    
    func connection( connection: NSURLConnection!, didReceiveData data: NSData! ) {
        shortURLData?.appendData(data)
    }
    
    func connectionDidFinishLoading( connection: NSURLConnection! ) {
        if let data = shortURLData {
            let shortURLString = NSString(data:data, encoding:NSUTF8StringEncoding)
            shortLabel.title = shortURLString
            clipboardButton.enabled = true
        }
    }

//MARK: - UIWebViewDelegate
    
    func webViewDidStartLoad( UIWebView ) {
        shortenButton.enabled = false
    }

    func webViewDidFinishLoad( UIWebView ) {
        shortenButton.enabled = true
        urlField.text = webView.request?.URL.absoluteString
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        var message = "That page could not be loaded. " +
                        error.localizedDescription
        let alert = UIAlertController(title: "Could not load URL",
                                    message: message,
                             preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "That's sad",
                                     style: .Default,
                                   handler: nil)
        
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}

