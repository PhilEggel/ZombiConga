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
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
        
        zombie.position = CGPoint(x: 400, y: 400)
        zombie.setScale(2.0)
        addChild(zombie)
    }
}