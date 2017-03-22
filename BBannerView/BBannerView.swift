//
//  BBannerView.swift
//  BBannerView
//
//  Created by Brant on 5/13/15.
//  Copyright (c) 2015 brant. All rights reserved.
//

import UIKit

@objc public protocol BBannerViewDelegate {
    @objc optional func didSelectItem(index: Int)
}

@objc public protocol BBannerViewDataSource {
    func viewForItem(bannerView: BBannerView, index: Int) -> UIView
    func numberOfItems() -> Int
}

public class BBannerView: UIView, UIScrollViewDelegate {
    
    private var scrollView: UIScrollView!
    
    var dataSource: BBannerViewDataSource!
    var delegate: BBannerViewDelegate?
    private var timer: Timer?
    
    var pageControl: UIPageControl?
    
    // you should init with this method
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView.isPagingEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
        self.addSubview(self.scrollView)
    }
    
    func reloadData() {
        let itemCount = dataSource.numberOfItems()
        
        let subviews = self.scrollView.subviews
        for view in subviews {
           view.removeFromSuperview()
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(dataSource.numberOfItems()), height: scrollView.frame.size.height)
        if dataSource.numberOfItems() > 1 {
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(dataSource.numberOfItems() + 2), height: scrollView.frame.size.height)
        }
        
        if dataSource.numberOfItems() > 1 {
            let itemBefore = dataSource.viewForItem(bannerView: self, index: dataSource.numberOfItems() - 1)
            itemBefore.frame.origin.x = 0
            scrollView.addSubview(itemBefore)
        }
        
        for i in 0 ..< itemCount {
            let item = dataSource.viewForItem(bannerView: self, index: i)
            item.tag = i + 500
            
            if itemCount > 1 {
                item.frame.origin.x = scrollView.frame.size.width * CGFloat(i + 1)
            } else {
                item.frame.origin.x = scrollView.frame.size.width * CGFloat(i)
            }
            
            let tap = UITapGestureRecognizer(target: self, action: Selector("tapItem:"))
            item.isUserInteractionEnabled = true
            item.addGestureRecognizer(tap)
            
            scrollView.addSubview(item)
        }
        
        if dataSource.numberOfItems() > 1 {
            let item = dataSource.viewForItem(bannerView: self, index: 0)
            item.frame.origin.x = scrollView.frame.size.width * CGFloat(dataSource.numberOfItems() + 1)
            scrollView.addSubview(item)
        }
        
        if dataSource.numberOfItems() > 1 {
            scrollView.scrollRectToVisible(CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height), animated: false)
        }
        
        // init page control
        if itemCount > 1 {
            if pageControl == nil {
                pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 20))
                pageControl?.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 20)
                addSubview(pageControl!)
            }
            
            pageControl?.isHidden = false
            pageControl?.numberOfPages = itemCount
            pageControl?.currentPage = 0
        } else {
            pageControl?.isHidden = true
        }
    }
    
    func tapItem(tap: UITapGestureRecognizer) {
        let index = tap.view!.tag - 500
        if self.delegate != nil {
            self.delegate?.didSelectItem!(index: index)
        }
    }
    
    func startAutoScroll(timeIntrval: Int) {
        if timer == nil {
            timer = Timer(timeInterval: Double(timeIntrval), target: self, selector: #selector(BBannerView.next as (BBannerView) -> () -> ()), userInfo: nil, repeats: true)
        }
        
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
        if self.dataSource.numberOfItems() > 1 {
            timer?.fireDate = NSDate() as Date
        } else {
            timer?.fireDate = (NSDate.distantFuture as NSDate) as Date
        }
    }
    
    func stopAutoScroll() {
        if timer != nil {
            timer?.fireDate = (NSDate.distantFuture as NSDate) as Date
        }
    }
    
    // scroll to next page
    func next() {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width) + 1
        scrollView.scrollRectToVisible(CGRect(x: CGFloat(page) * scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height), animated: true)
    }
    
    // when scroll to first or last page, update scrollView's contentoffset
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if dataSource.numberOfItems() > 1 {
            
            if scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.frame.size.width) == 0 {
                let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width) + 1
                if page == dataSource.numberOfItems() + 2 {
                    scrollView.scrollRectToVisible(CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height), animated: false)
                } else if page == 1 {
                    scrollView.scrollRectToVisible(CGRect(x: scrollView.frame.size.width * CGFloat(dataSource.numberOfItems()), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height), animated: false)
                }
            }
            
            let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width) - 1
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
