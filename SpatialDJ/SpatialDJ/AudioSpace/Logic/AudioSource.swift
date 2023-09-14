import AVFoundation

class AudioSource {
    var deck: Int
    var player: AVAudioPlayerNode?
    var point: CGPoint
    var range: CGFloat
    var addAnimation: Bool

    var onRemoveState: Bool {
        didSet {
            self.updateVolume()
        }
    }

    var yaw: CGFloat = 0 {
        didSet {
            self.updateAudioResult()
        }
    }

    init(player: AVAudioPlayerNode, deck: Int) {
        self.deck = deck
        self.player = player
        self.point = CGPoint(x: 0, y: 0)
        self.range = 20
        self.addAnimation = true
        self.onRemoveState = false

        self.updateAudioResult()
        self.updateVolume()
    }

    func convert(fullSize: CGSize) -> CGPoint {
        return CGPoint(x: fullSize.width * point.x, y: fullSize.height * point.y)
    }

    func applyFrom(viewPoint: CGPoint, insideSize: CGSize) {
        let x = viewPoint.x / insideSize.width
        let y = viewPoint.y / insideSize.height

        if x < 0 || y < 0 || x > 1 || y > 1 {
            self.onRemoveState = true
        } else {
            self.point = CGPoint(x: x, y: y)
            self.onRemoveState = false
        }

        self.updateAudioResult()
        self.updateVolume()
    }

    func updateVolume() {
        self.player?.volume = min(self.player?.volume ?? 0, self.onRemoveState ? 0 : Float(self.volume))
    }

    func updateAudioResult() {
        self.player?.pan = Float(self.audioResult(v1: self.userVector, v2: self.getVectorOnCircle))
    }

    var getVectorOnCircle: Vector2 {
        return Vector2(
            (self.point.x - 0.5) * 2,
            (self.point.y - 0.5) * 2
        )
    }

    var distance: CGFloat {
        let vector = self.getVectorOnCircle
        return sqrt(vector.x * vector.x + vector.y * vector.y)
    }

    var volume: CGFloat {
        let distance = self.distance
        var volumeValue = max((1 - (max(distance, 0.2) - 0.2)), 0)
        volumeValue = max(volumeValue, 0.05)
        return volumeValue
    }

    var timer: Timer?

    func stopAudio() {
        self.player?.stop()
        self.timer?.invalidate()
    }


//    private func averagePowerFromAllChannels() -> CGFloat {
//        guard let player = self.player else {
//            return 0
//        }
//
//        var power: CGFloat = 0.0
//        (0..<player.numberOfChannels).forEach { (index) in
//            power = power + CGFloat(player.averagePower(forChannel: index))
//        }
//        return power / CGFloat(player.numberOfChannels)
//    }

    var userVector: Vector2 {
        var vector = Vector2(1, 0)
        vector = vector.rotated(by: -self.yaw)
        return vector
    }

    func audioResult(v1: Vector2, v2: Vector2) -> CGFloat {
        let angle = v1.angelBetweenCurrentAnd(vector: v2)
        var deg = angle * CGFloat(180.0 / Double.pi)
        deg = abs(deg)

        let result: CGFloat
        if deg > 90 {
            let value = (180 - deg) / 90
            result = -1 + value
        } else {
            let value = deg / 90
            result = 1 - value
        }

        return self.normalizeAudioResultByVolume(result: result)
    }

    private func normalizeAudioResultByVolume(result: CGFloat) -> CGFloat {
        let volume = self.volume
        return result - result * pow(volume, 3)
    }
}

