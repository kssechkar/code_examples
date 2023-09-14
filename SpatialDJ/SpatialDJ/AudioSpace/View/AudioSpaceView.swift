import UIKit
import SnapKit

class AudioSpaceView: UIView, AudioSpaceDelegate {
    var contentView = UIView()

    var space: AudioSpace

    var backgroundView = UIView()
    let gradientView = AZGradientView(editMode: false)
    var userImageView = UIImageView(image: UIImage(named: "icon_user_2"))
    var audioSpaceNodes: [AudioSpaceNodeView] = []
    

    init(space: AudioSpace) {
        self.space = space
        super.init(frame: .zero)
        self.setup()
    }
    
    func addAudioSource(audioSource: AudioSource) {
        let node = AudioSpaceNodeView()
        node.source = audioSource
        self.audioSpaceNodes.append(node)
        self.contentView.addSubview(node)
        node.imageView.image = UIImage(systemName: "\(audioSource.deck).square")

        self.updatePosition(node: node, audioSource: audioSource)

        if audioSource.addAnimation {
            node.playFallAnimation()
        }

        self.lastAddedNode = node

        if self.audioSpaceNodes.count >= 1 {
            self.gradientView.animate()
        }
    }

    func removeAudioSource(audioSource: AudioSource) {
        guard let node = self.audioSpaceNodes.first(where: { $0.source === audioSource }) else {
            return
        }

        self.audioSpaceNodes.removeAll(where: { $0 === node })
        node.removeFromSuperview()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        for node in self.audioSpaceNodes {
            if let source = node.source {
                self.updatePosition(node: node, audioSource: source)
            }
        }
    }

    func updatePosition(node: AudioSpaceNodeView, audioSource: AudioSource) {
        node.center = audioSource.convert(fullSize: self.frame.size)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var timer: Timer?

    func setup() {
        self.addSubview(self.contentView)

        self.contentView.backgroundColor = .lightGray
        self.contentView.layer.cornerRadius = 12
        self.backgroundView.layer.cornerRadius = 12
        self.backgroundView.layer.masksToBounds = true

        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(self.snp.height)
        }

        self.contentView.addSubview(self.backgroundView)
        self.backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.backgroundView.addSubview(self.gradientView)
        self.gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.backgroundView.addSubview(self.userImageView)
        self.userImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalToSuperview()
        }

//        for source in audioSpace.sources {
//            self.addAudioSource(audioSource: source)
//        }
        self.space.delegate = self

        
        self.timer = Timer(timeInterval: 0.9, repeats: true, block: { _ in
            self.gradientView.animate()
        })
        RunLoop.current.add(self.timer!, forMode: .common)
    }

    var selectedNode: AudioSpaceNodeView?
    weak var lastAddedNode: AudioSpaceNodeView?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.selectedNode = nil

        guard let touch = touches.first else {
            return
        }

        let position = touch.location(in: self)

        for node in self.audioSpaceNodes {
            if node.frame.contains(position) {
                self.selectedNode = node
                node.selected = true
                break
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        guard let touch = touches.first,
              let selectedNode = self.selectedNode else {
            return
        }

        let position = touch.location(in: self)
        var itemFrame = CGRect(
            x: position.x - selectedNode.frame.width / 2,
            y: position.y - selectedNode.frame.height / 2,
            width: selectedNode.frame.width,
            height: selectedNode.frame.height
        )

        let percentage = self.bounds.intersectionPercentage(itemFrame)
        if percentage != 0 {
            if itemFrame.origin.x < 0 {
                itemFrame.origin.x = 0
            }

            if itemFrame.origin.y < 0 {
                itemFrame.origin.y = 0
            }

            if itemFrame.maxX > self.frame.width {
                itemFrame.origin.x = self.frame.width - itemFrame.width
            }

            if itemFrame.maxY > self.frame.height {
                itemFrame.origin.y = self.frame.height - itemFrame.height
            }

            selectedNode.center = CGPoint(
                x: itemFrame.midX,
                y: itemFrame.midY
            )
            selectedNode.prepareToRemove = false
        } else {
            touchesCancelled(touches, with: event)
        }

        selectedNode.source?.applyFrom(
            viewPoint: selectedNode.center,
            insideSize: self.bounds.size
        )
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.touchEndActions()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.touchEndActions()
    }

    private func touchEndActions() {
        self.selectedNode?.selected = false
        if self.selectedNode?.prepareToRemove == true, let source = self.selectedNode?.source {
            self.space.removeSource(audioSource: source)
            selectedNode?.removeFromSuperview()
        }
        self.selectedNode = nil
    }
}

public extension CGRect {
    func intersectionPercentage(_ otherRect: CGRect) -> CGFloat {
        if !intersects(otherRect) { return 0 }
        let intersectionRect = intersection(otherRect)
        if intersectionRect == self || intersectionRect == otherRect { return 100 }
        let intersectionArea = intersectionRect.width * intersectionRect.height
        let area = width * height
        return (intersectionArea / area) * 100
    }
}
