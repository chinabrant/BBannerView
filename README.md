# BBannerView
A cycle banner view by swift, 160 lines code, easy to modify.

# Requirements

iOS7 or higher
support swift 3 : 1.1.0

# HOW TO USE

You only need drag the BBannerView.swift to your project.

```swift
	bbannerView = BBannerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 250))
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

# Podfile

If you use CocoaPods, you can install the latest release version of BBannerView  by adding the following to your project's Podfile:
```
pod 'BBannerView'
```
# LICENSE
BBannerView is licensed under the `MIT` License.
