//
//  GameScene.swift
//  ColorPass
//
//  Created by Bashir on 2015-04-01.
//  Copyright (c) 2015 b26. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var circleHolder = SKSpriteNode()
    var ball = SKShapeNode()
    var recHolder = SKShapeNode()
    var recOne = SKSpriteNode()
    var recTwo = SKSpriteNode()
    var recThree = SKSpriteNode()
    var timer = NSTimer()
    var scoreHolder = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var score = 0
    
    var nodeCount = 0
    
    enum Collisions:UInt32 {
        case GoodRec = 0
        case BadRec = 1
        case Ball = 2
    }

    
    override init(size: CGSize) {
        super.init(size: size)
        let worldBorder = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody = worldBorder
        self.physicsBody?.friction = 0
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.addChild(circleHolder)
        self.addChild(recHolder)
        self.addChild(scoreHolder)
        loadBackground()
        loadBall()
        
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in (touches as! Set<UITouch>) {
            var location = touch.locationInNode(self)

//            if location.x > 0 && location.x < CGRectGetMidX(self.frame) {
//                ball.physicsBody?.applyImpulse(CGVector(dx: -5, dy: 0))
//            }
//            else {
//                ball.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 0))
//
//            }
            
            self.ball.runAction(SKAction.moveToX(location.x, duration: 0.1))
           // ball.phy
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
    }
    
    
    //Helper Functions
    
    func loadBackground() {
        self.backgroundColor = UIColor.lightGrayColor()
        loadRectangles()
        println(recHolder.children.count)
        println(CGRectGetMidY(self.frame))
        var moveDown = SKAction.moveToY(-count() * CGRectGetMidY(self.frame), duration: 2)
        var moveUp = SKAction.moveToY(self.frame.height, duration: 0)
        //add a timer to keep adding NODES BITCH
        var seq =  SKAction.sequence([moveDown, moveUp])
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("loadRectangles"), userInfo: nil, repeats: true)
        //recHolder.runAction(SKAction.repeatActionForever(moveDown))
        
    }
    
    func count () -> CGFloat {
       return CGFloat(recHolder.children.count)
    }
    
    func loadBall() {
        ball = SKShapeNode(circleOfRadius: 20)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        ball.physicsBody?.dynamic = true
        ball.physicsBody?.categoryBitMask = Collisions.Ball.rawValue
        ball.physicsBody?.collisionBitMask = Collisions.GoodRec.rawValue
        ball.fillColor = UIColor.blueColor()
        ball.strokeColor = UIColor.blueColor()
        ball.physicsBody?.affectedByGravity = false
        ball.name = "ball"
        ball.position = CGPoint(x: CGRectGetMidX(self.frame), y: 100)
        circleHolder.addChild(ball)
        loadScoreLabel()
    }
    
    func loadRectangles () {
        
        var randomNumberOne = arc4random()
        var randomNumberTwo = arc4random()
    

        recOne = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: self.frame.width/2, height: 10))
        recOne.physicsBody = SKPhysicsBody(rectangleOfSize: recOne.size)
        recOne.physicsBody?.dynamic = false
        recOne.physicsBody?.categoryBitMask = Collisions.BadRec.rawValue
        recOne.physicsBody?.collisionBitMask = Collisions.BadRec.rawValue
        recOne.physicsBody?.contactTestBitMask = Collisions.Ball.rawValue
        recOne.name = "recOne\(nodeCount)"
        
        
        recTwo = SKSpriteNode(color: UIColor.blueColor(), size: CGSize(width: self.frame.width/2, height: 10))
        recTwo.physicsBody = SKPhysicsBody(rectangleOfSize: recTwo.size)
        recTwo.physicsBody?.dynamic = false
        recTwo.physicsBody?.categoryBitMask = Collisions.GoodRec.rawValue
        recTwo.physicsBody?.collisionBitMask = Collisions.GoodRec.rawValue
        recTwo.physicsBody?.contactTestBitMask = Collisions.Ball.rawValue
        recTwo.name = "recTwo\(nodeCount)"
        
        
        if randomNumberOne > randomNumberTwo {
            recTwo.position = CGPoint(x: 0 + recTwo.frame.width/2, y: self.frame.height)
            recOne.position = CGPoint(x: self.frame.width - recOne.frame.width/2, y: self.frame.height)
        }
        else if randomNumberOne == randomNumberTwo {
            println("LOL OMG")
        }
        else {
            recOne.position = CGPoint(x: 0 + recOne.frame.width/2, y: self.frame.height)
            recTwo.position = CGPoint(x: self.frame.width - recTwo.frame.width/2, y: self.frame.height)
        }
        
        var moveDown = SKAction.moveToY(-self.frame.height - 100, duration: 3)
        
        recOne.runAction(moveDown, completion: {
            self.childNodeWithName("recOne\(nodeCount)")?.removeFromParent()
        })
        
        recTwo.runAction(moveDown, completion: {
            self.childNodeWithName("recTwo\(nodeCount)")?.removeFromParent()
        })
    
        
        recHolder.addChild(recOne)
        recHolder.addChild(recTwo)
        
        if recHolder.children.count >= 40 {
            timer.invalidate()
        }


    }
    
    func loadScoreLabel () {
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.fontColor = UIColor.blackColor()
        scoreLabel.fontSize = 60
        scoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.frame.height - 120)
        scoreHolder.zPosition = 10
        scoreHolder.addChild(scoreLabel)
    }
    
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == Collisions.BadRec.rawValue {
            timer.invalidate()
            contact.bodyA.node?.speed = 0
            recOne.speed = 0
            recTwo.speed = 0
            println("You failed")
        }
        
        else {
            score++
            scoreLabel.text = "\(score)"
            println("you've won")
        }
    }
    
}
