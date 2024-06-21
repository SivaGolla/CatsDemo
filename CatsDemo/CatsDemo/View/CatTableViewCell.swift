//
//  CatTableViewCell.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 20/06/24.
//

import UIKit

class CatTableViewCell: UITableViewCell {
    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favButton: UIButton!
        
    var viewModel: ACatViewModel? {
        didSet {
            viewModelDidChange()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        catImageView.layer.cornerRadius = 5
        contentView.layer.cornerRadius = 5
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
//        catImageView.image = nil
//        favButton.setImage(nil, for: .normal)
    }
}
