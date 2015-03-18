//
//  GameScene.m
//  Beam
//
//  Created by Carl Milazzo on 9/24/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import "GameScene.h"
#import "Player.h"
#import "BeamNode.h"
#import "AnalogControl.h"
#import "ButtonControl.h"
#import "OptionsMenu.h"
#import "SKTUtils.h"
#import <CoreMotion/CoreMotion.h>
@import AVFoundation;

#pragma mark constant variables
//-------Collision--------//
uint32_t const kCategoryWall = 0x1 << 0;
uint32_t const kCategoryBeam = 0x1 << 1;
uint32_t const kCategoryPlayer = 0x1 << 2;

//-------Movement constants---------//
//player speed when not shooting
static float const kMaxPlayerSpeed = 100;
//maxPlayerSpeed/beamSpeedDivider = player speed when shooting
static float const kBeamSpeadDivider = 5;
//starting value for players max rotation speed when using beam
static float const kMaxPlayerRotationWithBeam = M_PI*2/5;

//-------Beam constants-------------//
//speed of beam nodes
static float const kBeamSpeed = 240;
//initial color of the beam
static float const kBeamInitialHue = 0.8;
//time at which new beam nodes are created
static float const kBeamTick = 0.045;
//starting beam nodes per tick
static int const kStartBeamNodes = 5;
//starting beam node size
static float const kBeamInitialNodeSize = 7;
//beam node spread (in radians)
static float const kBeamInitialNodeSpread = M_PI/3.5;
//duration that beam nodes stay on the screen
static float const kBeamDuration = 1.75;
//time until direction change
static float const kBeamDirectionChangeTime = 0.07;
//total number of beam nodes created (bullet pool)
static float const kBeamNodesTotal = 250;

//-------Player constants ----------//
//size of player
static float const kPlayerRadius = 20;

//-------Enemy starter constants----//

//-------ZPositions-----------------//
static int const kZPositionBeam = 10;
static int const kZPositionPlayer = 1;

@implementation GameScene
{
    Player* _player;
    
    //CMMotionManager *_motionManager;
    //double _accelX;
    //double _accelY;
    double _lastTime;
    
    //beam variables
    double _lastBeamSpread;
    int _beamNodesPerTick;
    float _beamNodeSpread;
    float _beamNodeSize;
    float _beamNodeHue;
    BOOL _beamOn;
	CGFloat _beamOffYPos;
	CGFloat _beamOffXPos;
    
    //movement variables
    CGPoint _analogPosition;
    CGPoint _lastDirection;
    float _playerMaxMoveSpeedWithBeam;
    
    //Enemies and level variables
    
}

#pragma mark on load methods
-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    //starts a new game (to be called in view controller later)
    [self initialize];
    
}

//initialize variables and player
-(void)initialize
{
	
	//layout screendecoration
	[self layoutScreenDecoration];
	
    //initialize player
    _player = [[Player alloc]initWithRadius:kPlayerRadius];
    _player.position = CGPointMake(self.size.width/2, self.size.height/2);
    _player.zPosition = kZPositionPlayer;
    _player.physicsBody.categoryBitMask = kCategoryPlayer;
    _player.physicsBody.contactTestBitMask = 0;
    _player.physicsBody.collisionBitMask = kCategoryWall;
    _lastDirection = CGPointMake(1, 0);
    [self addChild:_player];
    
    //set player variables with starting values
	[_player redrawCircle:kBeamInitialHue];
	
    //zero out times
    _lastTime = (double)CFAbsoluteTimeGetCurrent();
    _lastBeamSpread = (double)CFAbsoluteTimeGetCurrent();
    
    //set beam variables with starting values
	_beamOffXPos = self.size.width*2;
	_beamOffYPos = self.size.height;
    [self fillBeamNodes];
    _beamNodesPerTick = kStartBeamNodes;
    _beamNodeSpread = kBeamInitialNodeSpread;
    _beamNodeSize = kBeamInitialNodeSize;
    _beamNodeHue = kBeamInitialHue; //temp (will use NSUserDefaults along with hue selection later)
	
    //set world physics body and image
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsBody.categoryBitMask = kCategoryWall;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = 0;
    self.physicsBody.dynamic = NO;
    self.physicsWorld.contactDelegate = self;
}

-(void)initializeFromSave
{
    
}

#pragma mark update methods
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    // calculate deltaTime
    double time = (double)CFAbsoluteTimeGetCurrent();
    // NSLog(@"time=%f",time);
    CGFloat dt = time - _lastTime;
    _lastTime = time;
    //NSLog(@"delta=%f",dt);
    
    //beam update
    [self beamNodesUpdate:dt withTime:time];
    
    //possible, player rotate
    [self playerUpdate:dt];
    
}

//beam update
-(void)beamNodesUpdate:(double)dt withTime:(double)time
{
    if(_beamOn)
    {
        if(time - _lastBeamSpread >= kBeamTick)
        {
            //fire new nodes
            [self generateBeamNodes];
            //update _lastBeamSpread
            _lastBeamSpread = time;
        }
    }
    //search through all of the active nodes and update them
	[self enumerateChildNodesWithName:@"beamNode" usingBlock:^(SKNode *node, BOOL *stop)
	{
		BeamNode* beam = (BeamNode*)node;
		[beam redrawCircle:dt];
		//if beam not active remove it
		if(!beam.Active)
		{
			//move off the screen and make inactive
			beam.position = CGPointMake(_beamOffXPos, _beamOffYPos);
			beam.name = @"inactiveBeam";
		}
		
    }];
}

//player update
-(void)playerUpdate:(double)dt
{
    if(_beamOn)
    {
        if(!CGPointEqualToPoint(_analogPosition,CGPointZero))
        {
            CGPoint newDirection = CGPointMake(_analogPosition.x,-_analogPosition.y);
            CGFloat shortest = ScalarShortestAngleBetween(_player.zRotation,CGPointToAngle(newDirection));
            CGFloat amtToRotate = kMaxPlayerRotationWithBeam * dt;
            if(ABS(shortest) <= amtToRotate)
            {
                _player.zRotation += shortest;
            }
            else
            {
                _player.zRotation += (ScalarSign(shortest)*amtToRotate);
            }
			
            _lastDirection = CGPointNormalize(CGPointMake(CGPointForAngle(_player.zRotation).x,CGPointForAngle(_player.zRotation).y));
            
        }
    }
    else
    {
        if(!CGPointEqualToPoint(_analogPosition,CGPointZero))
        {
            _player.zRotation = CGPointToAngle(CGPointMake(_analogPosition.x,-_analogPosition.y));
            _lastDirection = CGPointNormalize(CGPointMake(_analogPosition.x,-_analogPosition.y));
        }
    }
}

#pragma mark Generate Beam
//generates new beam nodes
-(void)fillBeamNodes
{
    for (int x = 0; x< kBeamNodesTotal; x++)
    {
        BeamNode* node = [[BeamNode alloc]init];
        //sets up beam nodes in a beam pool
        node.zPosition = kZPositionBeam;
		node.position = CGPointMake(_beamOffXPos, _beamOffYPos);
		node.name = @"inactiveBeam";
		[self addChild:node];
    }
	
}

//sets up spread actions and re-initializes values
-(void)generateBeamNodes
{
    //variables for spread calculation
    CGPoint spreadStart = CGPointForAngle(CGPointToAngle(_lastDirection)-(_beamNodeSpread/2));
    CGPoint spreadEnd = CGPointForAngle(CGPointToAngle(_lastDirection)+(_beamNodeSpread/2));
    for (int x = 0; x< _beamNodesPerTick; x++)
    {
		//grab an inactive beam node from the pool of inactives
		BeamNode* node = (BeamNode*)[self childNodeWithName:@"inactiveBeam"];
		if(node)
		{
			//rename it to keep it out of the inactive pool
			node.name = @"beamNode";
			//re initialize the node to the proper position, size, color, and directions
			[node reInitWithSize:_beamNodeSize andHue:_beamNodeHue withDuration:kBeamDuration andTime:kBeamDirectionChangeTime toDirection:CGPointForAngle(_player.zRotation)];
			
			node.zPosition = kZPositionBeam;
			
			node.position = CGPointAdd(_player.position, CGPointMultiplyScalar(CGPointForAngle(_player.zRotation), kPlayerRadius));
			
			//calculate angle to fire for each node per tick
			CGPoint fireVelocity;
			if(_beamNodesPerTick-1 <= 0)
			{
				fireVelocity = CGPointLerp(spreadStart, spreadEnd, 1.0/2.0);
			}
			else
			{
				fireVelocity = CGPointLerp(spreadStart, spreadEnd, (double)x/(_beamNodesPerTick-1));
			}
			fireVelocity = CGPointNormalize(fireVelocity);
			fireVelocity = CGPointMultiplyScalar(fireVelocity, kBeamSpeed);
			
			[node.physicsBody setVelocity:CGVectorMake(fireVelocity.x, fireVelocity.y)];
		}
		else
		{
			NSLog(@"ran out of nodes");
		}
    }
}


#pragma mark contact
-(void)didBeginContact:(SKPhysicsContact *)contact
{
    //NSLog(@"contact=%@",contact);
    //Handle contacts between two physics bodies.
    //Contacts are often a double dispatch problem, the effect you want
    //is based on the type of both bodies in the contact. This sample solves
    //this in a brute force way, by checking the types of each. A more
    //complicatd example might use methods on objects to perform the type checking.
}

#pragma decorations
-(void)layoutScreenDecoration
{
	CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
	int glowWidth = 10;
	UIColor *glowColor = [UIColor yellowColor];
	
	SKShapeNode *edgeloop = [SKShapeNode shapeNodeWithRectOfSize:self.size];
	edgeloop.position = center;
	edgeloop.strokeColor = glowColor;
	edgeloop.glowWidth = glowWidth;
	
	[self addChild:edgeloop];
	
	
	SKShapeNode *innercircle = [SKShapeNode shapeNodeWithCircleOfRadius:30];
	innercircle.position = center;
	innercircle.strokeColor = glowColor;
	innercircle.glowWidth = glowWidth;
	
	[self addChild:innercircle];
	
	
	
}

#pragma mark key-value-observers for controls
//observers for controls
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"relativePosition"])
    {
        [self analogControlUpdated:object];
    }
    if([keyPath isEqualToString:@"buttonPressed"])
    {
        [self buttonControlUpdated:object];
    }
    if([keyPath isEqualToString:@"sliderValue"])
    {
        [self sliderControlUpdated:object];
    }
}

//movement controls
-(void)analogControlUpdated:(AnalogControl*)analogControl
{
    _analogPosition = analogControl.relativePosition;
    if(_beamOn)
    {
        [_player.physicsBody setVelocity:CGVectorMake(_analogPosition.x*(kMaxPlayerSpeed/kBeamSpeadDivider),-_analogPosition.y*(kMaxPlayerSpeed/kBeamSpeadDivider))];
        
    }
    else
    {
        [_player.physicsBody setVelocity:CGVectorMake(_analogPosition.x*kMaxPlayerSpeed,-_analogPosition.y*kMaxPlayerSpeed)];
    }
    /*
    if(!CGPointEqualToPoint(analogControl.relativePosition,CGPointZero))
    {
        _player.zRotation = CGPointToAngle(CGPointMake(_analogPosition.x,-_analogPosition.y));
        _lastDirection = CGPointNormalize(CGPointMake(_analogPosition.x,-_analogPosition.y));
    }
    */
}

//button controls
-(void)buttonControlUpdated:(ButtonControl*)buttonControl
{
    _beamOn = buttonControl.buttonPressed;
    
    if(_beamOn)
    {
        [_player.physicsBody setVelocity:CGVectorMake(_analogPosition.x*(kMaxPlayerSpeed/kBeamSpeadDivider),-_analogPosition.y*(kMaxPlayerSpeed/kBeamSpeadDivider))];
    }
    else
    {
        [_player.physicsBody setVelocity:CGVectorMake(_analogPosition.x*kMaxPlayerSpeed,-_analogPosition.y*kMaxPlayerSpeed)];
    }
}

-(void)sliderControlUpdated:(OptionsMenu*)optionsMenu
{
	//used to color the beam
    _beamNodeHue = optionsMenu.sliderValue;
	//redraws the player with the apropriate color
	[_player redrawCircle:optionsMenu.sliderValue];
}

#pragma mark pause game
-(void)pauseGame
{
    self.scene.view.paused = YES;
}
-(void)playGame
{
    self.scene.view.paused = NO;
    _lastTime = (double)CFAbsoluteTimeGetCurrent();
}


@end
