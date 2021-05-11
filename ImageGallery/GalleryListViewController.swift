//
//  GalleryListViewController.swift
//  ImageGallery
//
//  Created by Alexander Ehrlich on 08.05.21.
//

import UIKit

class GalleryListViewController: UIViewController {

    @IBOutlet weak var galleryListTableView: UITableView!{
        
        didSet{
            galleryListTableView.dataSource = self
            galleryListTableView.delegate = self
        }
        
    }
    
    var selectedGallery: String?
    
}

//MARK: TableView DataSource and Delegate

extension GalleryListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section{
        
        case 0: return ImageGalleryModel.imageURLs.count
        case 1: return ImageGalleryModel.recentlyDeletedGallery.count
        default: return 0
            
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Your Gallieries" : "Recently Deleted"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = galleryListTableView.dequeueReusableCell(withIdentifier: "GalleryListCell", for: indexPath)
        
        if indexPath.section == 0{
            let keys = Array(ImageGalleryModel.imageURLs.keys).sorted()
            cell.textLabel?.text = keys[indexPath.row]
        }else if indexPath.section == 1 {
            let keys = Array(ImageGalleryModel.recentlyDeletedGallery.keys).sorted()
            cell.textLabel?.text = keys[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            let keys = Array(ImageGalleryModel.imageURLs.keys).sorted()
            selectedGallery = keys[indexPath.row]
        }else{
            selectedGallery = nil
        }
      
        if let detailVC = splitViewController?.viewControllers[1] as? UINavigationController{
            
            if let imageGalleryVC = detailVC.viewControllers.first as? ImageGalleryViewController{
                
                if let gallery = selectedGallery{
                    imageGalleryVC.title = gallery
                    imageGalleryVC.imageDataTuple = ImageGalleryModel.imageURLs[gallery] ?? []
                    imageGalleryVC.imageCollectionView.reloadData()
                }else{
                    detailVC.title = "Gallery"
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle{
        
        case .delete:
            
            if indexPath.section == 0{
                let key = ImageGalleryModel.imageURLs.keys.sorted()[indexPath.row]
                let removedItem = ImageGalleryModel.imageURLs.removeValue(forKey: key)
                ImageGalleryModel.recentlyDeletedGallery[key] = removedItem
            }else{
                let key = ImageGalleryModel.recentlyDeletedGallery.keys.sorted()[indexPath.row]
                ImageGalleryModel.recentlyDeletedGallery.removeValue(forKey: key)
            }
            
            galleryListTableView.reloadData()
            
        default: break
            
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let actions = UIContextualAction(style: .normal, title: "restore") { (action, view, closure) in
            
            let key = ImageGalleryModel.recentlyDeletedGallery.keys.sorted()[indexPath.row]
            let removedItem = ImageGalleryModel.recentlyDeletedGallery.removeValue(forKey: key)
            ImageGalleryModel.recentlyDeletedGallery.removeValue(forKey: key)
            ImageGalleryModel.imageURLs[key] = removedItem
            
            self.galleryListTableView.reloadData()
        }
        
        return UISwipeActionsConfiguration(actions: [actions])
    }
}

