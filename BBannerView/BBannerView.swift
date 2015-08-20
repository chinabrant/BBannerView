//
//  BBannerView.swift
//  BBannerView
//
//  Created by Brant on 5/13/15.
//  Copyright (c) 2015 brant. All rights reserved.
//

import UIKit

@objc protocol BBannerViewDelegate {
    optional func didSelectItem(index: Int)
}

@objc protocol BBannerViewDataSource {
    func viewForItem(bannerView: BBannerView, index: Int) -> UIView
    func numberOfItems() -> Int
}

class BBannerView: UIView, UIScrollViewDelegate {
    
    private var scrollView: UIScrollView!
    
    var dataSource: BBannerViewDataSource!
    var delegate: BBannerViewDelegate?
    private var timer: NSTimer?
    
    var pageControl: UIPageControl?
    
    // you should init with this method
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView.pagingEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
        self.addSubview(self.scrollView)
    }
    
    func reloadData() {
        var itemCount = dataSource.numberOfItems()
        
        var subviews = self.scrollView.subviews
        for view in subviews {
           view.removeFromSuperview()
        }
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * CGFloat(dataSource.numberOfItems()), scrollView.frame.size.height)
        if dataSource.numberOfItems() > 1 {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * CGFloat(dataSource.numberOfItems() + 2), scrollView.frame.size.height)
        }
        
        if dataSource.numberOfItems() > 1 {
            var itemBefore = dataSource.viewForItem(self, index: dataSource.numberOfItems() - 1)
            itemBefore.frame.origin.x = 0
            scrollView.addSubview(itemBefore)
        }
        
        for var i = 0; i < itemCount; i++ {
            var item = dataSource.viewForItem(self, index: i)
            item.tag = i + 500
            
            if itemCount > 1 {
                item.frame.origin.x = scrollView.frame.size.width * CGFloat(i + 1)
            } else {
                item.frame.origin.x = scrollView.frame.size.width * CGFloat(i)
            }
            
            var tap = UITapGestureRecognizer(target: self, action: "tapItem:")
            item.userInteractionEnabled = true
            item.addGestureRecognizer(tap)
            
            scrollView.addSubview(item)
        }
        
        if dataSource.numberOfItems() > 1 {
            var item = dataSource.viewForItem(self, index: 0)
            item.frame.origin.x = scrollView.frame.size.width * CGFloat(dataSource.numberOfItems() + 1)
            scrollView.addSubview(item)
        }
        
        if dataSource.numberOfItems() > 1 {
            scrollView.scrollRectToVisible(CGRectMake(scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height), animated: false)
        }
        
        // init page control
        if itemCount > 1 {
            if pageControl == nil {
                pageControl = UIPageControl(frame: CGRectMake(0, 0, self.frame.size.width, 20))
                pageControl?.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height - 20)
                addSubview(pageControl!)
            }
            
            pageControl?.hidden = false
            pageControl?.numberOfPages = itemCount
            pageControl?.currentPage = 0
        } else {
            pageControl?.hidden = true
        }
    }
    
    func tapItem(tap: UITapGestureRecognizer) {
        var index = tap.view!.tag - 500
        if self.delegate != nil {
            self.delegate?.didSelectItem!(index)
        }
    }
    
    func startAutoScroll(timeIntrval: Int) {
        if timer == nil {
            timer = NSTimer(timeInterval: Double(timeIntrval), target: self, selector: "next", userInfo: nil, repeats: true)
        }
        
        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        if self.dataSource.numberOfItems() > 1 {
            timer?.fireDate = NSDate()
        } else {
            timer?.fireDate = NSDate.distantFuture() as! NSDate
        }
    }
    
    func stopAutoScroll() {
        if timer != nil {
            timer?.fireDate = NSDate.distantFuture() as! NSDate
        }
    }
    
    // scroll to next page
    func next() {
        var page = Int(scrollView.contentOffset.x / scrollView.frame.size.width) + 1
        scrollView.scrollRectToVisible(CGRectMake(CGFloat(page) * scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height), animated: true)
    }
    
    // when scroll to first or last page, update scrollView's contentoffset
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if dataSource.numberOfItems() > 1 {
            if scrollView.contentOffset.x % scrollView.frame.size.width == 0 {
                var page = Int(scrollView.contentOffset.x / scrollView.frame.size.width) + 1
                if page == dataSource.numberOfItems() + 2 {
                    scrollView.scrollRectToVisible(CGRectMake(scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height), animated: false)
                } else if page == 1 {
                    scrollView.scrollRectToVisible(CGRectMake(scrollView.frame.size.width * CGFloat(dataSource.numberOfItems()), 0, scrollView.frame.size.width, scrollView.frame.size.height), animated: false)
                }
            }
            
            var page = Int(scrollView.contentOffset.x / scrollView.frame.size.width) - 1
            if page == -1 {
                page == dataSource.numberOfItems() - 1
            }
            
            pageControl?.currentPage = page
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
//    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        
//        if dataSource.numberOfItems() > 1 {
//            var page = Int(scrollView.contentOffset.x / scrollView.frame.size.width) + 1
//            if page == dataSource.numberOfItems() + 2 {
//                scrollView.scrollRectToVisible(CGRectMake(scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height), animated: false)
//            } else if page == 0 {
//                scrollView.scrollRectToVisible(CGRectMake(scrollView.frame.size.width * CGFloat(dataSource.numberOfItems()), 0, scrollView.frame.size.width, scrollView.frame.size.height), animated: false)
//            }
//        }
//    }

}
