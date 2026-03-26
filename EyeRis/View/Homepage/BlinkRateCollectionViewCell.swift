import UIKit

class BlinkRateCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var navigatorButton: UIButton!
    @IBOutlet weak var blinkRateSliderView: BlinkRateView!
    @IBOutlet weak var MainView: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var comment: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        [MainView, commentView].forEach {
            $0?.applyCornerRadius()
        }
    }

    var onTapNavigation: (() -> Void)?
    
    @IBAction func navButtonTapped(_ sender: Any) {
        onTapNavigation?()
    }
    
    
    func configure(rate: Int) {
        blinkRateSliderView.value = CGFloat(rate)
        comment.text = getTrimmedBlinkRateComment(rate: rate)
    }
}
