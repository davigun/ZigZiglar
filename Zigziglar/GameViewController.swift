//
//  GameViewController.swift
//  Zigziglar
//
//  Created by David Gunawan on 6/27/16.
//  Copyright (c) 2016 Davidgun. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit
import GameKit



struct bodyNames {
    static let Person = 0x1 << 1
    static let Coin = 0x1 << 2
}



class GameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate, GKGameCenterControllerDelegate{
    
    let scene = SCNScene()
    let cameraNode = SCNNode()
    
    var person = SCNNode()
    
    let firstBox = SCNNode()
    
    var goingLeft = Bool()
    
    var tempBox = SCNNode()
    
    var prevBoxNumber = Int()
    
    var boxNumber = Int()
    
    var firstOne = Bool()
    
    var score = Int()
    var highscore = Int()
    
    var dead = Bool()
    
    
    var scoreLabel = UILabel()
    var highscoreLabel = UILabel()
    
    var gameButton = UIButton()
    
    override func viewDidLoad() {
        self.createScene()
        
        authenticatePlayer()
        
        scene.physicsWorld.contactDelegate = self
        
        scoreLabel = UILabel(frame: CGRect(origin: CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 + self.view.frame.height / 2.5), size: CGSizeMake(self.view.frame.width, 100)))
        
        scoreLabel.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 - self.view.frame.height / 2.5)
        scoreLabel.textAlignment = .Center
        scoreLabel.text = "Score : \(score)"
        scoreLabel.textColor = UIColor.darkGrayColor()
        self.view.addSubview(scoreLabel)
        
        highscoreLabel = UILabel(frame: CGRect(origin: CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 + self.view.frame.height / 2.5), size: CGSizeMake(self.view.frame.width, 100)))
        
        highscoreLabel.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 + self.view.frame.height / 2.5)
        highscoreLabel.textAlignment = .Center
        highscoreLabel.text = "Highscore : \(highscore)"
        highscoreLabel.textColor = UIColor.darkGrayColor()
        self.view.addSubview(highscoreLabel)
        
        gameButton = UIButton(type: UIButtonType.Custom)
        gameButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        gameButton.center = CGPoint(x: self.view.frame.width - 40, y: 60)
        gameButton.setImage(UIImage(named: "gamecenter"), forState: .Normal)
        gameButton.addTarget(self, action: Selector("showLeaderboard"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(gameButton)
        
        
        
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        if nodeA.physicsBody?.categoryBitMask == bodyNames.Coin && nodeB.physicsBody?.categoryBitMask == bodyNames.Person{
            nodeA.removeFromParentNode()
            addScore()
        }
            
            
            
        else if nodeA.physicsBody?.categoryBitMask == bodyNames.Person && nodeB.physicsBody?.categoryBitMask == bodyNames.Coin{
            nodeB.removeFromParentNode()
            addScore()
            
        }
        
        
        
        
    }
    func updateLabel(){
        scoreLabel.text = "Score : \(score)"
        highscoreLabel.text = "Highscore : \(highscore)"
        
    }
    
    
    func addScore(){
        score += 1
        
        self.performSelectorOnMainThread(Selector("updateLabel"), withObject: nil, waitUntilDone: false)
        
        
        if score > highscore{
            
            highscore = score
            
            let scoreDefault = NSUserDefaults.standardUserDefaults()
            scoreDefault.setInteger(highscore, forKey: "highscore")
            print(highscore)
            
        }
        
    }
    
    
    
    
    
    func fadeIn(node : SCNNode){
        
        node.opacity = 0
        node.runAction(SCNAction.fadeInWithDuration(0.5))
        
    }
    func createCoin(box : SCNNode){
        scene.physicsWorld.gravity = SCNVector3Make(0, 0, 0)
        let spin = SCNAction.rotateByAngle(CGFloat(M_PI * 2), aroundAxis: SCNVector3Make(0, 0.5 , 0) , duration: 0.5)
        let randomNumber = arc4random() % 8
        if randomNumber == 3{
            let coinScene = SCNScene(named: "Coin.dae")
            let coin = coinScene?.rootNode.childNodeWithName("Coin", recursively: true)
            coin?.position = SCNVector3Make(box.position.x, box.position.y + 1, box.position.z)
            coin?.scale = SCNVector3Make(0.2, 0.2, 0.2)
            
            
            coin?.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: SCNPhysicsShape(node: coin!, options: nil))
            coin?.physicsBody?.categoryBitMask = bodyNames.Coin
            coin?.physicsBody?.contactTestBitMask = bodyNames.Person
            coin?.physicsBody?.collisionBitMask = bodyNames.Person
            coin?.physicsBody?.affectedByGravity = false
            
            
            scene.rootNode.addChildNode(coin!)
            coin?.runAction(SCNAction.repeatActionForever(spin))
            fadeIn(coin!)
        }
        
    }
    
    func fadeOut(node : SCNNode){
        let move = SCNAction.moveTo(SCNVector3Make(node.position.x, node.position.y - 2, node.position.z), duration: 0.5)
        node.runAction(move)
        node.runAction(SCNAction.fadeOutWithDuration(0.5))
    }
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        if dead == false{
            let deleteBox = self.scene.rootNode.childNodeWithName("\(prevBoxNumber)", recursively: true)
            
            let currentBox = self.scene.rootNode.childNodeWithName("\(prevBoxNumber + 1)", recursively: true)
            
            if deleteBox?.position.x > person.position.x + 1 || deleteBox?.position.z > person.position.z + 1{
                
                
                prevBoxNumber += 1
                
                fadeOut(deleteBox!)
                
                createBox()
                
            }
            
            if person.position.x > currentBox!.position.x - 0.5 && person.position.x < currentBox!.position.x + 0.5 || person.position.z > currentBox!.position.z - 0.5 && person.position.z < currentBox!.position.z + 0.5 {
                // Add scoring
            }
            else{
                
                die()
                dead = true
            }
            
        }
        
    }
    
    func die(){
        person.runAction(SCNAction.moveTo(SCNVector3Make(person.position.x, person.position.y - 10, person.position.z), duration: 1.0))
        
        let wait = SCNAction.waitForDuration(0.5)
        let sequence = SCNAction.sequence([wait, SCNAction.runBlock({
            node in
            
            self.scene.rootNode.enumerateChildNodesUsingBlock({
                node, stop in
                
                node.removeFromParentNode()
                
            })
            
        }), SCNAction.runBlock({
            node in
            
            print("HI")
            self.createScene()
            
            
        })])
        
        
        
        person.runAction(sequence)
    }
    
    func createBox(){
        tempBox = SCNNode(geometry: firstBox.geometry)
        let prevBox = scene.rootNode.childNodeWithName("\(boxNumber)", recursively: true)
        
        boxNumber += 1
        tempBox.name = "\(boxNumber)"
        
        let randomNumber = arc4random() % 2
        
        switch randomNumber{
            
        case 0:
            tempBox.position = SCNVector3Make((prevBox?.position.x)! - firstBox.scale.x, (prevBox?.position.y)!, (prevBox?.position.z)!)
            
            
            if firstOne == true{
                firstOne = false
                goingLeft = false
                
            }
            
            
            break
        case 1:
            tempBox.position = SCNVector3Make((prevBox?.position.x)!, (prevBox?.position.y)!, (prevBox?.position.z)! - firstBox.scale.z)
            
            
            if firstOne == true{
                firstOne = false
                goingLeft = true
                
            }
            break
        default:
            
            break
        }
        
        self.scene.rootNode.addChildNode(tempBox)
        createCoin(tempBox)
        fadeIn(tempBox)
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if dead == false{
            self.performSelectorOnMainThread(Selector("updateLabel"), withObject: nil, waitUntilDone: false)
            if goingLeft == false{
                person.removeAllActions()
                person.runAction(SCNAction.repeatActionForever(SCNAction.moveBy(SCNVector3Make(-100, 0, 0), duration: 20)))
                goingLeft = true
                
            }
            else {
                person.removeAllActions()
                person.runAction(SCNAction.repeatActionForever(SCNAction.moveBy(SCNVector3Make(0, 0, -100), duration: 20)))
                goingLeft = false
                
                
            }
        }
    }
    
    func createScene(){
        
        let scoreDefault = NSUserDefaults.standardUserDefaults()
        
        if scoreDefault.integerForKey("highscore") != 0{
            
            highscore = scoreDefault.integerForKey("highscore")
        }
        else{
            
            highscore = 0
        }
        print(highscore)
        
        
        
        
        
        boxNumber = 0
        score = 0
        prevBoxNumber = 0
        firstOne = true
        dead = false
        
        
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let sceneView = self.view as! SCNView
        sceneView.delegate = self
        sceneView.scene = scene
        
        
        //Create Person
        
        let personGeo = SCNSphere(radius: 0.2)
        person = SCNNode(geometry: personGeo)
        let personMat = SCNMaterial()
        personMat.diffuse.contents = UIColor.redColor()
        personGeo.materials = [personMat]
        person.position = SCNVector3Make(0, 1.1, 0)
        
        person.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: SCNPhysicsShape(node: person, options: nil))
        person.physicsBody?.categoryBitMask = bodyNames.Person
        person.physicsBody?.collisionBitMask = bodyNames.Coin
        person.physicsBody?.contactTestBitMask = bodyNames.Coin
        person.physicsBody?.affectedByGravity = false
        
        scene.rootNode.addChildNode(person)
        
        //Create Camera
        
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 3
        cameraNode.position = SCNVector3Make(20, 20, 20)
        cameraNode.eulerAngles = SCNVector3Make(-45, 45, 0)
        let constraint = SCNLookAtConstraint(target: person)
        constraint.gimbalLockEnabled = true
        self.cameraNode.constraints = [constraint]
        scene.rootNode.addChildNode(cameraNode)
        person.addChildNode(cameraNode)
        
        //Create Box
        
        let firstBoxGeo = SCNBox(width: 1, height: 1.5, length: 1, chamferRadius: 0)
        firstBox.geometry = firstBoxGeo
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIColor(red: 0.2, green: 0.8, blue: 0.9, alpha: 1.0)
        firstBoxGeo.materials = [boxMaterial]
        firstBox.position = SCNVector3Make(0, 0, 0)
        scene.rootNode.addChildNode(firstBox)
        firstBox.name = "\(boxNumber)"
        firstBox.opacity = 1
        
        
        
        for i in 0...6{
            
            createBox()
        }
        
        //Create Light
        
        let light = SCNNode()
        light.light = SCNLight()
        light.light?.type = SCNLightTypeDirectional
        light.eulerAngles = SCNVector3Make(-45, 45, 0)
        scene.rootNode.addChildNode(light)
        
        let light2 = SCNNode()
        light2.light = SCNLight()
        light2.light?.type = SCNLightTypeDirectional
        light2.eulerAngles = SCNVector3Make(45, -45, 0)
        scene.rootNode.addChildNode(light2)
        
    }
    
    
    func authenticatePlayer(){
        
        let localPlayer = GKLocalPlayer()
        
        localPlayer.authenticateHandler = {
            (viewController, error) in
            
            if viewController != nil {
                
                self.presentViewController(viewController!, animated: true, completion: nil)
            }
                
            else{
                print("logged in")
            }
            
            
        }
        
        
    }
    
    func saveHighscore(score : Int){
        
        if GKLocalPlayer.localPlayer().authenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "zag.002")
            
            scoreReporter.value = Int64(score)
            
            
            let scoreArray : [GKScore] = [scoreReporter]
            
            GKScore.reportScores(scoreArray, withCompletionHandler: nil)
            print("HI")
            
        }
        
    }
    
    func showLeaderboard(){
        saveHighscore(highscore)
        
        let gc = GKGameCenterViewController()
        
        gc.gameCenterDelegate = self
        
        self.presentViewController(gc, animated: true, completion: nil)
        
        
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
