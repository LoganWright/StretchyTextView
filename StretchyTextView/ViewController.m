//
//  ViewController.m
//  StretchyTextView
//
//  Created by Logan Wright on 5/10/14.
//  Copyright (c) 2014 Logan Wright. All rights reserved.
//

#import "ViewController.h"

#import "UIStretchyTextView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor blackColor];
    UIStretchyTextView * stretchyTextView = [[UIStretchyTextView alloc]init];
    // stretchyTextView.layer.borderWidth = 2.5;
    // stretchyTextView.layer.cornerRadius = 15.0;
    stretchyTextView.layer.borderColor = [UIColor greenColor].CGColor;
    stretchyTextView.frame = CGRectMake(0, 20, 300, 100);
    stretchyTextView.font = [UIFont systemFontOfSize:42.0];
    stretchyTextView.text = @"SUP \nMan!?";
    [self.view addSubview:stretchyTextView];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
