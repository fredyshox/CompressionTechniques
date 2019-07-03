import Foundation
import DifferentialCoding
import TGAImage

func meanSquaredError(original: TGAImage, reconstruction: TGAImage) -> (total: Double, red: Double, green: Double, blue: Double, s2n: Double) {
    guard original.size == reconstruction.size else {
        fatalError("Argument Error")
    }

    let n = Double(original.height * original.width)
    var redMSE = 0.0
    var greenMSE = 0.0
    var blueMSE = 0.0
    var redSNR = 0.0
    var blueSNR = 0.0
    var greenSNR = 0.0
    for x in 0..<original.width {
        for y in 0..<original.height {
            let orgColor = try! original.get(x, y)
            let recColor = try! reconstruction.get(x, y)
            redMSE += pow(Double(orgColor.red) - Double(recColor.red), 2.0)
            greenMSE += pow(Double(orgColor.green) - Double(recColor.green), 2.0)
            blueMSE += pow(Double(orgColor.blue) - Double(recColor.blue), 2.0)
            redSNR += pow(Double(orgColor.red), 2.0)
            greenSNR += pow(Double(orgColor.green), 2.0)
            blueSNR += pow(Double(orgColor.blue), 2.0)
        }
    }

    let totalMSE = (redMSE + greenMSE + blueMSE) / (3.0 * n)
    let totalSNR = (redSNR + greenSNR + blueSNR) / (3.0 * n * totalMSE)
    return (totalMSE, redMSE / n, greenMSE / n, blueMSE / n, totalSNR)
}

if CommandLine.arguments.count < 2 {
    fputs("Usage: program <bit_count>\n", stderr)
    exit(1)
}

do {
    let orgPath = CommandLine.arguments[1]
    let recPath = CommandLine.arguments[2]
    let image = try TGAImage(contentsOf: orgPath)
    var imgCopy = image
    let diffCoder = DifferentialCoder(quantizerBits: 1)
    diffCoder.decode(image: &imgCopy)
    print(meanSquaredError(original: imgCopy, reconstruction: image))
    let destUrl = URL(fileURLWithPath: recPath)
    try imgCopy.data().write(to: destUrl)
} catch let error {
    fputs("Error: \(error.localizedDescription)\n", stderr)
    exit(2)
}
