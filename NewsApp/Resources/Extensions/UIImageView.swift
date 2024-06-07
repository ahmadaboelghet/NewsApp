//
//  UIImageView.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 07/06/2024.
//

import UIKit

extension UIImageView {
    func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}

