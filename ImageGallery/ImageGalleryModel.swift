//
//  ImageGalleryModel.swift
//  ImageGallery
//
//  Created by Alexander Ehrlich on 09.05.21.
//

import UIKit

struct ImageGalleryModel {
    
    static var imageURLs : [String: [(NSURL?, CGSize)]] = ["Meine Gallerie" : [(NSURL(string: "https://www.google.com/imgres?imgurl=https%3A%2F%2Fstore.storeimages.cdn-apple.com%2F4668%2Fas-images.apple.com%2Fis%2Fiphone-11-og-201909%3Fwid%3D1200%26hei%3D630%26fmt%3Djpeg%26qlt%3D95%26.v%3D1566949840644&imgrefurl=https%3A%2F%2Fwww.apple.com%2Fde%2Fshop%2Fbuy-iphone%2Fiphone-11&tbnid=ioJqLKyAEOBdzM&vet=12ahUKEwjl4emF1b_wAhUK86QKHVoLDbIQMygbegUIARD5AQ..i&docid=SELnF-KiIHBshM&w=1200&h=630&q=apple&client=safari&ved=2ahUKEwjl4emF1b_wAhUK86QKHVoLDbIQMygbegUIARD5AQ"), CGSize(width: 100, height: 80))]]
    static var recentlyDeletedGallery = [String: [(NSURL?, CGSize)]]()
    
}
