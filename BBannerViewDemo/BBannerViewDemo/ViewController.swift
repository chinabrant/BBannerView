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
        bbannerView.startAutoScroll(timeIntrval: 2)
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
        print("index: \(index)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

