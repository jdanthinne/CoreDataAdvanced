//
//  ViewController.swift
//  Example
//
//  Created by Jérôme Danthinne on 5 août 2019.
//  Copyright © 2019 Grincheux. All rights reserved.
//

import CoreDataAdvanced
import UIKit

// MARK: - ViewController

/// The ViewController
class ViewController: UIViewController {
    // MARK: Properties

    /// The Label
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "🚀\nCoreDataAdvanced\nExample"
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()

    // MARK: View-Lifecycle

    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    /// LoadView
    override func loadView() {
        view = label
    }
}
