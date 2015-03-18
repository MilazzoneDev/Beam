//
//  ButtonControl.m
//  Beam
//
//  Created by Carl Milazzo on 10/3/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import "ButtonControl.h"

@implementation ButtonControl
{
    //UIImageView *_knobImageView;
    //CGPoint _baseCenter;
    UIImageView *_buttonImageView;
    BOOL held;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setUserInteractionEnabled:YES];
        
        _buttonImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _buttonImageView.contentMode = UIViewContentModeScaleAspectFit;
        _buttonImageView.image = [UIImage imageNamed:@"base"];
        [self addSubview:_buttonImageView];
        
    }
    return self;
}

-(void)updateButtonWithPosition:(CGPoint)position andContact:(BOOL)contact
{
    /*if(contact)
    {
        NSLog(@"button pressed");
        
    }
    else
    {
        NSLog(@"button released");
    }*/
    held = contact;
    self.buttonPressed = held;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    [self updateButtonWithPosition:touchLocation andContact:YES];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    [self updateButtonWithPosition:touchLocation andContact:YES];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updateButtonWithPosition:CGPointZero andContact:NO];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updateButtonWithPosition:CGPointZero andContact:NO];
}

@end
