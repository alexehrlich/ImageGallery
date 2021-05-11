//
//  ImageGalleryViewController.swift
//  ImageGallery
//
//  Created by Alexander Ehrlich on 08.05.21.
//

import UIKit

class ImageGalleryViewController: UIViewController {
    
    var cellWidthScale: CGFloat = 1.0
    var imageFetcher : ImageFetcher!
    
    @IBOutlet weak var imageCollectionView: UICollectionView! {
        didSet{
            imageCollectionView.dataSource = self
            imageCollectionView.delegate = self
            
            //for internal drag and drop
            imageCollectionView.dropDelegate = self
            imageCollectionView.dragDelegate = self
            imageCollectionView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(adjustCellWidth(with:))))
        }
    }
    
    var imageDataTuple : [(NSURL?, CGSize)]? {
        didSet{
            imageCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCollectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
    }
    
    @objc func adjustCellWidth(with recognizer: UIPinchGestureRecognizer){
        
        switch recognizer.state {
        
        case .changed:
            print(recognizer.scale)
            cellWidthScale *= recognizer.scale
            recognizer.scale = 1.0
            imageCollectionView.reloadData()
        default: break
        }
    }
    
}

//MARK: UICollectionViewDelegate

extension ImageGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageDataTuple?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        
        if let imageCell = cell as? ImageCollectionViewCell{
            
            if let url = imageDataTuple?[indexPath.row].0{
                
                //never fetch data on the main queue
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    let urlContent = try? Data(contentsOf: (url as? URL)!.imageURL)
                    
                    //check if the url is really the one we want to show
                    if let imageData = urlContent, url == self!.imageDataTuple?[indexPath.row].0{
                        
                        //update the UI always on the main queue
                        DispatchQueue.main.async {
                            imageCell.spinner.stopAnimating()
                            imageCell.imageView.image = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let checkedImageData = imageDataTuple{
            let imageHeightToWidth = checkedImageData[indexPath.row].1.height/checkedImageData[indexPath.row].1.width
            
            let calculatedWidth = (self.view.frame.width/4) * cellWidthScale
            
            return CGSize(width: calculatedWidth, height: calculatedWidth * imageHeightToWidth)
        }
        
        return CGSize.zero
    }
}

//MARK: UICollectionViewDropDelegate
extension ImageGalleryViewController: UICollectionViewDropDelegate{
    
    
    
    //1. Can the dropDelegate handle the object?
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        
        //requirement: only drop with image and url should be handled
        return session.canLoadObjects(ofClass: UIImage.self) && session.canLoadObjects(ofClass: NSURL.self)
    }
    
    //2. update the session. Return a propsal in which manner the object schoukd be dropped (.copy; .move...)
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        
        //Es wird überprüft, ob der collectionView auf dem gedroppt werden soll der ist, von dem das DragItem stammt
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == imageCollectionView
        
        let dropOperation: UIDropOperation = isSelf ? .move : .copy
        
        //intent: Soll eine neue Cell erstellt werden oder in die eingefügt werden, über der man sich gerde befindet?
        return UICollectionViewDropProposal(operation: dropOperation, intent: .insertAtDestinationIndexPath)
    }
    
    //3. perform the actual drop. update UI and the model
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        let destinationIntexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
        
        for item in coordinator.items{
            
            //Is the drop from the same collectionView or external? internal --> != nil
            if let sourceIndexPath = item.sourceIndexPath{
                
                
                
            }
            
            //external --> nil
            else{

                var dataTupel: (NSURL?, CGSize?) {
                    didSet{
                        
                        DispatchQueue.main.async {
                            if let controllerTitel = self.title, let presentImageSize = dataTupel.1, let presentURL = dataTupel.0{
                                
                                if ImageGalleryModel.imageURLs[controllerTitel] != nil {
                                    ImageGalleryModel.imageURLs[controllerTitel]!.append((presentURL, presentImageSize))
                                    self.imageDataTuple = ImageGalleryModel.imageURLs[controllerTitel]!
                                }
                            }
                        }
        
                    }
                }
                
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { provider, error in
                    dataTupel.0 = provider as? NSURL
                }
                
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { provider, error in
                    if let receivedImage = provider as? UIImage{
                        dataTupel.1 = receivedImage.size
                    }
                }
                
            }
        }
        
    }
}

//MARK: UICollectionViewDragDelegate
extension ImageGalleryViewController: UICollectionViewDragDelegate{
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        //
        
        return []
    }
}

