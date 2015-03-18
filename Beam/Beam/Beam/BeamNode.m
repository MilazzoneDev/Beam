//
//  BeamNode.m
//  Beam
//
//  Created by Carl Milazzo on 10/2/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import "BeamNode.h"
#import "SKTUtils.h"
#import "GameScene.h"

@implementation BeamNode
{
    //used to track and show lifetime left
    float _saturation;
    //color of the beam
    float _hue;
    //size of each particle
    double _size;
    
    //time until chnage
    double _changeTime;
    //direction to change to
    CGPoint _direction;
}

//init with the size of the particle, the color of the particle, the duration to stay on screen, the time until it changes direction (spread), and the direction to change to (after spread)
//the parent class will set the initial velocity
-(id)init
{
    if(self = [super init])
    {
        self.Active = NO;
	}
    return self;
}

-(void)reInitWithSize:(double)size andHue:(double)hue withDuration:(double)duration andTime:(double)changeTime toDirection:(CGPoint)direction
{
    _saturation = duration;
    _hue = hue;
    _changeTime = changeTime;
    _direction = direction;
	
	//if the size has changed since the last time this node was used
	//we have to recreate the shapenode and the physicsbody
    if(_size != size)
    {
        [self removeAllChildren];
        _size = size;
        
        //create the node if size is differnet
        CGSize spriteSize = CGSizeMake(_size, _size);
        _sprite = [SKShapeNode shapeNodeWithEllipseOfSize:spriteSize];
        
        //add a physics body to the node
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_size/2];
        self.physicsBody.categoryBitMask = kCategoryBeam;
        self.physicsBody.collisionBitMask = kCategoryWall;
        self.physicsBody.contactTestBitMask = 0;
        self.physicsBody.restitution = 0.9;
        //add it to the screen
        [self addChild:_sprite];
    }
	//if we are calling this method we want to actually make use of the node
    self.Active = YES;
	//make sure that it can move again
	self.physicsBody.dynamic = YES;
	//change the color to the apropriate color
    [_sprite setFillColor:[UIColor colorWithHue:_hue saturation:_saturation brightness:1 alpha:1]];
    [_sprite setStrokeColor:[UIColor clearColor]];
    
    //set up action to allow the node to change direction (spread)
    SKAction* wait = [SKAction waitForDuration:_changeTime];
    SKAction* changeDirection = [SKAction performSelector:@selector(changeVelocity) onTarget:self];
    [self runAction:[SKAction sequence:@[wait,changeDirection]]];
}

-(void)redrawCircle:(float)dt
{
    //used to track lifetime
    _saturation -= dt;
    
    //if life left is <= 0 set it to be removed
    if(_saturation <= 0)
    {
        self.Active = NO;
		[self removeAllActions]; //make sure it's not moving
		self.physicsBody.resting = YES; //make sure no physics is acting on it
		self.physicsBody.dynamic = NO; //make sure it can't move
    }
    //if saturation is less then 1 we want to recolor it
    if(_saturation < 1)
    {
        [_sprite setFillColor:[UIColor colorWithHue:_hue saturation:_saturation brightness:1 alpha:1]];
        [_sprite setStrokeColor:[UIColor clearColor]];
    }
    
}

//used to change direction after spread
-(void)changeVelocity
{
    //what is the old velocity
    CGPoint velocity = CGPointMake([self.physicsBody velocity].dx,[self.physicsBody velocity].dy);
    //grab the speed from the old velocity
    float speed = CGPointLength(velocity);
    //set new velocity with the same speed and the desired direction
    CGPoint newVelocity = CGPointMultiplyScalar(_direction, speed);
    //tell the physicsbody
    [self.physicsBody setVelocity: CGVectorMake(newVelocity.x, newVelocity.y)];
}

@end
