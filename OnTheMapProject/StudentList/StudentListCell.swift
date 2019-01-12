//
//  StudentListCell.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 12/18/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit

class StudentListCell: UITableViewCell {
    let mapPin = UIImageView()
    let nameLabel = UILabel()
    let urlLabel = UILabel()
    
    let identifier: String = "StudentListCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: "StudentListCell")
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure() {
        self.addSubview(mapPin)
        self.addSubview(nameLabel)
        self.addSubview(urlLabel)
        mapPin.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        urlLabel.translatesAutoresizingMaskIntoConstraints = false
        mapPin.image = UIImage(named: "icon_pin")
        mapPin.contentMode = .scaleAspectFit
        mapPin.layoutMargins.top = 8
        mapPin.layoutMargins.bottom = 8
        urlLabel.textColor = .gray
        layoutCell()
    }
    
    func layoutCell() {
        NSLayoutConstraint.activate([
            mapPin.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            mapPin.widthAnchor.constraint(equalToConstant: 80),
            mapPin.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            mapPin.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
            ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: mapPin.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: mapPin.trailingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: self.frame.height / 2)
            ])
        
        NSLayoutConstraint.activate([
            urlLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            urlLabel.bottomAnchor.constraint(equalTo: mapPin.bottomAnchor),
            urlLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            urlLabel.heightAnchor.constraint(equalTo: nameLabel.heightAnchor)
            ])
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 70)
            ])
    }
}
