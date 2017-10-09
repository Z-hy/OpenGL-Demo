//
//  ViewController.m
//  OpenGL-Demo
//
//  Created by user on 2017/9/6.
//  Copyright © 2017年 user. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLDrawView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet OpenGLDrawView *openGLView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
////    self.view.backgroundColor = [UIColor redColor];
//    
//    OpenGLDrawView *view = [[OpenGLDrawView alloc] init];
//    view.frame = self.view.bounds;
////    view.backgroundColor = [UIColor blueColor];
//    [self.view addSubview:view];
////    [view layoutSubviews];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
