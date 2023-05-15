//
//  ResultsTableViewCell.swift
//  Zevo360
//
//  Created by $umit on 15/05/23.
//

import UIKit
import Kingfisher
class ResultsTableViewCell: UITableViewCell {


    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    
    var infoData: NewsModel?{
        didSet{
            guard let infoData = infoData else { return }
            titleLbl.text = infoData.title
            subTitleLbl.text = infoData.description
            img.kf.setImage(with: URL(string: infoData.urlToImage), placeholder: UIImage(named: "image-placeholder"))
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

