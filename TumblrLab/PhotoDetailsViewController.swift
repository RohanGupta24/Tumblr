//
//  PhotoDetailsViewController.swift
//  TumblrLab
//
//  Created by Rohan Gupta on 1/17/18.
//  Copyright © 2018 Rohan Gupta. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {
    
    var url: String!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlPassedIn = URL(string: url!)
        imageView.af_setImage(withURL: urlPassedIn!)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     @IBOutlet var imageView: UIImageView!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
        case "fullScreenSegue":
            let destination = segue.destination as! FullScreenPhotoViewController
            destination.image = imageView.image
        default:
            break
        }
    }

}
