import UIKit

class AZGradientView: UIView {

    var backgroundImage = UIImageView()
    let blurEffect = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let overlayView = UIView()
    let animator: AZGradientAnimator

    init(
        editMode: Bool
    ) {
        let generator = AZGradientGenerator.basic
        generator.generate()
        self.animator = AZGradientAnimator(
            generator: generator,
            editMode: editMode
        )

        super.init(frame: .zero)
        self.setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        self.addSubview(self.backgroundImage)
        self.addSubview(self.blurEffect)
        self.addSubview(self.overlayView)

        self.overlayView.backgroundColor = .black.withAlphaComponent(0.3)

        self.animator.updateCallback = { image in
            self.backgroundImage.image = image
        }
        self.animator.applyFirstFrame()
    }

    func reset(editMode: Bool) {
        let generator = AZGradientGenerator.basic
        self.animator.generator = generator
        self.animator.reset()
        self.animator.applyFirstFrame()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.backgroundImage.frame = self.bounds
        self.blurEffect.frame = self.bounds
        self.overlayView.frame = self.bounds
    }

    func animate() {
        OperationQueue.main.addOperation {
            self.animator.startAnimation()
        }
    }
}

public extension UIColor {
    convenience init(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if cString.count != 6 {
            self.init(white: 0, alpha: 1.0)
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        if #available(iOS 10.0, *) {
            self.init(displayP3Red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                      alpha: CGFloat(1.0))
        } else {
            self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
        }
    }
}
