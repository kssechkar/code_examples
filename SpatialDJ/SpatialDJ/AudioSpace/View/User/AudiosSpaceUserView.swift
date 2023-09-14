import UIKit

class AudiosSpaceUserView: UIView {
    var contentView = UIView()
    var imageView = UIImageView()

    func setup() {
        self.snp.makeConstraints { make in
            make.size.equalTo(30)
        }

        self.addSubview(self.contentView)
        self.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
