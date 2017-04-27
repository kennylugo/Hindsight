//
//  MainCollectionViewCell.swift
//  Vlogr
//
//  Created by Kenny Batista on 1/19/17.
//  Copyright © 2017 kennybatista. All rights reserved.
//

import UIKit


class MainCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
    }
    
    
}
