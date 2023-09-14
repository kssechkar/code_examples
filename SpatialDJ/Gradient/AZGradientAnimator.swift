import UIKit

class AZGradientAnimator {
    typealias UpdateCallback = (UIImage?) -> Void

    var updateCallback: UpdateCallback?

    var generator: AZGradientGenerator

    private var displayLink: CADisplayLink?
    private var startTime = 0.0

    private var currentPhase: Int = 0

    private var inProgress: Bool = false
    private var currentAnimationStep: Int = 0

    private let editMode: Bool

    init(
        generator: AZGradientGenerator,
        editMode: Bool
    ) {
        self.generator = generator
        self.editMode = editMode
    }

    var imagesForPhase: [UIImage] = []

    func applyFirstFrame() {
        self.updateCallback?(self.generator.firstFrame)
    }

    func reset() {
        self.displayLink?.invalidate()
        self.currentPhase = 0
    }

    private var animationInProgress = false

    func startAnimation() {
        if self.currentAnimationStep == 0, self.animationInProgress {
            return
        }
        
        let numberOfFrames = self.generator.duration.int
        let frameToStep = self.imagesForPhase.count - numberOfFrames / 2

        if self.currentAnimationStep != 0,
           self.currentAnimationStep < frameToStep {
            return
        }

        var imagesLeft: [UIImage] = []
        if self.currentAnimationStep >= frameToStep, self.currentAnimationStep < self.imagesForPhase.count {
            imagesLeft = Array(self.imagesForPhase[self.currentAnimationStep..<self.imagesForPhase.count])
        }

        self.imagesForPhase = self.generator.animations[self.currentPhase]?.images ?? []
        let isEmpty = self.imagesForPhase.isEmpty
        self.imagesForPhase.insert(contentsOf: imagesLeft, at: 0)

        guard isEmpty == false else {
            return
        }

        self.displayLink?.invalidate()
        self.startTime = CACurrentMediaTime()

        self.animationInProgress = true
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .current, forMode: .common)

        self.displayLink = displayLink

        self.currentPhase += 1
        if self.currentPhase > 7 {
            self.currentPhase = 0
        }
    }

    @objc private func update() {
        let elapsed = CACurrentMediaTime() - self.startTime
        let fullDuration = self.generator.duration.durationInSeconds
        if elapsed >= fullDuration {
            self.finish()
            return
        }

        let progress = (elapsed / fullDuration)
        let timingProgress = Float(progress)//self.curveExecuter.transform(progress: Float(progress))
        var animationStep = max(Int(timingProgress * Float(self.imagesForPhase.count)), 0)
        animationStep = min(animationStep, self.imagesForPhase.count - 1)

        if timingProgress >= 1 {
            self.finish()
            return
        }

        if self.currentAnimationStep == animationStep || self.imagesForPhase.count == 0 {
            return
        }

        self.currentAnimationStep = animationStep
        self.updateCallback?(self.imagesForPhase[self.currentAnimationStep])
    }

    private func finish() {
        self.currentAnimationStep = 0
        self.animationInProgress = false
        let lastFrame = self.imagesForPhase.last

        self.imagesForPhase = []
        self.updateCallback?(lastFrame)
        self.displayLink?.invalidate()
    }

    private func filterArray<T>(values: [T], expectedSize: Int, startSize: Int) -> [T] {
        var result: [T] = []
        let leftSize = expectedSize - startSize
        let everyIndex = Double(values.count) / Double(leftSize)
        var currentIndex: Double = 0
        while true {
            let index = Int(round(currentIndex))
            if index >= values.count {
                break
            }
            result.append(values[index])
            currentIndex += everyIndex
        }
        return result
    }
}
