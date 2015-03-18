//
//  Player.m
//  Beam
//
//  Created by Carl Milazzo on 9/24/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import "Player.h"


@implementation Player
{
    double curColor;
    float _playerRadius;
}

-(id)initWithImageNamed:(NSString *)name
{
    if (self = [super initWithImageNamed:name])
    {
        
        
    }
    return self;
}

-(id)initWithRadius:(float)playerRadius
{
    if(self = [super init])
    {
		//create the player sprite
        _playerRadius = playerRadius;
        //_spriteEdge = [SKShapeNode shapeNodeWithCircleOfRadius:_playerRadius];
        //[_spriteEdge setFillColor:[UIColor colorWithHue:0 saturation:0 brightness:0.5 alpha:1]];
        //[_spriteEdge setStrokeColor:[UIColor clearColor]];
		
		_sprite = [[SKSpriteNode alloc]initWithImageNamed:@"PlayerTop"];
		_sprite.size = CGSizeMake(_playerRadius*2, _playerRadius*2);
		
		//_sprite = [[SKSpriteNode alloc] init];
		//[_sprite addChild:_spriteEdge];
		//[_sprite addChild:topImage];
        [self addChild:_sprite];
		
		//creates a circle in front of the player to show direction
        _forwardSprite = [SKShapeNode shapeNodeWithCircleOfRadius:5];
        [_forwardSprite setFillColor:[UIColor whiteColor]];
        [_forwardSprite setStrokeColor:[UIColor clearColor]];
        _forwardSprite.position = CGPointMake(playerRadius, 0);
        
        [self addChild:_forwardSprite];
        
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_playerRadius];
        self.physicsBody.allowsRotation = NO;
        self.physicsBody.dynamic = YES;
    }
    return self;
}

//used to color the player in a rainbow of colors
-(void)redrawCircle:(double)hue
{
	if(curColor != hue)
	{
		curColor = hue;
		//[_sprite setFillColor:[UIColor colorWithHue:color saturation:1 brightness:1 alpha:1]];
		//[_sprite setStrokeColor:[UIColor clearColor]];
		
		[_sprite setColorBlendFactor:0.7];
		[_sprite setColor:[UIColor colorWithHue:curColor saturation:1 brightness:1 alpha:1]];
	}
}

@end
