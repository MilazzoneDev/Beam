//
//  BeamNode.h
//  Beam
//
//  Created by Carl Milazzo on 10/2/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BeamNode : SKSpriteNode

@property SKShapeNode *sprite;
@property (nonatomic, assign) BOOL Active;

extern uint32_t const kCategoryWall;
extern uint32_t const kCategoryBeam;
extern uint32_t const kCategoryPlayer;


-(void)reInitWithSize:(double)size andHue:(double)hue withDuration:(double)duration andTime:(double)changeTime toDirection:(CGPoint)direction;

-(void)redrawCircle:(float)dt;

-(void)changeVelocity;

@end
