//
//  GameScene.h
//  Beam
//

//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene :  SKScene<UIAccelerometerDelegate,SKPhysicsContactDelegate>

//------Methods----------//
-(void)initialize;
-(void)initializeFromSave;

-(void)pauseGame;
-(void)playGame;

@end
