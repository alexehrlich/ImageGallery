//
//  ImageGalleryModel.swift
//  ImageGallery
//
//  Created by Alexander Ehrlich on 09.05.21.
//

import UIKit

struct ImageGalleryModel {
    
    static var imageURLs : [String: [(NSURL?, CGSize)]] = ["Meine Gallerie" : [(NSURL(string: "https://www.nasa.gov/sites/default/files/wave_earth_mosaic_3.jpg"), CGSize(width: 100, height: 80))]]
    static var recentlyDeletedGallery = [String: [(NSURL?, CGSize)]]()
    
}
