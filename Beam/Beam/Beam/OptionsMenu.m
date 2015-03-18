//
//  OptionsMenu.m
//  Beam
//
//  Created by Carl Milazzo on 10/4/14.
//  Copyright (c) 2014 Carl Milazzo. All rights reserved.
//

#import "OptionsMenu.h"

static float const padding = 10;

@implementation OptionsMenu


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        NSString *font = @"Academy Engraved LET";
        
        [self setUserInteractionEnabled:YES];
        //options title
        float titleWidth = self.bounds.size.width-padding*42;
        float titleHeight = 70;
        float titleX = padding*21;
        float titleY = padding*2;
        UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(titleX, titleY, titleWidth, titleHeight)];
        [title setText:[NSString stringWithFormat:@"Options"]];
        [title setTextAlignment:NSTextAlignmentCenter];
        [title setFont:[UIFont fontWithName:font size:50]];
        [self addSubview:title];
        
        //create a slider to change the hue of the beam
        float sliderWidth = self.bounds.size.width/2 - padding*2;
        float sliderHeight = self.bounds.size.height/8 - padding;
        float sliderX = padding*2;
        float sliderY = self.bounds.size.height/2 - sliderHeight/2;
        
        UISlider* slider = [[UISlider alloc] initWithFrame:CGRectMake(sliderX, sliderY, sliderWidth, sliderHeight)];
        [slider addTarget:self
                      action:@selector(SliderChanged:)
            forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:slider];
        
        //create a button to leave the options menu
        float doneWidth = self.bounds.size.width*3/16 - padding*2;
        float doneHeight = self.bounds.size.height/8 - padding;
        float doneX = self.bounds.size.width - doneWidth - padding*2;
        float doneY = self.bounds.size.height - doneHeight - padding*2;
        UIButton *done = [[UIButton alloc] initWithFrame:CGRectMake(doneX, doneY+padding/2, doneWidth, doneHeight)];
        //done.titleLabel.font = [UIFont fontWithName:font size:20];
        [done.titleLabel setFont:[UIFont fontWithName:font size:20]];
        [done.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [done setTitle:@"Done" forState:UIControlStateNormal];
        [done setTitle:@"Done" forState:UIControlStateHighlighted];
        [done setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [done addTarget:self action:@selector(DonePressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addGestureRecogniser:self];
        
        [self addSubview:done];
        
    }
    return self;
}

#pragma mark Interactive UI elements
-(IBAction)SliderChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    self.sliderValue = slider.value;
    //NSLog(@"slider value: %f",slider.value);
    [self setNeedsDisplayInRect:self.bounds];
}

-(IBAction)DonePressed:(id)sender
{
    //NSLog(@"done pressed");
    self.donePressed = YES;
}

-(void)addGestureRecogniser:(UIView *)touchView{
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(DonePressed:)];
    swipe.direction = UISwipeGestureRecognizerDirectionUp;
    [touchView addGestureRecognizer:swipe];
}


#pragma mark drawRect methods
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    //adds the background
    CGRect rectangle = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    CGContextRef _context = UIGraphicsGetCurrentContext();
    
    [self drawRoundedRect:_context rect:rectangle radius:10 color:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1]];
    
    //adds a boarder to the title
    float titleWidth = self.bounds.size.width-padding*42;
    float titleHeight = 70;
    float titleX = padding*21;
    float titleY = padding*2;
    CGRect titleRect = CGRectMake(titleX, titleY, titleWidth, titleHeight-10);
    CGRect biggerTitleRect = CGRectMake(titleRect.origin.x - padding, titleRect.origin.y-padding, titleRect.size.width+padding*2, titleRect.size.height+padding*2);
    [self drawRoundedRect:_context rect:biggerTitleRect radius:10 color:[UIColor grayColor]];
    [self drawRoundedRect:_context rect:titleRect radius:10 color:[UIColor whiteColor]];
    
    //add slider gradient
    float sliderWidth = self.bounds.size.width/2 - padding*2;
    float sliderHeight = self.bounds.size.height/8 - padding;
    float sliderX = padding*2;
    float sliderY = self.bounds.size.height/2 - sliderHeight/2;
    
    CGRect sliderSize = CGRectMake(sliderX, sliderY, sliderWidth, sliderHeight);
    
    //Add a color picker behind the slider to show the user more accurately what color they picked
    [self squareHueColor:sliderSize withContext:_context];
    
    //add a view to the current color picked
    float hueViewWidth = sliderHeight*2;
    float hueViewHeight = sliderHeight;
    float hueViewX = sliderX+sliderWidth+padding*3;
    float hueViewY = sliderY;
    CGRect hueViewBorder = CGRectMake(hueViewX-padding, hueViewY-padding, hueViewWidth+padding*2, hueViewHeight+padding*2);
    CGContextSetFillColorWithColor(_context, [[UIColor grayColor] CGColor]);
    [self drawRoundedRect:_context rect:hueViewBorder radius:10 color:[UIColor grayColor]];
    CGRect hueView = CGRectMake(hueViewX, hueViewY, hueViewWidth, hueViewHeight);
    CGContextSetFillColorWithColor(_context, [[UIColor colorWithHue:self.sliderValue saturation:1 brightness:1 alpha:1] CGColor]);
    CGContextFillRect(_context, hueView);
    
    //adds a boarder to the done button
    float doneWidth = self.bounds.size.width*3/16 - padding*2;
    float doneHeight = self.bounds.size.height/8 - padding;
    float doneX = self.bounds.size.width - doneWidth - padding*2;
    float doneY = self.bounds.size.height - doneHeight - padding*2;
    
    CGRect doneRect = CGRectMake(doneX, doneY, doneWidth, doneHeight);
    CGRect biggerDoneRect = CGRectMake(doneRect.origin.x - padding, doneRect.origin.y-padding, doneRect.size.width+padding*2, doneRect.size.height+padding*2);
    [self drawRoundedRect:_context rect:biggerDoneRect radius:10 color:[UIColor grayColor]];
    [self drawRoundedRect:_context rect:doneRect radius:10 color:[UIColor whiteColor]];
}

//makes the colors behind the slider appear as Squares (to pick color you have to line it up with the center of the slider
-(void)squareHueColor:(CGRect)sliderSize withContext:(CGContextRef)context
{
    float Xpos = sliderSize.origin.x;
    float Ypos = sliderSize.origin.y;
    float width = sliderSize.size.width;
    float height = sliderSize.size.height;
    
    //due to the shift we have extra to draw at the end and begining (we'll just make it red)
    //this one adds circles
    CGContextSetFillColorWithColor(context, [[UIColor colorWithHue:1 saturation:1 brightness:1 alpha:1] CGColor]);
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithHue:1 saturation:1 brightness:1 alpha:1] CGColor]);
    //begining rect
    CGRect BeginingFill = CGRectMake(Xpos, Ypos, height, height);
    CGContextFillEllipseInRect(context, BeginingFill);
    //ending rect
    CGRect EndFill = CGRectMake(Xpos + (width - height), Ypos, height, height);
    CGContextFillEllipseInRect(context, EndFill);
    
    
    //number of shades to go through
    float numCircles = 100;
    for(int x=0; x < numCircles; x++)
    {
        //hue of the area to draw
        float Hue = (x/numCircles);
        //draw the circle at
        //X: slider's x + the position the color should be at + the slider hight/2(so the center of the slider will be the color you picked)
        //Y: slider's y
        //Width: width of the fragment in the color wheel (based on how many samples we are taking
            //method 1: the height of the slider (smoother look but has some over draw at the end)
                //height
            //method 2: the exact section of the sample (segmented look)
                //(width-height)/numCircles
        //Height: height of the slider
        CGRect squarePos = CGRectMake(Xpos + ((x/numCircles)*(width-height))+height/2, Ypos, (width-height)/numCircles, height);
        CGContextSetFillColorWithColor(context, [[UIColor colorWithHue:Hue saturation:1 brightness:1 alpha:1] CGColor]);
        CGContextSetStrokeColorWithColor(context, [[UIColor colorWithHue:Hue saturation:1 brightness:1 alpha:1] CGColor]);
        //draws a circle
        //CGContextFillEllipseInRect(context, squarePos);//looks kind of cool XD
        //draws a square
        CGContextFillRect(context, squarePos);
    }
}

- (void) drawRoundedRect:(CGContextRef)c rect:(CGRect)rect radius:(int)corner_radius color:(UIColor *)color
{
    int x_left = rect.origin.x;
    int x_left_center = rect.origin.x + corner_radius;
    int x_right_center = rect.origin.x + rect.size.width - corner_radius;
    int x_right = rect.origin.x + rect.size.width;
    
    int y_top = rect.origin.y;
    int y_top_center = rect.origin.y + corner_radius;
    int y_bottom_center = rect.origin.y + rect.size.height - corner_radius;
    int y_bottom = rect.origin.y + rect.size.height;
    
    //Begin!
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, x_left, y_top_center);
    
    //First corner
    CGContextAddArcToPoint(c, x_left, y_top, x_left_center, y_top, corner_radius);
    CGContextAddLineToPoint(c, x_right_center, y_top);
    
    //Second corner
    CGContextAddArcToPoint(c, x_right, y_top, x_right, y_top_center, corner_radius);
    CGContextAddLineToPoint(c, x_right, y_bottom_center);
    
    //Third corner
    CGContextAddArcToPoint(c, x_right, y_bottom, x_right_center, y_bottom, corner_radius);
    CGContextAddLineToPoint(c, x_left_center, y_bottom);
    
    //Fourth corner
    CGContextAddArcToPoint(c, x_left, y_bottom, x_left, y_bottom_center, corner_radius);
    CGContextAddLineToPoint(c, x_left, y_top_center);
    
    //Done
    CGContextClosePath(c);
    
    CGContextSetFillColorWithColor(c, color.CGColor);
    
    CGContextFillPath(c);
}

@end
