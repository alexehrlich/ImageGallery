//
//  ImageGalleryViewController.swift
//  ImageGallery
//
//  Created by Alexander Ehrlich on 08.05.21.
//

import UIKit

class ImageGalleryViewController: UIViewController {

    @IBOutlet weak var imageCollectionView: UICollectionView! {
        didSet{
            imageCollectionView.dataSource = self
            imageCollectionView.delegate = self
        }
    }
    
    var imageURLs = [URL?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageCollectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
    }
    
}

//MARK: UICollectionViewDelegate

extension ImageGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        cell.backgroundColor = UIColor.blue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return indexPath.row % 2 == 0 ? CGSize(width: 100, height: 50) : CGSize(width: 100, height: 100)
    }
    
    
}
