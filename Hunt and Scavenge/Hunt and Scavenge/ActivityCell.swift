//
//  TaskCell.swift
//  Hunt and Scavenge
//
//  Created by Abraham on 3/2/23.
//

import UIKit

class ActivityCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var completedImageView: UIImageView!
    
    func configure(with task: Activity) {
        titleLabel.text = task.title
        titleLabel.textColor = task.isComplete ? .secondaryLabel : .label
        completedImageView.image = UIImage(systemName: task.isComplete ? "circle.dashed.inset.filled" : "circle")?.withRenderingMode(.alwaysTemplate)
        completedImageView.tintColor = task.isComplete ? .systemBlue : .tertiaryLabel
    }

}
