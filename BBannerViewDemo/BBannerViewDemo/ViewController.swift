//
//  ViewController.swift
//  BBannerViewDemo
//
//  Created by Brant on 5/25/15.
//  Copyright (c) 2015 brant. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BBannerViewDelegate, BBannerViewDataSource {

    
    var bbannerView: BBannerView!
    
    var banner2: BBannerView = {
        let banner = BBannerView(frame: CGRect(x: 0, y: 300, width: UIScreen.main.bounds.size.width, height: 250))
        
        return banner
    }()
    
    var images = ["image_1.png", "image_2.png", "image_3.png"]
    //    var images = ["1.png"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        
        bbannerView = BBannerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 250))
        bbannerView.dataSource = self
        bbannerView.delegate = self
        view.addSubview(bbannerView)
        bbannerView.reloadData()
        bbannerView.startAutoScroll(timeIntrval: 4)
        
        self.view.addSubview(self.banner2)
        self.banner2.numberOfItems = { (bannerView: BBannerView) -> Int in
            return self.images.count
        }
        
        self.banner2.viewForItem = { (bannerView: BBannerView, index: Int) -> UIView in
            let imageView = UIImageView(frame: bannerView.bounds)
            imageView.image = UIImage(named: self.images[index])
            
            return imageView
        }
        
        self.banner2.tap = { (bannerView: BBannerView, index: Int) in
            print("banner2 tap: %d", index)
        }
        
        
        banner2.reloadData()
        banner2.startAutoScroll(timeIntrval: 2)
    }
    
    // MARK: - BBanerViewDataSource
    
    func numberOfItems() -> Int {
        return images.count
    }
    
    func viewForItem(bannerView: BBannerView, index: Int) -> UIView {
        let imageView = UIImageView(frame: bannerView.bounds)
        imageView.image = UIImage(named: images[index])
        
        return imageView
    }
    
    // MARK: - BBannerViewDelegate
    
    func didSelectItem(index: Int) {
        print("banner1 index: \(index)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

