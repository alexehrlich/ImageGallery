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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowImageCollection" {
            if let destVC = segue.destination as? ImageGalleryViewController, let gallery = selectedGallery{
                destVC.imageURLs = ImageGalleryModel.imageURLs[gallery]!
            }
        }
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
        let cell = galleryListTableView.dequeueReusableCell(withIdentifier: "GalleryListCell", for: indexPath)
        
        if indexPath.section == 0{
            let keys = Array(ImageGalleryModel.imageURLs.keys).sorted()
            cell.textLabel?.text = keys[indexPath.row]
        }else if indexPath.row == 1 {
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
        
        performSegue(withIdentifier: "ShowImageCollection", sender: self)
        
    }
    
    
}
