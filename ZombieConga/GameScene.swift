//
//  GameScene.swift
//  ZombieConga
//
//  Created by philippe eggel on 02/11/2015.
//  Copyright (c) 2015 PhilEagleDev. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    
    let playableRect: CGRect
    
    var lastTouchLocation = CGPoint.zero
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - initialize and draw frame
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
        
        zombie.position = CGPoint(x: 400, y: 400)
        addChild(zombie)
        spawnEnemy()
        
        debugDrawPlayableArea()
    }
    
    override func update(currentTime: NSTimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        let distToLastTouchLocation = (lastTouchLocation - zombie.position).length()
        if distToLastTouchLocation <= (zombieMovePointsPerSec * CGFloat(dt)) {
            zombie.position = lastTouchLocation
            boundsCheckZombie()
            velocity = CGPoint.zero
        } else {
            moveSprite(zombie, velocity: velocity)
            boundsCheckZombie()
            rotateSprite(zombie, direction: velocity)
        }
    }
    
    func spawnEnemy() {
        //1 Create enemy
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: size.width + enemy.size.width / 2, y: size.height / 2)
        addChild(enemy)
        
        //2 Add Action
        let actionMidMove = SKAction.moveByX(
            -size.width / 2 - enemy.size.width / 2,
            y: -CGRectGetHeight(playableRect) / 2 + enemy.size.height / 2,
            duration: 1.0)
        
        let actionMove = SKAction.moveByX(
            -size.width / 2 - enemy.size.width / 2,
            y: CGRectGetHeight(playableRect) / 2 - enemy.size.height / 2,
            duration: 1.0)
        
        let wait = SKAction.waitForDuration(0.25)
        
        let logMessage = SKAction.runBlock {
            print("Reached Bottom")
        }
        
        let halfSequence = SKAction.sequence([actionMidMove, logMessage, wait, actionMove])
        let sequence = SKAction.sequence([halfSequence, halfSequence.reversedAction()])
        
        let repeatAction = SKAction.repeatActionForever(sequence)
        enemy.runAction(repeatAction)
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint) {
        let currentAngle = sprite.zRotation
        
        let shortest = shortestAngleBetween(currentAngle, angle2: direction.angle)
        var amountToRotate = zombieRotateRadiansPerSec * CGFloat(dt)
        
        if fabs(shortest) < amountToRotate {
            amountToRotate = shortest
        }
        
        sprite.zRotation += amountToRotate * currentAngle.sign()
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func moveZombieToward(location: CGPoint) {
        //1 Find the vector zombie to the tap
        // diff between zombie and tap
        let offset = location - zombie.position
        
        //2 normalizing the vector based on the zombieMovePointsPerSec length
        let direction = offset.normalized()
        velocity = direction * zombieMovePointsPerSec
    }
    
    
    //MARK: - player interaction
    func sceneTouched(touchLocation: CGPoint) {
        lastTouchLocation = touchLocation
        moveZombieToward(touchLocation)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
}