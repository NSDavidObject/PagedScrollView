//
//  DEPagingScrollView.swift
//  InstagramSpike
//
//  Created by David Elsonbaty on 12/11/15.
//  Copyright © 2015 David Elsonbaty. All rights reserved.
//

import UIKit

@objc
enum DEScrollDirection : Int {
    case Vertical, Horizontal
    
    func isVertical() -> Bool {
        return self == .Vertical
    }
}

@objc
protocol DEPagingScrollViewDataSource {

    func pagingScrollView(scrollView: UIScrollView, viewForIndex index: Int) -> UIView
    func pagingScrollView(scrollView: UIScrollView, viewSizeForIndex index: Int) -> CGSize
    
    func numberOfViewsForpagingScrollView(scrollView: UIScrollView) -> Int
    func scrollDirectionForPagingScrollView(scrollView: UIScrollView) -> DEScrollDirection
    
}

@objc
protocol DEPagingScrollViewDelegate {
    
    optional func pagingScrollView(scrollView: UIScrollView, DidDisplayView view: UIView, forIndex index: Int)
    
    optional func pagingScrollView(scrollView: UIScrollView, WillDismissView view: UIView, forIndex index: Int)
    optional func pagingScrollView(scrollView: UIScrollView, DidDismissView view: UIView, forIndex index: Int)
    
}

class DEPagingScrollView: UIScrollView {
    
    private var isVertical = true
    private var lastSelectedPage = 0
    private var views: [UIView] = []
    
    weak var pagingDelegate: DEPagingScrollViewDelegate?
    weak var datasource: DEPagingScrollViewDataSource? {
        didSet {
            if (datasource != nil) { self.configureScrollView() }
        }
    }
    
    weak var _scrollViewDelegate: UIScrollViewDelegate?
    override var delegate: UIScrollViewDelegate? {
        get {
            return _scrollViewDelegate
        }
        set {
            _scrollViewDelegate = newValue
        }
    }
    
    private func commonInitialization() {

        super.delegate = self
        self.pagingEnabled = true
    }
    
    init () {
        super.init(frame: CGRectZero)
        commonInitialization()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitialization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitialization()
    }
}

// MARK: - DataSource
private extension DEPagingScrollView {
    
    func configureScrollView() {
        
        guard let datasource = datasource else { return }
        
        self.views = []
        var totalWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        
        let numberOfViews = datasource.numberOfViewsForpagingScrollView(self)
        self.isVertical = datasource.scrollDirectionForPagingScrollView(self).isVertical()
        
        for idx in 0..<numberOfViews {
            
            let view = datasource.pagingScrollView(self, viewForIndex: idx)
            let viewSize = datasource.pagingScrollView(self, viewSizeForIndex: idx)
            
            view.frame = CGRectMake(isVertical ? 0 : totalWidth,
                isVertical ? totalWidth : 0,
                viewSize.width,
                viewSize.height)
            
            self.addSubview(view)
            self.views.append(view)
            
            totalWidth  += viewSize.width
            totalHeight += viewSize.height
        }
     
        // Configure Content Size
        let width = isVertical ? totalWidth / CGFloat(numberOfViews) : totalWidth
        let height = !isVertical ? totalHeight / CGFloat(numberOfViews) : totalHeight
        self.contentSize = CGSizeMake(width, height)
    }
}

extension DEPagingScrollView: UIScrollViewDelegate {
    
    private func scrollViewDidStopScrolling() {
        
        guard let delegate = self.pagingDelegate,
              selectedView = self.selectedView(),
                 viewIndex = self.views.indexOf(selectedView)
            else { return }

        delegate.pagingScrollView?(self, DidDisplayView: selectedView, forIndex: viewIndex)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        _scrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
        
        scrollViewDidStopScrolling()
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        _scrollViewDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
        
        scrollViewDidStopScrolling()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        _scrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        
        if (!decelerate) {
            scrollViewDidStopScrolling()
        }
    }
}

// MARK: Helpers
private extension DEPagingScrollView {
    
    func selectedView() -> UIView? {
        
        var selectedView: UIView?
        var contentOffset = self.isVertical ? self.contentOffset.y : self.contentOffset.x

        self.views.forEachUntil({ selectedView != nil }) { view in
         
            if (contentOffset == 0) {
                selectedView = view
            }
            
            contentOffset -= self.isVertical ? view.frame.size.height : view.frame.size.width
        }
                    
        return selectedView
    }
}






