# BBannerView
A cycle banner view by swift, easy to modify.

一个swift写的广告轮播组件，支持代理和闭包的形式设置数据源和事件代理。代码少容易修改，可以很方便定制。

# Requirements

* iOS8 or higher
* swift 3

# How to use?

代理和闭包同时设置时，data source会优先使用代理。事件两个都会响应.

### 代理的形式

```swift
    bbannerView = BBannerView(frame: CGRect(x: 0, 
                                            y: 0, 
                                        width: UIScreen.main.bounds.size.width, 
                                        height: 250))
    bbannerView.dataSource = self
    bbannerView.delegate = self
    view.addSubview(bbannerView)
    bbannerView.reloadData()
    bbannerView.startAutoScroll(timeIntrval: 2)
   
    
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

```


### 闭包的形式

```swift
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
```

# 集成


* If you use CocoaPods, you can install the latest release version of BBannerView  by adding the following to your project's Podfile:

> pod 'BBannerView'

* 直接拖`BBannerView.swift`到你的项目

# LICENSE
BBannerView is licensed under the `MIT` License.
