//
//  Player.h
//  Beam
//
//  Created by Carl Milazzo on 9/24/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Player : SKSpriteNode

@property SKSpriteNode *sprite;
@property SKShapeNode *spriteEdge;
@property SKShapeNode *forwardSprite;

-(id)initWithImageNamed:(NSString *)name;
-(id)initWithRadius:(float)playerRadius;
-(void)redrawCircle:(double)hue;
@end
