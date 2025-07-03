import UIKit

enum IconPaths {
    
    // SPY
    static func spyHatPath() -> UIBezierPath {
        let spyHatPath = UIBezierPath()
        spyHatPath.move(to: CGPoint(x: 142.31, y: 263.18))
        spyHatPath.addCurve(to: CGPoint(x: 34.14, y: 259.81), controlPoint1: CGPoint(x: 142.31, y: 263.18), controlPoint2: CGPoint(x: 42.18, y: 262.98))
        spyHatPath.addCurve(to: CGPoint(x: 106.08, y: 231.17), controlPoint1: CGPoint(x: 29.89, y: 258.13), controlPoint2: CGPoint(x: 103.76, y: 233.23))
        spyHatPath.addCurve(to: CGPoint(x: 129.28, y: 162.26), controlPoint1: CGPoint(x: 108.56, y: 228.96), controlPoint2: CGPoint(x: 129.28, y: 162.26))
        spyHatPath.addCurve(to: CGPoint(x: 231.83, y: 161.75), controlPoint1: CGPoint(x: 129.28, y: 162.26), controlPoint2: CGPoint(x: 171.24, y: 192.16))
        spyHatPath.addCurve(to: CGPoint(x: 251.38, y: 233.29), controlPoint1: CGPoint(x: 231.83, y: 161.75), controlPoint2: CGPoint(x: 249.36, y: 231.1))
        spyHatPath.addCurve(to: CGPoint(x: 323.51, y: 261.37), controlPoint1: CGPoint(x: 253.5, y: 235.59), controlPoint2: CGPoint(x: 331.59, y: 260.49))
        spyHatPath.addCurve(to: CGPoint(x: 142.31, y: 263.18), controlPoint1: CGPoint(x: 304.9, y: 263.38), controlPoint2: CGPoint(x: 142.31, y: 263.18))
        spyHatPath.close()
        return spyHatPath
    }
    
    static func spyRightEyePath() -> UIBezierPath {
        let spy2rightEyePath = UIBezierPath()
        spy2rightEyePath.move(to: CGPoint(x: 200.64, y: 274.75))
        spy2rightEyePath.addCurve(to: CGPoint(x: 195.36, y: 273.84), controlPoint1: CGPoint(x: 200.64, y: 274.75), controlPoint2: CGPoint(x: 195.55, y: 275.61))
        spy2rightEyePath.addCurve(to: CGPoint(x: 196.74, y: 272.28), controlPoint1: CGPoint(x: 195.18, y: 272.07), controlPoint2: CGPoint(x: 196.74, y: 272.28))
        spy2rightEyePath.addLine(to: CGPoint(x: 266.74, y: 264.23))
        spy2rightEyePath.addCurve(to: CGPoint(x: 269.65, y: 268.04), controlPoint1: CGPoint(x: 266.74, y: 264.23), controlPoint2: CGPoint(x: 271.06, y: 263.73))
        spy2rightEyePath.addCurve(to: CGPoint(x: 251, y: 288.79), controlPoint1: CGPoint(x: 268.24, y: 272.35), controlPoint2: CGPoint(x: 263.91, y: 283.36))
        spy2rightEyePath.addCurve(to: CGPoint(x: 220.92, y: 290.78), controlPoint1: CGPoint(x: 238.08, y: 294.21), controlPoint2: CGPoint(x: 229.43, y: 293.24))
        spy2rightEyePath.addCurve(to: CGPoint(x: 200.64, y: 274.75), controlPoint1: CGPoint(x: 212.42, y: 288.32), controlPoint2: CGPoint(x: 205.23, y: 282.01))
        spy2rightEyePath.close()
        spy2rightEyePath.move(to: CGPoint(x: 205.84, y: 274.41))
        spy2rightEyePath.addCurve(to: CGPoint(x: 217.45, y: 284.06), controlPoint1: CGPoint(x: 205.84, y: 274.41), controlPoint2: CGPoint(x: 211.41, y: 281.68))
        spy2rightEyePath.addCurve(to: CGPoint(x: 248.8, y: 283.34), controlPoint1: CGPoint(x: 227.08, y: 287.86), controlPoint2: CGPoint(x: 241.52, y: 288.11))
        spy2rightEyePath.addCurve(to: CGPoint(x: 238.83, y: 270.83), controlPoint1: CGPoint(x: 248.94, y: 283.25), controlPoint2: CGPoint(x: 238.96, y: 281.82))
        spy2rightEyePath.addCurve(to: CGPoint(x: 205.84, y: 274.41), controlPoint1: CGPoint(x: 238.83, y: 270.72), controlPoint2: CGPoint(x: 205.84, y: 274.41))
        spy2rightEyePath.close()
        return spy2rightEyePath
    }
    
    static func spyLeftEyePath() -> UIBezierPath {
        let spyLeftEyePath = UIBezierPath()
        spyLeftEyePath.move(to: CGPoint(x: 152.99, y: 276.75))
        spyLeftEyePath.addCurve(to: CGPoint(x: 158.16, y: 275.85), controlPoint1: CGPoint(x: 152.99, y: 276.75), controlPoint2: CGPoint(x: 157.97, y: 277.59))
        spyLeftEyePath.addCurve(to: CGPoint(x: 156.81, y: 274.32), controlPoint1: CGPoint(x: 158.34, y: 274.11), controlPoint2: CGPoint(x: 156.81, y: 274.32))
        spyLeftEyePath.addLine(to: CGPoint(x: 88.2, y: 266.44))
        spyLeftEyePath.addCurve(to: CGPoint(x: 85.34, y: 270.17), controlPoint1: CGPoint(x: 88.2, y: 266.44), controlPoint2: CGPoint(x: 83.96, y: 265.95))
        spyLeftEyePath.addCurve(to: CGPoint(x: 103.63, y: 290.5), controlPoint1: CGPoint(x: 86.73, y: 274.39), controlPoint2: CGPoint(x: 90.96, y: 285.18))
        spyLeftEyePath.addCurve(to: CGPoint(x: 133.1, y: 292.45), controlPoint1: CGPoint(x: 116.29, y: 295.81), controlPoint2: CGPoint(x: 124.76, y: 294.86))
        spyLeftEyePath.addCurve(to: CGPoint(x: 152.99, y: 276.75), controlPoint1: CGPoint(x: 141.44, y: 290.04), controlPoint2: CGPoint(x: 148.49, y: 283.86))
        spyLeftEyePath.close()
        spyLeftEyePath.move(to: CGPoint(x: 120.55, y: 273.88))
        spyLeftEyePath.addCurve(to: CGPoint(x: 130.7, y: 287.86), controlPoint1: CGPoint(x: 120.55, y: 273.88), controlPoint2: CGPoint(x: 118.31, y: 281.4))
        spyLeftEyePath.addCurve(to: CGPoint(x: 103.11, y: 284.45), controlPoint1: CGPoint(x: 130.7, y: 287.86), controlPoint2: CGPoint(x: 116.26, y: 292.4))
        spyLeftEyePath.addCurve(to: CGPoint(x: 91.21, y: 270.85), controlPoint1: CGPoint(x: 94.22, y: 279.09), controlPoint2: CGPoint(x: 91.21, y: 270.85))
        spyLeftEyePath.addLine(to: CGPoint(x: 120.55, y: 273.88))
        spyLeftEyePath.close()
        return spyLeftEyePath
    }
    
    // CIVILIAN
    static func civilianHatPath() -> UIBezierPath {
        let civilHatPath = UIBezierPath()
        civilHatPath.move(to: CGPoint(x: 173.58, y: 261.33))
        civilHatPath.addCurve(to: CGPoint(x: 57.88, y: 239.4), controlPoint1: CGPoint(x: 113.28, y: 261.51), controlPoint2: CGPoint(x: 67.22, y: 246.34))
        civilHatPath.addCurve(to: CGPoint(x: 107.42, y: 229.87), controlPoint1: CGPoint(x: 54.46, y: 236.86), controlPoint2: CGPoint(x: 107.42, y: 229.87))
        civilHatPath.addCurve(to: CGPoint(x: 132.6, y: 181.36), controlPoint1: CGPoint(x: 107.42, y: 229.87), controlPoint2: CGPoint(x: 113.26, y: 199.58))
        civilHatPath.addCurve(to: CGPoint(x: 219.69, y: 181.55), controlPoint1: CGPoint(x: 165.12, y: 150.72), controlPoint2: CGPoint(x: 198.58, y: 159.03))
        civilHatPath.addCurve(to: CGPoint(x: 244.72, y: 230.57), controlPoint1: CGPoint(x: 242.44, y: 205.84), controlPoint2: CGPoint(x: 242.59, y: 228.65))
        civilHatPath.addCurve(to: CGPoint(x: 293.91, y: 240.68), controlPoint1: CGPoint(x: 246.88, y: 232.51), controlPoint2: CGPoint(x: 300.66, y: 237.19))
        civilHatPath.addCurve(to: CGPoint(x: 173.58, y: 261.33), controlPoint1: CGPoint(x: 278.63, y: 248.57), controlPoint2: CGPoint(x: 215.7, y: 261.2))
        civilHatPath.close()
        return civilHatPath
    }
    
    static func civilianRightEyePath() -> UIBezierPath {
        let civil2righteyePath = UIBezierPath()
        civil2righteyePath.move(to: CGPoint(x: 204.25, y: 276.6))
        civil2righteyePath.addCurve(to: CGPoint(x: 205.54, y: 271.32), controlPoint1: CGPoint(x: 204.28, y: 274.92), controlPoint2: CGPoint(x: 204.73, y: 272.69))
        civil2righteyePath.addCurve(to: CGPoint(x: 207.92, y: 268.45), controlPoint1: CGPoint(x: 206.34, y: 269.99), controlPoint2: CGPoint(x: 207.01, y: 269.32))
        civil2righteyePath.addCurve(to: CGPoint(x: 241.81, y: 266.04), controlPoint1: CGPoint(x: 217.55, y: 259.25), controlPoint2: CGPoint(x: 235.31, y: 261.93))
        civil2righteyePath.addCurve(to: CGPoint(x: 247.68, y: 271.86), controlPoint1: CGPoint(x: 243.86, y: 267.33), controlPoint2: CGPoint(x: 246.17, y: 269.04))
        civil2righteyePath.addCurve(to: CGPoint(x: 242.81, y: 286.97), controlPoint1: CGPoint(x: 250.18, y: 276.55), controlPoint2: CGPoint(x: 249.36, y: 282.95))
        civil2righteyePath.addCurve(to: CGPoint(x: 215.61, y: 289), controlPoint1: CGPoint(x: 232.76, y: 293.13), controlPoint2: CGPoint(x: 221.91, y: 291.29))
        civil2righteyePath.addCurve(to: CGPoint(x: 204.25, y: 276.6), controlPoint1: CGPoint(x: 210.31, y: 287.07), controlPoint2: CGPoint(x: 204.16, y: 282.09))
        civil2righteyePath.close()
        civil2righteyePath.move(to: CGPoint(x: 209.17, y: 270.63))
        civil2righteyePath.addCurve(to: CGPoint(x: 210.57, y: 283.22), controlPoint1: CGPoint(x: 205.52, y: 274.13), controlPoint2: CGPoint(x: 206.95, y: 280.15))
        civil2righteyePath.addCurve(to: CGPoint(x: 230.9, y: 287.93), controlPoint1: CGPoint(x: 218.63, y: 290.05), controlPoint2: CGPoint(x: 232.44, y: 288.61))
        civil2righteyePath.addCurve(to: CGPoint(x: 231.7, y: 265.67), controlPoint1: CGPoint(x: 224.54, y: 285.12), controlPoint2: CGPoint(x: 221.4, y: 271.49))
        civil2righteyePath.addCurve(to: CGPoint(x: 209.17, y: 270.63), controlPoint1: CGPoint(x: 231.8, y: 265.61), controlPoint2: CGPoint(x: 217.65, y: 262.48))
        civil2righteyePath.close()
        return civil2righteyePath
    }
    
    static func civilianLeftEyePath() -> UIBezierPath {
        let civilLeftEyePath = UIBezierPath()
        civilLeftEyePath.move(to: CGPoint(x: 150.19, y: 280.62))
        civilLeftEyePath.addCurve(to: CGPoint(x: 149.32, y: 275.47), controlPoint1: CGPoint(x: 150.32, y: 279), controlPoint2: CGPoint(x: 149.96, y: 276.95))
        civilLeftEyePath.addCurve(to: CGPoint(x: 146.48, y: 271.32), controlPoint1: CGPoint(x: 148.65, y: 273.92), controlPoint2: CGPoint(x: 147.74, y: 272.7))
        civilLeftEyePath.addCurve(to: CGPoint(x: 112.32, y: 267.56), controlPoint1: CGPoint(x: 140.3, y: 264.53), controlPoint2: CGPoint(x: 122.48, y: 261.57))
        civilLeftEyePath.addCurve(to: CGPoint(x: 104.55, y: 276.65), controlPoint1: CGPoint(x: 110.26, y: 268.78), controlPoint2: CGPoint(x: 105.27, y: 272.17))
        civilLeftEyePath.addCurve(to: CGPoint(x: 112.93, y: 290.74), controlPoint1: CGPoint(x: 103.74, y: 281.65), controlPoint2: CGPoint(x: 106.08, y: 287.56))
        civilLeftEyePath.addCurve(to: CGPoint(x: 138.13, y: 292.66), controlPoint1: CGPoint(x: 124.55, y: 296.14), controlPoint2: CGPoint(x: 131.19, y: 294.03))
        civilLeftEyePath.addCurve(to: CGPoint(x: 150.19, y: 280.62), controlPoint1: CGPoint(x: 144.79, y: 291.35), controlPoint2: CGPoint(x: 149.88, y: 284.77))
        civilLeftEyePath.close()
        civilLeftEyePath.move(to: CGPoint(x: 132.15, y: 268.01))
        civilLeftEyePath.addCurve(to: CGPoint(x: 131.11, y: 291), controlPoint1: CGPoint(x: 122.84, y: 272.44), controlPoint2: CGPoint(x: 123.6, y: 285.67))
        civilLeftEyePath.addCurve(to: CGPoint(x: 110.22, y: 285.26), controlPoint1: CGPoint(x: 131.11, y: 291), controlPoint2: CGPoint(x: 116.46, y: 293.08))
        civilLeftEyePath.addCurve(to: CGPoint(x: 114.08, y: 270.31), controlPoint1: CGPoint(x: 104.18, y: 277.67), controlPoint2: CGPoint(x: 110.2, y: 272.61))
        civilLeftEyePath.addCurve(to: CGPoint(x: 132.15, y: 268.01), controlPoint1: CGPoint(x: 121.91, y: 265.66), controlPoint2: CGPoint(x: 132.22, y: 267.98))
        civilLeftEyePath.close()

       return civilLeftEyePath
   }
} 