import UIKit

class AudioPlayerView: UIControl {
    let song: Song
    let imageView = UIImageView()
    let label = UILabel()
    let deck = 0

    init(deck: Int, song: Song) {
        self.song = song
        super.init(frame: .zero)
        self.setup(deck: deck)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(deck: Int) {
        self.addSubview(self.imageView)
        self.imageView.isUserInteractionEnabled = false
        self.imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.size.equalTo(40)
        }

        self.imageView.tintColor = .white
        self.imageView.image = UIImage(systemName: "\(deck).square")

        self.addSubview(self.label)
        self.label.textColor = .white
        self.label.isUserInteractionEnabled = false
        self.label.snp.makeConstraints { make in
            make.top.equalTo(self.imageView.snp.bottom).inset(-8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        self.label.text = self.song.name
    }
}
