//
//  ViewController.swift
//  PagedScrollView
//
//  Created by David Elsonbaty on 12/12/15.
//  Copyright © 2015 David Elsonbaty. All rights reserved.
//

import UIKit

private struct Constants {
    
    static let NumberOfCells = 20
}

class ViewController: UIViewController {
    
    @IBOutlet weak var scrollView: DEPagingScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.scrollView.datasource = self
        self.scrollView.pagingDelegate = self
        self.scrollView.clipsToBounds = false
    }
}

extension ViewController: DEPagingScrollViewDelegate {
    
    func pagingScrollView(scrollView: UIScrollView, didDisplayView view: UIView, forIndex index: Int) {

    }
    
    func pagingScrollView(scrollView: UIScrollView, didScrollPastView view: UIView, forIndex index: Int, visibility: CGFloat) {
        view.alpha = (1 - visibility)
    }
}

extension ViewController: DEPagingScrollViewDataSource {
    
    func scrollDirectionForPagingScrollView(scrollView: UIScrollView) -> DEScrollDirection {
        return .Vertical
    }
    
    func numberOfViewsForpagingScrollView(scrollView: UIScrollView) -> Int {
        return Constants.NumberOfCells
    }
    
    func pagingScrollView(scrollView: UIScrollView, viewSizeForIndex index: Int) -> CGSize {
        return CGSizeMake(self.view.frame.width, self.view.frame.width)
    }
    
    func pagingScrollView(scrollView: UIScrollView, viewForIndex index: Int) -> UIView {
        
        let view = UIView()
        view.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(255))/CGFloat(255), green: CGFloat(arc4random_uniform(255))/CGFloat(255), blue: CGFloat(arc4random_uniform(255))/CGFloat(255), alpha: 0.8)
        return view
    }
}