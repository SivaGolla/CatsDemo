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
    @IBOutlet weak var wikiView: UITextView!
    
    var viewModel: ACatDetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        catImageView.layer.cornerRadius = 5
        configure()
    }
    
    private func configure() {
        
        guard let viewModel = viewModel else {
            return
        }
        
        title = viewModel.titleText
        catInfoTextView.text = viewModel.fullText
        viewModel.loadRemoteImage { [weak self] image in
            DispatchQueue.main.async {
                self?.catImageView.image = image
            }
        }
        
        let attributedString = NSMutableAttributedString(string: viewModel.linkText)
        attributedString.addAttribute(.link, value: viewModel.wikiLink, range: NSRange(location: Constants.wikiHeader.count - 1, length: viewModel.wikiLink.count))

        wikiView.attributedText = attributedString
        wikiView.delegate = self
    }
}

extension ACatDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
