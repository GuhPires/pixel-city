//
//  PopVC.swift
//  PixelCity
//
//  Created by Gustavo Mac Mini on 21/05/20.
//  Copyright © 2020 DEVX. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var popImageView: UIImageView!
    
    // MARK: - Global variables/constants
    var passedImg: UIImage!
    
    // MARK: - Init methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popImageView.image = passedImg
        
        addDoubleTap()
    }
    
    // MARK: - Custom methods
    func initData(forImage image: UIImage) {
        self.passedImg = image
    }
    
    func addDoubleTap() {
        let dbTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_:)))
        dbTap.numberOfTapsRequired = 2
        dbTap.delegate = self
        view.addGestureRecognizer(dbTap)
    }
    
    @objc func doubleTapped(_ gesture: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
