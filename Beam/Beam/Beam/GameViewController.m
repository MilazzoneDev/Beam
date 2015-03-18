//
//  GameViewController.m
//  Beam
//
//  Created by Carl Milazzo on 9/24/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "AnalogControl.h"
#import "ButtonControl.h"
#import "OptionsButton.h"
#import "OptionsMenu.h"

//values for buttons
static float const padSide = 128;
static float const padPadding = 10;
//options postions values
static float const optionsOnYPosition = padPadding*3;
static float const optionsXPosition = padPadding*3;
static float optionsOffYPosition; //set in setUpOptions

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@implementation GameViewController
{
    //UI
    AnalogControl *_analogControl;
    ButtonControl *_buttonControl;
    OptionsButton *_optionControl;
    
    //views
    SKView *skView;
    GameScene *_scene;
    OptionsMenu *_options;
    
    //iAd variables
    BOOL _bannerIsVisible;
    ADBannerView *_iAd;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (!skView)
    {
        // Configure the view.
        skView = [[SKView alloc] initWithFrame:self.view.bounds];//(SKView *)self.view;
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = YES;
        //skView.showsPhysics = YES;
        
        //sets up the game scene
        [self setUpGameView];
        [self setUpOptions];
        
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
}

#pragma mark setup options and game scene
-(void)setUpOptions
{
    //set the optionsOffYPosition to be off the screen
    optionsOffYPosition = -skView.frame.size.height;
    _options = [[OptionsMenu alloc] initWithFrame:CGRectMake(optionsXPosition, optionsOffYPosition,skView.frame.size.width-(padPadding*6) , skView.frame.size.height-(padPadding*6))];
    _options.hidden = YES;
    [_options setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_options];
    //slider to change the hue
    [_options addObserver:_scene forKeyPath:@"sliderValue" options:NSKeyValueObservingOptionNew context:nil];
    //button to close the options menu
    [_options addObserver:self forKeyPath:@"donePressed" options:NSKeyValueObservingOptionNew context:nil];
    
}

-(void)setUpGameView
{
    // Create and configure the scene.
    CGSize size = CGSizeMake(skView.bounds.size.width, skView.bounds.size.height);
    GameScene *scene = [[GameScene alloc]initWithSize:size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    // Present the scene.
    [skView presentScene:scene];
    [self.view addSubview:skView];
    
    
    //analog joystick
    _analogControl = [[AnalogControl alloc] initWithFrame:CGRectMake(padPadding, skView.frame.size.height-padPadding-padSide, padSide, padSide)];
    [self.view addSubview:_analogControl];
    //observer to the joystick to control the player
    [_analogControl addObserver:scene forKeyPath:@"relativePosition" options:NSKeyValueObservingOptionNew context:nil];
    
    //button to fire the beam
    _buttonControl = [[ButtonControl alloc] initWithFrame:CGRectMake(skView.frame.size.width-padPadding-padSide, skView.frame.size.height-padPadding-padSide, padSide, padSide)];
    [self.view addSubview:_buttonControl];
    //observer for the game to fire the beam
    [_buttonControl addObserver:scene forKeyPath:@"buttonPressed" options:NSKeyValueObservingOptionNew context:nil];
    
    //options control
    _optionControl = [[OptionsButton alloc]initWithFrame:CGRectMake(skView.frame.size.width-padPadding-(padSide/3), padPadding, padSide/3, padSide/3)];
    [self.view addSubview:_optionControl];
    //button to open options menu
    [_optionControl addObserver:self forKeyPath:@"optionsPressed" options:NSKeyValueObservingOptionNew context:nil];
    
    _scene = scene;
}

#pragma mark key-value-observers for controls
//observers for controls
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //did we want to open the options menu
    if([keyPath isEqualToString:@"optionsPressed"])
    {
        [self showOptions:YES];
    }
    //did we want to close the options menu
    if([keyPath isEqualToString:@"donePressed"])
    {
        [self showOptions:NO];
    }

}

-(void)showOptions:(BOOL)show
{
    NSLog(@"Toggle Options Menu");
    if(show)
    {
        [_optionControl setUserInteractionEnabled:NO];
        [_scene pauseGame];
        _options.hidden = NO;
        //_options.frame = CGRectMake(optionsXPosition, optionsOffYPosition, _options.frame.size.width , _options.frame.size.height);
        [UIView animateWithDuration:0.25f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _options.frame = CGRectMake(optionsXPosition, optionsOnYPosition+75, _options.frame.size.width , _options.frame.size.height);
                             
                         }
                         completion:^(BOOL finished) {
							 //NSLog(@"finished1");
                         }];
        [UIView animateWithDuration:0.35f
                              delay:0.25f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _options.frame = CGRectMake(optionsXPosition, optionsOnYPosition, _options.frame.size.width , _options.frame.size.height);
                             
                         }
                         completion:^(BOOL finished) {
                             //Taller iAd
                             //_iAd = [[ADBannerView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height, 320, 100)];
                             //_iAd.frame = CGRectOffset(_iAd.frame, -_iAd.frame.size.width/2, 0);
                             //Wider iAd
                             _iAd = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 100)];
                             _iAd.delegate = self;
							 //NSLog(@"finished2");
                         }];
        
        //flip page (for fun XD )
        /*_options.frame = CGRectMake(optionsXPosition, optionsOnYPosition, _options.frame.size.width , _options.frame.size.height);
        [UIView animateWithDuration:0.5f
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             //_options.frame = CGRectMake(optionsXPosition, optionsOnYPosition, _options.frame.size.width , _options.frame.size.height);
                             [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:_options cache:NO];
                             
                         }
                         completion:^(BOOL finished) {
                             
                         }];
        */
    }
    else
    {
        //clear iAd
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             _iAd.frame = CGRectOffset(_iAd.frame, 0, _iAd.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             // Assumes the banner view is placed at the bottom of the screen.
                             _iAd.frame = CGRectOffset(_iAd.frame, 0, _iAd.frame.size.height);
                             [_iAd removeFromSuperview];
                             _iAd.delegate = nil;
                             _iAd = nil;
                             _bannerIsVisible = NO;
                         }];
        
        
        //NOTE: Make sure to enable the _optionControl on completion, otherwise if pressed before completion the screen won't come back
        //clear options screen
        [UIView animateWithDuration:0.5f
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             _options.frame = CGRectMake(optionsXPosition, optionsOffYPosition, _options.frame.size.width , _options.frame.size.height);
                             
                         }
                         completion:^(BOOL finished) {
                             [_optionControl setUserInteractionEnabled:YES];
                             [_scene playGame];
                             _options.hidden = YES;
                         }];
        
        //flip page (for fun XD )
        /*[UIView animateWithDuration:0.5f
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:_options cache:NO];
                             _options.hidden = YES;
                             
                         }
                         completion:^(BOOL finished) {
                             _options.frame = CGRectMake(optionsXPosition, optionsOffYPosition, _options.frame.size.width , _options.frame.size.height);
                             _options.hidden = NO;
                             [_optionControl setUserInteractionEnabled:YES];
                             [_scene playGame];
                         }];
        */
        //[_optionControl setUserInteractionEnabled:YES];
        
    }
}


#pragma mark ADBannerView methods
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!_bannerIsVisible)
    {
        //move the options menu up a tad
        [UIView animateWithDuration:0.1f
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             //used if the tall iAd is used
                             //_options.frame = CGRectOffset(_options.frame, 0, -padPadding*1.5);
                             
                         }
                         completion:^(BOOL finished) {
                             
                         }];
        
        // If banner isn't part of view hierarchy, add it
        if (_iAd.superview == nil)
        {
            [self.view addSubview:_iAd];
        }
        
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        
        // Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        
        [UIView commitAnimations];
        
        _bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Failed to retrieve ad");
	
    if (_bannerIsVisible)
    {
        //move the options menu down a tad
        [UIView animateWithDuration:0.1f
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             //used if the tall iAd is used
                             //_options.frame = CGRectOffset(_options.frame, 0, padPadding*1.5);
                             
                         }
                         completion:^(BOOL finished) {

                         }];
        
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        
        // Assumes the banner view is placed at the bottom of the screen.
        _iAd.frame = CGRectOffset(_iAd.frame, 0, _iAd.frame.size.height);
        
        [UIView commitAnimations];
        
        _bannerIsVisible = NO;
    }
}

#pragma mark UIViewController methods
- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark Handle pauses
-(void)viewDidAppear:(BOOL)animated{
	//allows us to pause when the notification menu is opened
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	// Remove notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
	
	[super viewWillDisappear:animated];
}

- (void)appWillResignActive:(NSNotification *)notification
{
	// Handle notification
	if(_options.hidden)
	{
		NSLog(@"paused");
		[_scene pauseGame];
	}
}

- (void)appDidBecomeActive:(NSNotification *)notification
{
	// Handle notification
	if(_options.hidden)
	{
		NSLog(@"end pause");
		[_scene playGame];
	}
	else
	{
		[_scene pauseGame];
	}
}

//we need to remove the observers that were created so the scene could see the UI elements
-(void)dealloc
{
    if(_scene)
    {
        [_analogControl removeObserver:_scene forKeyPath:@"relativePosition"];
        [_buttonControl removeObserver:_scene forKeyPath:@"buttonPressed"];
        [_optionControl removeObserver:self forKeyPath:@"optionsPressed"];
        [_options removeObserver:_scene forKeyPath:@"sliderValue"];
        [_options removeObserver:self forKeyPath:@"donePressed"];
    }
}

@end
