//
//  CatsViewController.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 20/06/24.
//

import UIKit

class CatsViewController: UIViewController {

    @IBOutlet weak var catsTableView: UITableView!
    
    let viewModel = CatsViewModel()
    
    let favImage = UIImage(systemName: "heart.fill")!.withTintColor(.red, renderingMode: .alwaysTemplate)
    let unFavImage = UIImage(systemName: "heart")!.withTintColor(.red, renderingMode: .alwaysTemplate)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Cats Collection"
        view.accessibilityIdentifier = "catsCollection"
        catsTableView.register(UINib(nibName: "CatTableViewCell", bundle: nil), forCellReuseIdentifier: "CatTableViewCell")
//        catsTableView.dataSource = photoDataSource
//        catsTableView.prefetchDataSource = self
        catsTableView.rowHeight = UITableView.automaticDimension
        catsTableView.estimatedRowHeight = 320
        catsTableView.separatorStyle = .none
        catsTableView.separatorColor = .clear
    }

}

extension CatsViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.catModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        cell.textLabel?.text = "Item \(indexPath.row)"
        cell.imageView?.image = nil // Reset image to avoid flickering
        
        // Load image for the cell
        viewModel.image(at: indexPath) { image in
            DispatchQueue.main.async {
                if let currentCell = tableView.cellForRow(at: indexPath) {
                    currentCell.imageView?.image = image
                }
            }
        }
        
        return cell
    }
    
    // UITableViewDataSourcePrefetching methods
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            viewModel.image(at: indexPath) { _ in
                // Prefetching image
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            viewModel.cancelImageLoad(at: indexPath)
        }
    }
}


