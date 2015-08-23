//
//  GameScene.swift
//  Evolution
//
//  Created by Jeff Kloosterman on 8/22/15.
//  Copyright (c) 2015 Jeff Kloosterman. All rights reserved.
//

import SpriteKit

extension CollectionType where Index == Int {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }

        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: CGFloat.randomOne(),
                       green: CGFloat.randomOne(),
                       blue: CGFloat.randomOne(),
                       alpha: 1)
    }

    func mutate() -> UIColor {
        var r : CGFloat = 0
        var g : CGFloat = 0
        var b : CGFloat = 0
        var a : CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)

         return UIColor(red: r + CGFloat.randomRange(-0.01, max: 0.01),
                        green: g + CGFloat.randomRange(-0.01, max: 0.01),
                        blue: b + CGFloat.randomRange(-0.01, max: 0.01),
                        alpha: a)
    }

    func distanceToColor(color : UIColor) -> Float {
        var r0 : CGFloat = 0
        var g0 : CGFloat = 0
        var b0 : CGFloat = 0
        var a0 : CGFloat = 0
        self.getRed(&r0, green: &g0, blue: &b0, alpha: &a0)

        var r1 : CGFloat = 0
        var g1 : CGFloat = 0
        var b1 : CGFloat = 0
        var a1 : CGFloat = 0
        color.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)

        return Float(sqrt(pow((r0 - r1), 2) + pow((g0 - g1), 2) + pow((b0 - b1), 2)))
    }
}

extension CGFloat {
    static func randomOne() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX)
    }

    static func randomNumber(max : CGFloat) -> CGFloat {
        return CGFloat.randomOne() * max
    }

    static func randomRange(min : CGFloat, max : CGFloat) -> CGFloat {
        return min + CGFloat.randomNumber(max - min)
    }
}

class GameScene: SKScene {

    var creatures : [SKShapeNode] = []

    func seed(n : Int = 28) {
        for i in 0 ..< n {
            let radius = 40
            let diameter = 2 * radius
            let x = (i * diameter + radius) % Int(self.view!.frame.width)
            let y = (i / (Int(self.view!.frame.width) / diameter) * diameter + radius)
            let creature = SKShapeNode(circleOfRadius: CGFloat(radius - 2))
            creature.strokeColor = UIColor.clearColor()
            creature.position = CGPoint(x: x, y: y)
            creature.fillColor = UIColor.random()
            self.creatures.append(creature)
        }
    }

    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.random()
        self.seed()
        for creature in self.creatures {
            self.addChild(creature)
        }
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        var sortedCreatures = self.creatures.sort { [unowned self] in $0.fillColor.distanceToColor(self.backgroundColor) < $1.fillColor.distanceToColor(self.backgroundColor) }

        if sortedCreatures.last!.fillColor.distanceToColor(self.backgroundColor) < 0.01 {
            self.backgroundColor = UIColor.random()
        }

        for _ in 0 ..< self.creatures.count / 20 {
            let removed = sortedCreatures.last!
            sortedCreatures.removeLast()
            let copy = sortedCreatures.first!

            removed.fillColor = copy.fillColor
        }

        for _ in 0 ..< self.creatures.count / 10 {
            let randomIndex = Int(arc4random_uniform(UInt32(sortedCreatures.count)))
            self.creatures[randomIndex].fillColor = self.creatures[randomIndex].fillColor.mutate()
        }
    }
}
