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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureView()
        bindViewModel()
        
        LoadingView.start()
        viewModel.fetchAllCatsWithFavs()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoadCatDetails" {
            
            let viewModel = ACatDetailViewModel(model: (sender as! CatBreed))
            let destinationViewController = segue.destination as! ACatDetailViewController
            destinationViewController.viewModel = viewModel
        }
    }
}

// MARK: - Private Methods
extension CatsViewController {
    private func configureView() {
        title = "Whisker World"
        view.accessibilityIdentifier = "catsCollection"
        catsTableView.register(UINib(nibName: "CatTableViewCell", bundle: nil), forCellReuseIdentifier: "CatTableViewCell")
        catsTableView.dataSource = self
        catsTableView.delegate = self
        catsTableView.prefetchDataSource = self
        catsTableView.rowHeight = UITableView.automaticDimension
        catsTableView.estimatedRowHeight = 320
        catsTableView.separatorStyle = .none
        catsTableView.separatorColor = .clear
    }
    
    private func bindViewModel() {
        viewModel.itemsDidChange = { [weak self] in
            LoadingView.stop()
            self?.catsTableView.reloadData()
        }
        
        viewModel.serviceDidFailed = { [weak self] error in
            
            DispatchQueue.main.async {
                LoadingView.stop()
                self?.showErrorPrompt()
            }
            
            print("Error during cat list fetch")
        }
    }
    
    private func loadCatImage(at indexPath: IndexPath) {
        viewModel.image(at: indexPath) { [weak self] image in
            DispatchQueue.main.async {
                if let currentCell = self?.catsTableView.cellForRow(at: indexPath) as? CatTableViewCell {
                    currentCell.catImageView?.image = image
                    currentCell.setNeedsLayout()
                }
            }
        }
    }
    
    func showErrorPrompt() {
        // Present an error to the user
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
        cell.viewModel = item
        cell.catImageView?.image = nil // Reset image to avoid flickering
        cell.delegate = self

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
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "LoadCatDetails", sender: viewModel.catModels[indexPath.row].model)
    }
}

extension CatsViewController: CatTableViewCellDelegate {
    func toggleFavButton(favID: String?, catBreed: CatBreed, type: FavOpType) {
        viewModel.toggleFavourite(favID: favID, catBreed: catBreed, type: type)
    }
}

