//
//  GalleryListTableViewCell.swift
//  ImageGallery
//
//  Created by Alexander Ehrlich on 15.05.21.
//

protocol ListTableViewDelegate {
    func updateListName(with string: String, for oldValue: String)
}

import UIKit

class ListTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var oldLabel = String()
    
    var delegate: GalleryListViewController?

    @IBOutlet weak var galleryNameTextField: UITextField!{
        didSet{
            
            self.isUserInteractionEnabled = true
            
            galleryNameTextField.delegate = self

            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(beginEditing(with:)))
            tapRecognizer.numberOfTapsRequired = 2
            self.addGestureRecognizer(tapRecognizer)
        }
    }
    
    @objc func beginEditing(with recognizer: UITapGestureRecognizer){
        
        switch recognizer.state{
            case .ended:
            galleryNameTextField.isEnabled = true
            galleryNameTextField.becomeFirstResponder()
                
            default: break
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        galleryNameTextField.isEnabled = false
        galleryNameTextField.resignFirstResponder()
       
        if let newName = galleryNameTextField.text{
            delegate?.updateListName(with: newName, for: oldLabel)
        }
        
        return true
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
