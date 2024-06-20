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
    
    let favImage = UIImage(systemName: "heart.fill")!.withTintColor(.red, renderingMode: .automatic)
    let unFavImage = UIImage(systemName: "heart")!.withTintColor(.red, renderingMode: .automatic)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Cats Collection"
        view.accessibilityIdentifier = "catsCollection"
        catsTableView.register(UINib(nibName: "CatTableViewCell", bundle: nil), forCellReuseIdentifier: "CatTableViewCell")
        catsTableView.dataSource = self
        catsTableView.delegate = self
        catsTableView.prefetchDataSource = self
        catsTableView.rowHeight = UITableView.automaticDimension
        catsTableView.estimatedRowHeight = 320
        catsTableView.separatorStyle = .none
        catsTableView.separatorColor = .clear
        
        fetchRemoteCatList()
    }
    
    func fetchRemoteCatList() {
        viewModel.loadCatList { [weak self] result in
            switch result {
            case .success(let catList):
                if catList.isEmpty {
//                    self?.showErrorPrompt()
                    return
                }
                
                self?.viewModel.catModels = catList
                DispatchQueue.main.async {
                    self?.catsTableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}

extension CatsViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.catModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CatTableViewCell", for: indexPath) as! CatTableViewCell
        let item = viewModel.catModels[indexPath.row]
        cell.nameLabel?.text = item.id
        cell.catImageView?.image = nil // Reset image to avoid flickering
        
        // Load image for the cell
        loadCatImage(at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // Load image for the cell
        loadCatImage(at: indexPath)
    }
    
    // UITableViewDataSourcePrefetching methods
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            loadCatImage(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            viewModel.cancelImageLoad(at: indexPath)
        }
    }
        
    func loadCatImage(at indexPath: IndexPath) {
        viewModel.image(at: indexPath) { [weak self] image in
            DispatchQueue.main.async {
                if let currentCell = self?.catsTableView.cellForRow(at: indexPath) as? CatTableViewCell {
                    currentCell.catImageView?.image = image
                }
            }
        }
    }
}


