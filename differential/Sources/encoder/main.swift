import Foundation
import DifferentialCoding
import TGAImage

if CommandLine.arguments.count < 2 {
    fputs("Usage: program <bit_count>\n", stderr)
    exit(1)
}

do {
    let qBits = UInt8(CommandLine.arguments[1])!
    let srcPath = CommandLine.arguments[2]
    let destPath = CommandLine.arguments[3]

    var image = try TGAImage(contentsOf: srcPath)
    let diffCoder = DifferentialCoder(quantizerBits: qBits)
    diffCoder.encode(image: &image)
    let destUrl = URL(fileURLWithPath: destPath)
    try image.data().write(to: destUrl)
} catch let error {
    fputs("Error: \(error.localizedDescription)\n", stderr)
    exit(2)
}
