//
//  FeedViewController.swift
//
//
//  Created by Denis Yaremenko on 22.10.2024.
//

import UIKit
import EssentialFeed

final public class FeedViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var loader: FeedLoader?
    private var tableModel = [FeedImage]()
    
    
    // MARK: - Init
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    // MARK: - Methods
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
            
            // self?.tableModel = (try? result.get()) ?? []
            
            //            switch result {
            //            case let .success(feed):
            //                self?.tableModel = feed
            //                self?.tableView.reloadData()
            //            case .failure: break
            //            }
            //            self?.refreshControl?.endRefreshing()
            
            if let feed = try? result.get() {
                self?.tableModel = feed
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - UITableViewDataSource

extension FeedViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (cellModel.location == nil)
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.text = cellModel.description
        return cell
    }
}
