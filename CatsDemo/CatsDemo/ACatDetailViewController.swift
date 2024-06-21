//
//  ACatDetailViewController.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 21/06/24.
//

import UIKit

class ACatDetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var catInfoTextView: UITextView!
    var viewModel: ACatDetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        catImageView.layer.cornerRadius = 5
        loadCatDetailViews()
    }
    
    private func loadCatDetailViews() {
        title = viewModel?.titleText
        catInfoTextView.text = viewModel?.fullText
        viewModel?.loadRemoteImage { [weak self] image in
            DispatchQueue.main.async {
                self?.catImageView.image = image
            }
        }
//        wikilinkLabel.text = viewModel?.linkText
    }
}
