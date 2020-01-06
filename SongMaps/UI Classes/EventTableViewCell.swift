//
//  EventTableViewCell.swift
//  SongMaps
//
//  Created by Polecat on 12/16/19.
//  Copyright © 2019 Polecat. All rights reserved.
//

import UIKit
import Kingfisher

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var venuNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var eventImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(event: Event) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        nameLabel.text = event.name
        dateLabel.text = dateFormatter.string(from: event.date!)
        venuNameLabel.text = event.venue
        let distance = Int(event.distance)
        if distance > 1 {
            distanceLabel.text = String(distance) + " miles away"
        } else if distance == 1 {
            distanceLabel.text = String(distance) + " mile away"
        } else {
            distanceLabel.text = "Less than a mile away"
        }
        
        let url = URL(string: event.image!)
        let processor = DownsamplingImageProcessor(size: CGSize(width: eventImage.bounds.width, height: eventImage.bounds.height))
        eventImage.kf.indicatorType = .activity
        eventImage.kf.setImage(with: url, options: [.transition(.fade(0.2)), .processor(processor)])
    }
    @IBAction func ticketmasterButtonTap(_ sender: Any) {
        print("tappy tap")
    }
    
}
