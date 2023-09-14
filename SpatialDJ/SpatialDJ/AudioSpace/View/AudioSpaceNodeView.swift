import UIKit

class AudioSpaceNodeView: UIView {
    var frameView = UIView()
    var contentView = UIView()
    var imageView = UIImageView()
    var backgroundLight = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var source: AudioSource? {
        didSet {
            self.imageView.image = UIImage(systemName: "1.square")
        }
    }

    var volume: CGFloat = 0 {
        didSet {

        }
    }

    var selected: Bool = false {
        didSet {
            self.backgroundLight.isHidden = !self.selected
            if selected {
                self.contentView.transform = .init(scaleX: 1.12, y: 1.12)
            } else {
                self.contentView.transform = .identity
            }
        }
    }

    var prepareToRemove: Bool = false {
        didSet {
            if self.prepareToRemove {
                self.alpha = 0.5
            } else {
                self.alpha = 1.0
            }
        }
    }

    func setup() {
        self.selected = false
        self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)

        self.addSubview(self.backgroundLight)
        self.addSubview(self.frameView)
        self.addSubview(self.contentView)

        self.contentView.backgroundColor = .white
        self.contentView.layer.cornerRadius = 25
        self.contentView.layer.masksToBounds = true

        self.backgroundLight.image = UIImage(named: "selected_light")
        self.backgroundLight.alpha = 0.25
        self.backgroundLight.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(145)
        }

        self.contentView.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.center.equalToSuperview()
        }

        self.contentView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(36)
        }
    }

    func playFallAnimation() {
        self.transform = CGAffineTransform(scaleX: 10, y: 10)
        self.alpha = 0

        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut]) {
            self.alpha = 1
            self.transform = .identity
        } completion: { _ in }
    }
}
