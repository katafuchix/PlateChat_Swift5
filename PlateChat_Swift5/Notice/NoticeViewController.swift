//
//  NoticeViewController.swift
//  PlateChat
//
//  Created by cano on 2018/09/02.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Rswift
import XLPagerTabStrip

class NoticeViewController: SegmentedPagerTabStripViewController {

    @IBOutlet weak var refreshButton: UIBarButtonItem!

    static let pv1 = R.storyboard.footPrint.footPrintViewController()!
    static let pv2 = R.storyboard.articleReplyLog.articleReplyLogViewController()!

    var isReload = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // change segmented style
        settings.style.segmentedControlColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        settings.style.segmentedControlColor = .white

        self.refreshButton.rx.tap.subscribe(onNext: { [unowned self] _ in
            switch self.segmentedControl.selectedSegmentIndex {
            case 0:
                NoticeViewController.pv1.observeFootprint()
            case 1:
                NoticeViewController.pv2.observeArticleReplyLog()
            default:
                break
            }
            //NoticeViewController.pv1.observeFootprint()
            //NoticeViewController.pv2.observeArticleReplyLog()
        }).disposed(by: rx.disposeBag)
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {

        let pv1 = NoticeViewController.pv1
        let pv2 = NoticeViewController.pv2

        guard isReload else {
            return [pv1, pv2]
        }

        var childViewControllers = [pv1, pv2]
        let count = childViewControllers.count

        for index in childViewControllers.indices {
            let nElements = count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index {
                childViewControllers.swapAt(index, n)
            }
        }
        let nItems = 1 + (arc4random() % 4)
        return Array(childViewControllers.prefix(Int(nItems)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
