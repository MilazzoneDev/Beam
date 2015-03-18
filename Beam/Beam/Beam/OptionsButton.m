//
//  OptionsButton.m
//  Beam
//
//  Created by Carl Milazzo on 10/4/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import "OptionsButton.h"

@implementation OptionsButton
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
        _buttonImageView.image = [UIImage imageNamed:@"OptionsButton"];
        [self addSubview:_buttonImageView];
        
    }
    return self;
}

-(void)updateButtonWithPosition:(CGPoint)position andContact:(BOOL)contact
{
    if(contact)
    {
        //NSLog(@"Options pressed");
        
    }
    else
    {
        //NSLog(@"button released");
    }
    held = contact;
    self.optionsPressed = held;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    [self updateButtonWithPosition:touchLocation andContact:YES];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
