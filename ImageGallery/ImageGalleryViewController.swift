//
//  ImageGalleryViewController.swift
//  ImageGallery
//
//  Created by Alexander Ehrlich on 08.05.21.
//

import UIKit

class ImageGalleryViewController: UIViewController {
    
    var cellWidthScale: CGFloat = 1.0
    var currentCellSize = CGSize()
    var imageFetcher : ImageFetcher!
    
    var loadAllImages = false
    var tappedCellIndex = 0
    
    @IBOutlet weak var imageCollectionView: UICollectionView! {
        didSet{
            imageCollectionView.dataSource = self
            imageCollectionView.delegate = self
            
            //for internal drag and drop
            imageCollectionView.dragDelegate = self
            imageCollectionView.dropDelegate = self
            imageCollectionView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(adjustCellWidth(with:))))
        }
    }
    
    var userIsPinching = false
    
    var imageDataTuple : [(NSURL?, CGSize)]? {
        didSet{
            if loadAllImages == true{
                imageCollectionView?.reloadData()
                loadAllImages = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
    }

    
    @objc func adjustCellWidth(with recognizer: UIPinchGestureRecognizer){
        
        switch recognizer.state {
        
        case .changed:

            userIsPinching = true
            cellWidthScale *= recognizer.scale
            recognizer.scale = 1.0
            imageCollectionView.collectionViewLayout.invalidateLayout()
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
            
            imageCell.imageView.image = nil
            imageCell.spinner.startAnimating()
            
            
            if let url = imageDataTuple?[indexPath.row].0{
                
                imageCell.imageUrl = url
                
                //never fetch data on the main queue
                DispatchQueue.global(qos: .userInitiated).async {
                    let urlContent = try? Data(contentsOf: (url as URL).imageURL)
                    
                        //update the UI always on the main queue
                        DispatchQueue.main.async {
                            
                            //check if the url is really the one we want to show
                            if let imageData = urlContent, url == imageCell.imageUrl, let image = UIImage(data: imageData){
                                imageCell.spinner.stopAnimating()
                                imageCell.imageView.image = image
                            }

                            else{
                                imageCell.spinner.stopAnimating()
                                imageCell.imageView.image = UIImage(systemName: "xmark.octagon.fill")
                                imageCell.imageView.tintColor = UIColor.red
                                imageCell.imageView.sizeToFit()
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
            currentCellSize = CGSize(width: calculatedWidth, height: calculatedWidth * imageHeightToWidth)
            return currentCellSize
        }
        
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        tappedCellIndex = indexPath.item
        performSegue(withIdentifier: "ShowImage", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowImage"{
            
            if let destVC = segue.destination as? DetailImageViewController{
                destVC.imageUrl = imageDataTuple![tappedCellIndex].0
            }
        }
    }
}

//MARK: UICollectionViewDropDelegate
extension ImageGalleryViewController: UICollectionViewDropDelegate{
    

    //1. Can the dropDelegate handle the object?
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        //requirement: only drop with image and url should be handled
        return session.canLoadObjects(ofClass: NSURL.self)
    }

    
    //2. update the session. Return a propsal in which manner the object schould be dropped (.copy; .move...)
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
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
                
                if let url = item.dragItem.localObject as? NSURL{
                    
                    imageCollectionView.performBatchUpdates {
                        imageDataTuple?.remove(at: sourceIndexPath.item)
                        imageDataTuple?.insert((url, currentCellSize), at: destinationIntexPath.item)
                        imageCollectionView.deleteItems(at: [sourceIndexPath])
                        imageCollectionView.insertItems(at: [destinationIntexPath])
                    }
                    coordinator.drop(item.dragItem, toItemAt: destinationIntexPath)
                }
            }
            
            //external --> nil
            else{

                var dataTupel: (NSURL?, CGSize?) {
                    didSet{
                        
                        DispatchQueue.main.async {
                            if let controllerTitel = self.title, let presentImageSize = dataTupel.1, let presentURL = dataTupel.0{
                                
                                if ImageGalleryModel.imageURLs[controllerTitel] != nil {
                                    ImageGalleryModel.imageURLs[controllerTitel]!.append((presentURL, presentImageSize))
                                    print(ImageGalleryModel.imageURLs)
                                    self.imageDataTuple = ImageGalleryModel.imageURLs[controllerTitel]!
                                    self.imageCollectionView.insertItems(at: [IndexPath(item: ImageGalleryModel.imageURLs[controllerTitel]!.count - 1, section: 0)])
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
    
    
    //Proveide inital drag items
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItem(at: indexPath)
    }
    
    //Provide drag items which were added while dragging
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        
        session.localContext = collectionView
        return dragItem(at: indexPath)
    }
    
    
    
    private func dragItem(at indexPath: IndexPath) -> [UIDragItem]{
        
        if let nsURL = (imageCollectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell)?.imageUrl{
            
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: nsURL))
            
            dragItem.localObject = nsURL
            
            return [dragItem]
        }
        
        return []
    }
}

//MARK: New selected Gallery
extension ImageGalleryViewController: GalleryListViewControllerDelegate{
    func gallerySelected(name: String) {
        loadAllImages = true
        imageDataTuple = ImageGalleryModel.imageURLs[name]
        self.title = name
    }
}


