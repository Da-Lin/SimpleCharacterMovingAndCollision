//
//  GameScene.swift
//  PlayAround
//
//  Created by Justin Dike on 1/10/17.
//  Copyright © 2017 Justin Dike. All rights reserved.
//

import SpriteKit
import GameplayKit

enum BodyType:UInt32{
    
    case player = 1
    case building = 2
    case castle = 4
    case road = 8
    
    //powers of 2 (so keep multiplying by 2
    
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var thePlayer:SKSpriteNode = SKSpriteNode()
    var moveSpeed:TimeInterval = 1
    let swipeRightRec = UISwipeGestureRecognizer()
    let swipeLeftRec = UISwipeGestureRecognizer()
    let swipeUpRec = UISwipeGestureRecognizer()
    let swipeDownRec = UISwipeGestureRecognizer()
    let rotateRec = UIRotationGestureRecognizer()
    let tapRec = UITapGestureRecognizer()
    var tileMap = SKTileMapNode()
    
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        self.physicsWorld.gravity = CGVector(dx: 1, dy: 0)
        
        /*
        
        tapRec.addTarget(self, action:#selector(GameScene.tappedView))
        tapRec.numberOfTouchesRequired = 2
        tapRec.numberOfTapsRequired = 3
        self.view!.addGestureRecognizer(tapRec)
        
        
        rotateRec.addTarget(self, action: #selector (GameScene.rotatedView (_:) ))
        self.view!.addGestureRecognizer(rotateRec)
 
         */
        
        swipeRightRec.addTarget(self, action: #selector(GameScene.swipedRight) )
        swipeRightRec.direction = .right
        self.view!.addGestureRecognizer(swipeRightRec)
        
        swipeLeftRec.addTarget(self, action: #selector(GameScene.swipedLeft) )
        swipeLeftRec.direction = .left
        self.view!.addGestureRecognizer(swipeLeftRec)
        
        
        swipeUpRec.addTarget(self, action: #selector(GameScene.swipedUp) )
        swipeUpRec.direction = .up
        self.view!.addGestureRecognizer(swipeUpRec)
        
        swipeDownRec.addTarget(self, action: #selector(GameScene.swipedDown) )
        swipeDownRec.direction = .down
        self.view!.addGestureRecognizer(swipeDownRec)
        
        
        if let somePlayer:SKSpriteNode = self.childNode(withName: "Player") as? SKSpriteNode {
            
            thePlayer = somePlayer
            thePlayer.physicsBody?.isDynamic = true
            thePlayer.physicsBody?.affectedByGravity = false
            thePlayer.physicsBody?.categoryBitMask = BodyType.player.rawValue
            thePlayer.physicsBody?.collisionBitMask = BodyType.castle.rawValue | BodyType.road.rawValue
            thePlayer.physicsBody?.contactTestBitMask = BodyType.building.rawValue | BodyType.castle.rawValue
            
            
        }
        
        for node in self.children {
            
            if (node.name == "Building") {
                
                if (node is SKSpriteNode) {
                    
                    node.physicsBody?.categoryBitMask = BodyType.building.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    
                    print ("found a building")
                }
                
                
                
            }
            
            
            if let aCastle:Castle = node as? Castle {
                
                aCastle.setUpCastle()
                aCastle.dudesInCastle = 5
                
            }
            
        }
        
        self.tileMap = (self.childNode(withName: "Tile Map") as? SKTileMapNode)!
        
        let tileSize = tileMap.tileSize
        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width
        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height
        
        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row)
                let isEdgeTile = tileDefinition?.userData?["edgeTile"] as? Bool
                if (isEdgeTile ?? false) {
                    print(isEdgeTile)
                    let x = CGFloat(col) * tileSize.width - halfWidth
                    let y = CGFloat(row) * tileSize.height - halfHeight
                    let rect = CGRect(x: 0, y: 0, width: tileSize.width, height: tileSize.height)
                    let tileNode = SKShapeNode(rect: rect)
                    tileNode.position = CGPoint(x: x, y: y)
                    tileNode.physicsBody = SKPhysicsBody.init(rectangleOf: tileSize, center: CGPoint(x: tileSize.width / 2.0, y: tileSize.height / 2.0))
                    tileNode.physicsBody?.isDynamic = false
                    tileNode.physicsBody?.collisionBitMask = BodyType.player.rawValue
                    tileNode.physicsBody?.categoryBitMask = BodyType.road.rawValue
                    tileMap.addChild(tileNode)
                }
            }
        }
        
       
        
        
    
    }
    
    
    //MARK: ============= Gesture Recognizers
    
    func tappedView() {
        
        print("tapped three times")
        
    }

    
    func swipedRight() {
        
        print(" right")
        
        move(theXAmount: 100, theYAmount: 0, theAnimation: "WalkRight")
    }
    
    func swipedLeft() {
        
        print(" left")

       move(theXAmount: -100, theYAmount: 0, theAnimation: "WalkLeft")
    }
    
    func swipedUp() {
        
        print(" up")
        
        move(theXAmount: 0, theYAmount: 100, theAnimation: "WalkBack")
    }
    
    func swipedDown() {
        
        print(" down")
        
        move(theXAmount: 0, theYAmount: -100, theAnimation: "WalkFront")
        
       
    }

    
  

    
    func cleanUp(){
        
        //only need to call when presenting a different scene class
        
        for gesture in (self.view?.gestureRecognizers)! {
            
            self.view?.removeGestureRecognizer(gesture)
        }
        
        
    }
    
    
    
    func rotatedView(_ sender:UIRotationGestureRecognizer) {
        
        if (sender.state == .began) {
            
             print("rotation began")
            
        }
        if (sender.state == .changed) {
            
            print("rotation changed")
            
            //print(sender.rotation)
            
            let rotateAmount = Measurement(value: Double(sender.rotation), unit: UnitAngle.radians).converted(to: .degrees).value
            print(rotateAmount)
            
            thePlayer.zRotation = -sender.rotation
            
        }
        if (sender.state == .ended) {
            
            print("rotation ended")
            
            
        }
        
        
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        for node in self.children {
            
            if (node.name == "Building") {
                
                if (node.position.y > thePlayer.position.y){
                    
                    node.zPosition = -100
                    
                } else {
                    
                    node.zPosition = 100
                    
                }
                    
                    
            }
        }

        
        
    }
    
    
    func move(theXAmount:CGFloat , theYAmount:CGFloat, theAnimation:String )  {
        
        
        let wait:SKAction = SKAction.wait(forDuration: 0.05)
        
        let walkAnimation:SKAction = SKAction(named: theAnimation, duration: moveSpeed )!
        
        let moveAction:SKAction = SKAction.moveBy(x: theXAmount, y: theYAmount, duration: moveSpeed )
        
        let group:SKAction = SKAction.group( [ walkAnimation, moveAction ] )
        
        let finish:SKAction = SKAction.run {
            
            //print ( "Finish")
            
           
        }
        
        
        let seq:SKAction = SKAction.sequence( [wait, group, finish] )
        
        
        
        thePlayer.run(seq)
        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
        /*
        if ( pos.y > 0) {
            //top half touch
            
        } else {
            //bottom half touch
            
            moveDown()
            
        }
         */
        
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
                
        for t in touches {
            
            self.touchDown(atPoint: t.location(in: self))
            
            break
        
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
   
    //MARK: Physics contacts 
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if (contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.building.rawValue) {
            
            print ("touched a building")
        } else if (contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.building.rawValue) {
            
            print ("touched a building")
            
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.castle.rawValue) {
            
            print ("touched a castle")
        } else if (contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.castle.rawValue) {
            
            print ("touched a castle")
        }
        
        
    }
    
    
    
    
}



