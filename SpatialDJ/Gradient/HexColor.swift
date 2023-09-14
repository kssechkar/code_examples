import UIKit

struct HexColor: Equatable, Codable {
    enum CodingKeys: String, CodingKey {
        case hex
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.hex = try values.decode(String.self, forKey: .hex)
        self.color = UIColor(hex: self.hex)
    }

    var color: UIColor
    var hex: String

    init(hex: String) {
        self.color = UIColor(hex: hex)
        self.hex = hex
    }

    static func == (lhs: HexColor, rhs: HexColor) -> Bool {
        return lhs.hex == rhs.hex
    }
}

