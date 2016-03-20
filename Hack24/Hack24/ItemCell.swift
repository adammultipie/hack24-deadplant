import UIKit

class ItemCell: UITableViewCell {
  @IBOutlet weak var valueTextView: UITextView!
  
  var item: Item? {
    didSet {
      textLabel!.text = item?.name
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
  }
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}
