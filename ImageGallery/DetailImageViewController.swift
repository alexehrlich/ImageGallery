//
//  DetailImageViewController.swift
//  ImageGallery
//
//  Created by Alexander Ehrlich on 16.05.21.
//

import UIKit

class DetailImageViewController: UIViewController {
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var imageScrollView: UIScrollView! {
        
        didSet{
            imageScrollView.delegate = self
            imageScrollView.minimumZoomScale = 0.5
            imageScrollView.maximumZoomScale = 25
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!{
        didSet{
            imageScrollView?.contentSize = imageView.frame.size
        }
    }
    
    var imageUrl: NSURL!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
        //never fetch data on the main queue
        DispatchQueue.global(qos: .userInitiated).async {
            let urlContent = try? Data(contentsOf: (self.imageUrl as URL).imageURL)
            
            //update the UI always on the main queue
            DispatchQueue.main.async {
                
                //check if the url is really the one we want to show
                if let imageData = urlContent{
                    self.spinner.stopAnimating()
                    self.imageView.image = UIImage(data: imageData)
                }
            }
        }
    }
}


//MARK: UIScrollView:
extension DetailImageViewController: UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
