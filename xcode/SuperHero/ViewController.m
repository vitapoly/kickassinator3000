//
//  ViewController.m
//  SuperHero
//
//  Created by Michael Wang on 8/23/14.
//  Copyright (c) 2014 blast buzz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.vcMain = [[VCMain alloc] initWithNibName:@"VCMain" bundle:Nil];
    [self.view addSubview:self.vcMain.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
