import Foundation
import HSCryptoKit

class TrieNode {

    enum NodeType {
        case NULL
        case BRANCH
        case EXTENSION
        case LEAF
    }

    private static let alphabet: [String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]

    let nodeType: NodeType
    let hash: Data
    var elements: [Data]

    private let encodedPath: String

    init(rlp: RLPElement) {
        elements = [Data]()
        for element in rlp.listValue {
            elements.append(element.dataValue)
        }

        hash = CryptoKit.sha3(rlp.dataValue)

        if rlp.listValue.count == 17 {
            nodeType = NodeType.BRANCH
            encodedPath = ""
        } else {
            let first = elements[0]
            let nibble: UInt8 = first[0] >> 4

            switch nibble {
            case 0:
                nodeType = NodeType.EXTENSION;
                encodedPath = first.subdata(in: 1..<first.count).toHexString()

            case 1:
                nodeType = NodeType.EXTENSION
                encodedPath = TrieNode.secondCharacter(ofByteInHex: first[0]) + first.subdata(in: 1..<first.count).toHexString()

            case 2:
                nodeType = NodeType.LEAF;
                encodedPath = first.subdata(in: 1..<first.count).toHexString()

            case 3:
                nodeType = NodeType.LEAF
                encodedPath = TrieNode.secondCharacter(ofByteInHex: first[0]) + first.subdata(in: 1..<first.count).toHexString()

            default:
                nodeType = NodeType.NULL
                encodedPath = ""

            }
        }
    }

    private static func secondCharacter(ofByteInHex byte: UInt8) -> String {
        let byteString = String(byte, radix: 16)

        let startIndex = byteString.index(byteString.startIndex, offsetBy: 1)
        return String(byteString[startIndex...])
    }

    func getPath(element: Data?) -> String? {
        if (element == nil && nodeType == NodeType.LEAF) {
            return encodedPath;
        }

        for (i, elementInNode) in elements.enumerated() {
            if elementInNode == element {
                if (nodeType == NodeType.BRANCH) {
                    return TrieNode.alphabet[i]
                } else if (nodeType == NodeType.EXTENSION) {
                    return encodedPath;
                }
            }
        }

        return nil;
    }

    func toString() -> String {
        return "(\(elements.map{ $0.toHexString() }.joined(separator: "|")))"
    }
}
