//
//  OptionsButton.h
//  Beam
//
//  Created by Carl Milazzo on 10/4/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionsButton : UIView

@property (nonatomic, assign) BOOL optionsPressed;

-(void)updateButtonWithPosition:(CGPoint)position andContact:(BOOL)contact;

@end
