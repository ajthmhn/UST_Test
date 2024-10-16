//
//  DeviceListCell.swift
//  UST-Test
//
//  Created by Ajith Mohan on 15/10/24.
//

import UIKit

class DeviceListCell: UITableViewCell {

    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblDetails: UILabel!
    @IBOutlet var lblStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
