//
//  CatTableViewCell.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 20/06/24.
//

import UIKit

protocol CatTableViewCellDelegate: AnyObject {
    func toggleFavButton(favID: String?, catBreed: CatBreed, type: FavOpType)
}

class CatTableViewCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favButton: UIButton!
        
    weak var delegate: CatTableViewCellDelegate? = nil
    
    var viewModel: ACatViewModel? {
        didSet {
            viewModelDidChange()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        catImageView.addCornerRadius(5)
        containerView.addCornerRadius()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        catImageView.image = nil
        nameLabel.text = ""
        favButton.setImage(nil, for: .normal)
    }
    
    func viewModelDidChange() {
        guard let viewModel = viewModel else { return }
        
        nameLabel.text = viewModel.name
        favButton.setImage(viewModel.isFavorite ? Constants.favImage : Constants.unFavImage, for: .normal)
    }
    
    @IBAction func didSelectFavButton(_ sender: Any) {
        guard let viewModel = viewModel else {
            return
        }
        
        delegate?.toggleFavButton(favID: "\(viewModel.favID)",
                                  catBreed: viewModel.model,
                                  type: viewModel.isFavorite ? FavOpType.remove : FavOpType.update)
    }
}
