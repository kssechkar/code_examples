import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var Artist: UILabel!
    @IBOutlet weak var BPM: UILabel!
    @IBOutlet weak var Pitch: UILabel!
    @IBOutlet weak var Cover: UIImageView!
    @IBOutlet weak var Load1: UIButton!
    @IBOutlet weak var Load2: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
