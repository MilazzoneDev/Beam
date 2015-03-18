//
//  OptionsMenu.h
//  Beam
//
//  Created by Carl Milazzo on 10/4/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionsMenu : UIView

@property (nonatomic, assign) float sliderValue;
@property (nonatomic, assign) BOOL donePressed;

-(IBAction)SliderChanged:(id)sender;
-(IBAction)DonePressed:(id)sender;

@end
