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
    
    private lazy var scrollView: UIScrollView = {
        
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    public var dataSource: BBannerViewDataSource?
    public var delegate: BBannerViewDelegate?
    private var timer: Timer?
    
    private var autoScorllTimeinterval: TimeInterval = 5    // 自动滑动时间间隔
    private var isAutoScroll: Bool = false  // 当前是否是自动滑动模式
    
    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 20))
        pc.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 20)
        self.addSubview(pc)
        return pc
    }()
    
    // block dataSource and delegate
    public var tap: ((_ bannerView: BBannerView, _ index: Int) -> ())?
    public var numberOfItems: ((_ bannerView: BBannerView) -> (Int))?
    public var viewForItem: ((_ bannerView: BBannerView, _ index: Int) -> (UIView))?
    
    // you should init with this method
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }

    func setupViews() {
        self.addSubview(self.scrollView)
    }
    
    func view(index: Int) -> UIView {
        if let dataSource = self.dataSource {
            return dataSource.viewForItem(bannerView: self, index: index)
        }
        else {
            assert((self.viewForItem != nil), "delegate 和 闭包形式的数据源都为空, 请确保使用其中一种形式")
            return self.viewForItem!(self, index)
        }
    }
    
    func itemCount() -> Int {
        if let dataSource = self.dataSource {
            return dataSource.numberOfItems()
        }
        else {
            assert(self.numberOfItems != nil, "delegate 和 闭包形式的数据源都为空, 请确保使用其中一种形式")
            return self.numberOfItems!(self)
        }
    }
    
    // recreate the banner views
    public func reloadData() {
        let itemCount = self.itemCount()
        
        // clear previous views
        let subviews = self.scrollView.subviews
        for view in subviews {
           view.removeFromSuperview()
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(itemCount), height: scrollView.frame.size.height)
        if itemCount > 1 {
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(itemCount + 2), height: scrollView.frame.size.height)
        }
        
        if itemCount > 1 {
            let itemBefore = self.view(index: itemCount - 1) // dataSource.viewForItem(bannerView: self, index: itemCount - 1)
            itemBefore.frame.origin.x = 0
            scrollView.addSubview(itemBefore)
        }
        
        for i in 0 ..< itemCount {
            let item = self.view(index: i)
            item.tag = i + 500
            
            if itemCount > 1 {
                item.frame.origin.x = scrollView.frame.size.width * CGFloat(i + 1)
            } else {
                item.frame.origin.x = scrollView.frame.size.width * CGFloat(i)
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapItem(tap:)))
            item.isUserInteractionEnabled = true
            item.addGestureRecognizer(tap)
            
            scrollView.addSubview(item)
        }
        
        if itemCount > 1 {
            let item = self.view(index: 0) // dataSource.viewForItem(bannerView: self, index: 0)
            item.frame.origin.x = scrollView.frame.size.width * CGFloat(itemCount + 1)
            scrollView.addSubview(item)
        }
        
        if itemCount > 1 {
            scrollView.scrollRectToVisible(CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height), animated: false)
        }
        
        // init page control
        if itemCount > 1 {

            self.pageControl.isHidden = false
            self.pageControl.numberOfPages = itemCount
            self.pageControl.currentPage = 0
        } else {
            self.pageControl.isHidden = true
        }
        
        // update timer
        if itemCount <= 1 {
            timer?.fireDate = (NSDate.distantFuture as NSDate) as Date
        }
    }
    
    func tapItem(tap: UITapGestureRecognizer) {
        let index = tap.view!.tag - 500
        
        // delegate call back
        if self.delegate != nil {
            self.delegate?.didSelectItem!(index: index)
        }
        
        // block call back
        if let tap = self.tap {
            tap(self, index)
        }
    }
    
    public func startAutoScroll(timeIntrval: TimeInterval) {
        
        isAutoScroll = true
        autoScorllTimeinterval = timeIntrval
        
        if timer == nil {
            timer = Timer(timeInterval: Double(timeIntrval), target: self, selector: #selector(BBannerView.next as (BBannerView) -> () -> ()), userInfo: nil, repeats: true)
        }
        
        // notice run loop mode
        RunLoop.current.add(timer!, forMode: RunLoopMode.defaultRunLoopMode)
        if self.itemCount() > 1 {
            
            timer?.fireDate =  Date.init(timeIntervalSinceNow: self.autoScorllTimeinterval)
        } else {
            timer?.fireDate = (NSDate.distantFuture as NSDate) as Date
        }
    }
    
    public func stopAutoScroll() {
        if timer != nil {
            timer?.fireDate = (NSDate.distantFuture as NSDate) as Date
        }
    }
    
    // scroll to next page
    func next() {

        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width) + 1
        
        scrollView.scrollRectToVisible(CGRect(x: CGFloat(page) * scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height), animated: true)
        
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isAutoScroll {
            self.stopAutoScroll()
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isAutoScroll {
            self.startAutoScroll(timeIntrval: self.autoScorllTimeinterval)
        }
    }
    
    // when scroll to first or last page, update scrollView's contentoffset
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if self.itemCount() > 1 {
            
            if self.scrollView.contentOffset.x >= self.scrollView.contentSize.width - self.scrollView.frame.size.width {
                // 滑动到最后一页后，要手动滑到第二页
                scrollView.scrollRectToVisible(CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height), animated: false)
            }
            else if self.scrollView.contentOffset.x <= 0 {
                scrollView.scrollRectToVisible(CGRect(x: scrollView.frame.size.width * CGFloat(self.itemCount()), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height), animated: false)
            }
            
            var indicatorPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width) - 1
            if indicatorPage == -1 {
                indicatorPage = self.itemCount() - 1
            }
            
            self.pageControl.currentPage = indicatorPage
        }
    }

}
