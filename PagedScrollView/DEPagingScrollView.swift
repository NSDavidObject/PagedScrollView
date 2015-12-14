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
protocol DEPagingScrollViewDelegate : NSObjectProtocol {
    
    optional func pagingScrollView(scrollView: UIScrollView, didDisplayView view: UIView, forIndex index: Int)
    optional func pagingScrollView(scrollView: UIScrollView, didScrollPastView view: UIView, forIndex index: Int, visibility: CGFloat)
    
}

class DEPagingScrollView: UIScrollView {
    
    private var isVertical = true
    private var views: [UIView] = []
    private var lastSelectedPage = 0
    private var lastContentOffset: CGFloat = 0
    
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
                isVertical ? totalHeight : 0,
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
            (viewIndex, selectedView) = self.selectedViewInfo()
            where lastSelectedPage != viewIndex else { return }
        
        self.lastSelectedPage = viewIndex
        delegate.pagingScrollView?(self, didDisplayView: selectedView, forIndex: viewIndex)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        _scrollViewDelegate?.scrollViewDidScroll?(scrollView)
        
        guard let pagingDelegate = pagingDelegate
            where pagingDelegate.respondsToSelector("pagingScrollView:didScrollPastView:forIndex:visibility:")  else {
            return
        }
        
        let fistVisibleView = self.firstVisibleViewInfo()
        let currentContentOffset = isVertical ? scrollView.contentOffset.y : scrollView.contentOffset.x
        
        var visibleView = fistVisibleView?.1
        var visibleViewIndex = fistVisibleView?.0
        var visibleSize = isVertical ? scrollView.frame.height : scrollView.frame.width
        
        while let currVisibleView = visibleView, currVisibleViewIndex = visibleViewIndex where visibleSize > 0 {

            var visibility: CGFloat = 1
            let viewSize = isVertical ? currVisibleView.frame.height : currVisibleView.frame.width
            let viewOrigin = isVertical ? currVisibleView.frame.origin.y : currVisibleView.frame.origin.x
            
            if viewOrigin < currentContentOffset {

                visibility = (viewOrigin + viewSize - currentContentOffset) / viewSize
                
            } else {
                
                visibility = min( visibleSize / viewSize , 1)
            }
            
            pagingDelegate.pagingScrollView?(self, didScrollPastView: currVisibleView, forIndex: currVisibleViewIndex, visibility: visibility)
            
            visibleSize -= (viewSize * visibility)
            
            let nextIndex = currVisibleViewIndex.successor()
            if nextIndex < views.count {
            
                visibleViewIndex = nextIndex
                visibleView = views[nextIndex]
            }
        }
        
        lastContentOffset = currentContentOffset
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
    
    func selectedViewInfo() -> (Int, UIView)? {
        return viewInfoGetter(true)
    }
    
    func firstVisibleViewInfo() -> (Int, UIView)? {
        return viewInfoGetter(false)
    }
    
    // Selected or First Visible
    func viewInfoGetter(selected: Bool) -> (Int, UIView)? {
     
        var selectedView: (Int, UIView)?
        var contentOffset = self.isVertical ? self.contentOffset.y : self.contentOffset.x
        
        self.views.forEachUntil({ selectedView != nil }) { (idx, view) in
            
            if (selected && contentOffset <= 0) {
                selectedView = (idx, view)
            }
            
            contentOffset -= self.isVertical ? view.frame.size.height : view.frame.size.width
            
            if (!selected && contentOffset <= 0) {
                selectedView = (idx, view)
            }
        }
        
        return selectedView
    }
}






