import BigInt

struct QuoteMapper {

    static func quote(map: [String: Any]) throws -> Quote {
        guard let fromTokenMap = map["fromToken"] as? [String: Any],
              let toTokenMap = map["toToken"] as? [String: Any] else {
            throw ResponseError.invalidJson
        }

        let fromToken = try TokenMapper.token(map: fromTokenMap)
        let toToken = try TokenMapper.token(map: toTokenMap)

        guard let toAmountString = map["toTokenAmount"] as? String,
              let toAmount = BigUInt(toAmountString, radix: 10),
              let fromAmountString = map["fromTokenAmount"] as? String,
              let fromAmount = BigUInt(fromAmountString, radix: 10),
              let estimateGas = map["estimatedGas"] as? Int else {
            throw ResponseError.invalidJson
        }


        return Quote(
                fromToken: fromToken,
                toToken: toToken,
                fromTokenAmount: fromAmount,
                toTokenAmount: toAmount,
                route: [],                      // todo: parse "protocols"
                estimateGas: estimateGas
        )
    }

}

extension QuoteMapper {

    public enum ResponseError: Error {
        case invalidJson
    }

}
