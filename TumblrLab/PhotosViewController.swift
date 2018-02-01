//
//  PhotosViewController.swift
//  TumblrLab
//
//  Created by Rohan Gupta on 1/10/18.
//  Copyright © 2018 Rohan Gupta. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotoCell: UITableViewCell {
    
    @IBOutlet var img: UIImageView!
    
    var url: String!
}

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate{

    var posts: [NSDictionary] = []
    
    var pageNumber = 0
    
    @IBOutlet var TumblrView: UITableView!
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = TumblrView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - TumblrView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && TumblrView.isDragging) {
                isMoreDataLoading = true
                let frame = CGRect(x: 0, y: TumblrView.contentSize.height, width: TumblrView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                loadMoreData()
                // ... Code to load more results ...
            }
            
        }
    }
    
    func loadMoreData() {
        
        // ... Create the NSURLRequest (myRequest) ...
        pageNumber += 1
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV&page=\(pageNumber)")
        
        let myRequest = URLRequest(url: url!)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: URLSessionConfiguration.default,
                                 delegate:nil,
                                 delegateQueue:OperationQueue.main
        )
        let task : URLSessionDataTask = session.dataTask(with: myRequest, completionHandler: { (data, response, error) in
            
            // Update flag
            self.isMoreDataLoading = false
            
             self.loadingMoreView!.stopAnimating()
            
            // ... Use the new data to update the data source ...
            if let error = error {
                print(error.localizedDescription)
            }
            else if let data = data {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                
                let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                
                //retrieve the "posts" dictionary from "response"
                self.posts.append(contentsOf: responseFieldDictionary["posts"] as! [NSDictionary])
                    
                    
                
                // TODO: Get the posts and store in posts property
                
                self.TumblrView.reloadData()
                }
            
            }
                // TODO: Reload the table view

        
    });

        task.resume()
}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        TumblrView.delegate = self;
        TumblrView.dataSource = self;
        
        loadMoreData()
        
        let frame = CGRect(x: 0, y: TumblrView.contentSize.height, width: TumblrView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        TumblrView.addSubview(loadingMoreView!)
        
        var insets = TumblrView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        TumblrView.contentInset = insets
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath as IndexPath) as! PhotoCell
        let post = posts[indexPath.section]
        if let photos = post["photos"] as? [[String: Any]] {
            let photo = photos[0]
            let originalSize = photo["original_size"] as! [String: Any]
            let urlString = originalSize["url"] as! String
            let url = URL(string: urlString)
            cell.img.af_setImage(withURL: url!)
            cell.url = urlString
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! PhotoDetailsViewController
        let cell = sender as! PhotoCell
        destination.url = cell.url
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        
        profileView.clipsToBounds = true;
        
        profileView.layer.cornerRadius = 15;
        
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        // Set the avatar
        profileView.af_setImage(withURL: URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar")!)
        headerView.addSubview(profileView)
        
        // Add a UILabel for the date here
        // Use the section number to get the right URL
        let post = posts[section]
        print(post["date"]!)
        let dateLabel = UILabel(frame: CGRect(x: 50, y: 10, width: tableView.frame.width - 50, height: 30))
        //let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        dateLabel.text = post["date"]! as! String
        headerView.addSubview(dateLabel)
        // let label = ...
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    


}
