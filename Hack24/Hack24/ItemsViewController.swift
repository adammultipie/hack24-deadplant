import UIKit
import CoreLocation

struct ItemsViewControllerConstant {
    static let storedItemsKey = "storedItems"
}

class ItemsViewController: UIViewController {
    @IBOutlet weak var itemsTableView: UITableView!
    
    
    var beaconRegions:[CLBeaconRegion]?;
    var interactor = BeaconInteractor();
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        interactor.start();
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        interactor.stop();
    }
    
    @IBAction func cancelItem(segue: UIStoryboardSegue) {
        // Do nothing
    }
}

// MARK: UITableViewDataSource
extension ItemsViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Item", forIndexPath: indexPath) as! ItemCell
//        let item = items[indexPath.row]
//        cell.item = item
        return cell
    }
}

