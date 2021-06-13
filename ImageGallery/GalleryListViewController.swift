//
//  GalleryListViewController.swift
//  ImageGallery
//
//  Created by Alexander Ehrlich on 08.05.21.
//

import UIKit

protocol GalleryListViewControllerDelegate {
    func gallerySelected(name: String)
}

class GalleryListViewController: UIViewController {

    @IBOutlet weak var galleryListTableView: UITableView!{
        
        didSet{
            galleryListTableView.dataSource = self
            galleryListTableView.delegate = self
        }
    }
    
    var delegate: GalleryListViewControllerDelegate!
    
    var selectedGallery: String?
    
    override func viewDidLoad() {

        if ImageGalleryModel.imageURLs.isEmpty{
            //do something
        }else{
            let keys = Array(ImageGalleryModel.imageURLs.keys).sorted()
            selectedGallery = keys.first!
        }
    }
    
    @IBAction func addGallery(_ sender: UIBarButtonItem) {
        
        let keys = ImageGalleryModel.imageURLs.keys.sorted() + ImageGalleryModel.recentlyDeletedGallery.keys.sorted()
        
        let name: String = "New Gallery ".madeUnique(withRespectTo: keys)
        ImageGalleryModel.imageURLs[name] = [(NSURL?, CGSize)]()
        
        galleryListTableView.reloadData()
    }
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
        if let cell = galleryListTableView.dequeueReusableCell(withIdentifier: "GalleryListCell", for: indexPath) as? ListTableViewCell{
            
            if indexPath.section == 0{
                
                cell.galleryNameTextField.isEnabled = false
                cell.delegate = self
                
                let keys = Array(ImageGalleryModel.imageURLs.keys).sorted()
                cell.galleryNameTextField.text = keys[indexPath.row]
                cell.oldLabel = keys[indexPath.row]
            }else if indexPath.section == 1 {
                let keys = Array(ImageGalleryModel.recentlyDeletedGallery.keys).sorted()
                cell.galleryNameTextField.text = keys[indexPath.row]
                cell.oldLabel = keys[indexPath.row]
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            let keys = Array(ImageGalleryModel.imageURLs.keys).sorted()
            selectedGallery = keys[indexPath.row]
            delegate.gallerySelected(name: selectedGallery!)
            
            //IPhone Code t oshow the detailVC after selecting a cell
            if let detailVC = delegate as? ImageGalleryViewController, let detailNavigationController = detailVC.navigationController{
                splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
            }
        }else{
            selectedGallery = nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
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
        
        //only add swipe action to recently deleted
        if indexPath.section == 1 {
            let actions = UIContextualAction(style: .normal, title: "restore") { (action, view, closure) in
                
                let key = ImageGalleryModel.recentlyDeletedGallery.keys.sorted()[indexPath.row]
                let removedItem = ImageGalleryModel.recentlyDeletedGallery.removeValue(forKey: key)
                ImageGalleryModel.recentlyDeletedGallery.removeValue(forKey: key)
                ImageGalleryModel.imageURLs[key] = removedItem
                self.galleryListTableView.reloadData()
            }
            return UISwipeActionsConfiguration(actions: [actions])
        }
        return nil
    }
}

//MARK: Update from the Name editing
extension GalleryListViewController: ListTableViewDelegate{
    func updateListName(with string: String, for oldValue: String) {
        
        ImageGalleryModel.imageURLs[string] = ImageGalleryModel.imageURLs[oldValue]
        ImageGalleryModel.imageURLs.removeValue(forKey: oldValue)
        
        galleryListTableView.reloadData()
        
        selectedGallery = string
    }
}


