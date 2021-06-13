//
//  ImageCollectionViewCell.swift
//  ImageGallery
//
//  Created by Alexander Ehrlich on 08.05.21.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView! 
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageUrl: NSURL?


}
