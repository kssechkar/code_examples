import UIKit

final class AZGradientGenerator: Codable {
    enum CodingKeys: String, CodingKey {
        case colors
        case firstStepPoints
        case nextStepPoints
        case duration
    }

    class Point: CustomStringConvertible {
        var color: UIColor
        var point: CGPoint

        init(color: UIColor, point: CGPoint) {
            self.color = color
            self.point = point
        }

        var description: String {
            return "Point: \(self.point)"
        }
    }

    class GeneratedAnimation {
        var step: Int
        var images: [UIImage]

        init(step: Int, images: [UIImage]) {
            self.step = step
            self.images = images
        }
    }

    var colors: [HexColor]
    let firstStepPoints: [CGPoint]
    let nextStepPoints: [CGPoint]
    var duration: AZAnimationDuration = .fps60

    enum MemorySize {
        case low, medium, high

        static var current: MemorySize {
            if ProcessInfo.processInfo.physicalMemory < 838860800 {
                return .low
            } else if ProcessInfo.processInfo.physicalMemory < 1572864000 {
                return .medium
            } else {
                return .high
            }
        }

        var sizeCoef: CGFloat {
            switch self {
            case .low:
                return 0.1
            case .medium:
                return 0.12
            case .high:
                return 0.14
            }
        }
    }

    private let size: CGSize = {
        let size = CGSize(
            width: UIScreen.main.bounds.size.width,
            height: UIScreen.main.bounds.size.width
        )
        let coef = MemorySize.current.sizeCoef
        return .init(width: size.width * coef, height: size.height * coef)
    }()

    var animations: [Int: GeneratedAnimation] = [:]

    var firstFrame: UIImage? {
        self.generateFirstFrameIfNeeded()
        return _firstFrame
    }
    private var _firstFrame: UIImage?

    private static var basicColors: [HexColor] = [
        .init(hex: "7FA381"),
        .init(hex: "FFF5C5"),
        .init(hex: "336F55"),
        .init(hex: "FBE37D")
    ]

    static var basic: AZGradientGenerator {
        let generator = AZGradientGenerator(
            colors: AZGradientGenerator.basicColors,
            firstStepPoints: [
                .init(x: 0.823, y: 0.086),
                .init(x: 0.362, y: 0.254),
                .init(x: 0.184, y: 0.923),
                .init(x: 0.648, y: 0.759)
            ],
            nextStepPoints: [
                .init(x: 0.59, y: 0.16),
                .init(x: 0.28, y: 0.58),
                .init(x: 0.42, y: 0.83),
                .init(x: 0.74, y: 0.42)
            ]
        )
        
        return generator
    }

    func resetToDefaults() {
        self.regenerateWithNewColors(
            colors: AZGradientGenerator.basicColors,
            duration: .fps60
        )
    }

    func copy() -> AZGradientGenerator {
        let generator = AZGradientGenerator(
            colors: self.colors,
            firstStepPoints: self.firstStepPoints,
            nextStepPoints: self.nextStepPoints
        )

        generator.duration = self.duration
        generator._firstFrame = self._firstFrame

        if self.isGenerationInProcess == false {
            generator.animations = self.animations
        } else {
            generator.generate()
        }

        return generator
    }

    func regenerateWithNewColors(colors: [HexColor], duration: AZAnimationDuration) {
        self.colors = colors
        self.duration = duration

        _firstFrame = nil
        self.generateFirstFrameIfNeeded()

        self.backgroundBlurGeneration()
    }

    init(colors: [HexColor], firstStepPoints: [CGPoint], nextStepPoints: [CGPoint]) {
        self.colors = colors
        self.firstStepPoints = firstStepPoints
        self.nextStepPoints = nextStepPoints
    }

    func generate() {
        self.generateFirstFrameIfNeeded()
        self.backgroundBlurGeneration()
    }

    private var blurGenerated: DispatchQueue?

    private let globalBackgroundSyncronizeDataQueue = DispatchQueue(
        label: "globalBackgroundSyncronizeToken")
    private var _generationToken: String = ""

    private var generationToken: String {
        set {
            self.globalBackgroundSyncronizeDataQueue.sync {
                self._generationToken = newValue
            }
        }

        get {
            self.globalBackgroundSyncronizeDataQueue.sync {
                return self._generationToken
            }
        }
    }

    private var isGenerationInProcess: Bool = false

    func backgroundBlurGeneration() {
        self.generationToken = UUID().uuidString
        let sessionToken = self.generationToken

        self.blurGenerated =
            DispatchQueue(
                label: "com.cache.date",
                qos: .userInteractive,
                attributes: .concurrent)

        self.isGenerationInProcess = true
        let startTime = CFAbsoluteTimeGetCurrent()

        self.blurGenerated?.async {
            for i in 0..<8 {
                self.generate(step: i, token: sessionToken)
            }

            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("Time elapsed: \(timeElapsed) s.")
            OperationQueue.main.addOperation {
                self.isGenerationInProcess = false
            }
        }
    }

    private func generate(step: Int, token: String) {
        var images: [UIImage] = []

        for substep in 0..<self.duration.int {
            if token != self.generationToken {
                return
            }

            if let image = self.generateGradient(
                with: self.size,
                gradPointArray: self.applyTransformerToPoints(step: step, substep: substep)
            ) {
                if token != self.generationToken {
                    return
                }
                
                images.append(image)
            }
        }

        if token != self.generationToken {
            return
        }

        OperationQueue.main.addOperation {
            self.animations[step] = GeneratedAnimation(step: step, images: images)
        }
    }

    private func generateFirstFrameIfNeeded() {
        guard _firstFrame == nil else {
            return
        }

        let image = self.generateGradient(
            with: self.size,
            gradPointArray: self.applyTransformerToPoints(step: 0, substep: 0)
        )
        _firstFrame = image
    }

    private func applyTransformerToPoints(step: Int, substep: Int) -> [Point] {
        var points: [Point] = []

        var firstSet: [CGPoint]
        var secondSet: [CGPoint]

        if step % 2 == 0 {
            firstSet = self.shiftArray(array: self.firstStepPoints, offset: step / 2)
            secondSet = self.shiftArray(array: self.nextStepPoints, offset: step / 2)
        } else {
            firstSet = self.shiftArray(array: self.nextStepPoints, offset: step / 2)
            secondSet = self.shiftArray(array: self.firstStepPoints, offset: step / 2 + 1)
        }

        for index in 0..<self.colors.count {
            let point = self.transformPoint(
                poinsts: (firstSet[index], secondSet[index]),
                substep: substep
            )

            points.append(
                .init(
                    color: self.colors[index].color,
                    point: point
                )
            )
        }

        return points
    }

    private func shiftArray(array: [CGPoint], offset: Int) -> [CGPoint] {
        var newArray = array
        var offset = offset
        while offset > 0 {
            let element = newArray.removeFirst()
            newArray.append(element)
            offset -= 1
        }
        return newArray
    }

    private func transformPoint(poinsts: (first: CGPoint, second: CGPoint), substep: Int) -> CGPoint {
        let delta = CGFloat(substep) / CGFloat(self.duration.int)
        let x = poinsts.first.x + (poinsts.second.x - poinsts.first.x) * delta
        let y = poinsts.first.y + (poinsts.second.y - poinsts.first.y) * delta

        return CGPoint(x: x, y: y)
    }

    private func generateGradient(with size: CGSize, gradPointArray gradPoints: [Point]) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(size, true, 0)

        let c = UIGraphicsGetCurrentContext()

        c?.setFillColor(UIColor.white.cgColor)
        c?.fill(CGRect(origin: CGPoint.zero, size: size))

        c?.setBlendMode(.multiply)

        var gradLocs: [CGFloat] = [0, 0.1, 0.35, 1]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let radius = max(size.width, size.height)

        for point in gradPoints {
            let colors = [
                point.color.cgColor,
                point.color.withAlphaComponent(0.8).cgColor,
                point.color.withAlphaComponent(0.3).cgColor,
                point.color.withAlphaComponent(0).cgColor
            ]

            let grad = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: &gradLocs)
            if let grad = grad {
                let newPoint = point.point.applying(
                    .init(scaleX: size.width, y: size.height)
                )

                c?.drawRadialGradient(grad, startCenter: newPoint, startRadius: 0, endCenter: newPoint, endRadius: radius, options: [])
            }
        }

        let i = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return i
    }
}

enum AZAnimationDuration: String, CaseIterable, Codable {
    case fps60 = "60"
    case fps45 = "45"
    case fps30 = "30"

    var durationInSeconds: TimeInterval {
        switch self {
        case .fps60:
            return 1
        case .fps30:
            return 0.5
        case .fps45:
            return 0.75
        }
    }

    var int: Int {
        switch self {
        case .fps60:
            return 60
        case .fps30:
            return 30
        case .fps45:
            return 45
        }
    }

    var title: String {
        switch self {
        case .fps60:
            return "60f (1 sec)"
        case .fps30:
            return "30f"
        case .fps45:
            return "45f"
        }
    }
}
