//
//  ViewController.m
//  WWDC2014
//
//  Created by Jak Tiano on 4/4/14.
//  Copyright (c) 2014 Jak Tiano. All rights reserved.
//

#import "ViewController.h"
#import "JTAccelerometerSelectionView.h"
#import "JTAboutMeView.h"
#import "AppDelegate.h"

@interface ViewController ()

@property(nonatomic,weak)   UIView* currentInfoView;
@property(nonatomic,strong) JTAboutMeView* aboutMe;
@property(nonatomic,strong) JTAboutMeView* education;
@property(nonatomic,strong) JTAboutMeView* professional;
@property(nonatomic,strong) JTAboutMeView* programming;

@property(nonatomic,strong) JTAccelerometerSelectionView* selectionView;

@end

@implementation ViewController

// ---- View Controller Methods -----
-(void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1.0];
    
    self.selectionView = [[JTAccelerometerSelectionView alloc] initWithFrame:CGRectMake(0, 0, 192, 192)];
    self.selectionView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:self.selectionView];
    
    float headerHeight = self.selectionView.frame.size.height/2 + 160;
    float contentHeight = self.view.frame.size.height - headerHeight;
    
    self.currentInfoView = nil;
    self.aboutMe         = [[JTAboutMeView alloc] initWithFrame:CGRectMake(0, 0, 320, contentHeight)];
    self.education       = [[JTAboutMeView alloc] initWithFrame:CGRectMake(0, 0, contentHeight, 320)];
    self.professional    = [[JTAboutMeView alloc] initWithFrame:CGRectMake(0, 0, 320, contentHeight)];
    self.programming     = [[JTAboutMeView alloc] initWithFrame:CGRectMake(0, 0, contentHeight, 320)];
    
    [self.aboutMe loadFromFileForCategory:@"About Me"];
    [self.education loadFromFileForCategory:@"Education"];
    [self.professional loadFromFileForCategory:@"Professional"];
    [self.programming loadFromFileForCategory:@"Programming"];
    
    self.aboutMe.center      = CGPointMake(self.view.frame.size.width/2, headerHeight + (self.aboutMe.frame.size.height/2));
    self.education.center    = CGPointMake(self.view.frame.size.width/2, headerHeight + (self.aboutMe.frame.size.width/2));
    self.professional.center = CGPointMake(self.view.frame.size.width/2, headerHeight + (self.aboutMe.frame.size.height/2));
    self.programming.center  = CGPointMake(self.view.frame.size.width/2, headerHeight + (self.aboutMe.frame.size.width/2));
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientation:) name:@"JTOrientationChangedCCW0"    object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientation:) name:@"JTOrientationChangedCCW90"   object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientation:) name:@"JTOrientationChangedCCW180"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientation:) name:@"JTOrientationChangedCCW270"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientation:) name:@"JTOrientationChangedINVALID" object:nil];
    
    NSTimeInterval timeInt = 1.0/60.0;
    [NSTimer scheduledTimerWithTimeInterval:timeInt target:self selector:@selector(updateAccelerometer) userInfo:nil repeats:YES];
}
-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ------ Private Methods -------
-(void)updateAccelerometer {
    
    // read in and process accelerometer data
    double xData = [AppDelegate sharedMotionManager].accelerometerData.acceleration.x;
    double yData = [AppDelegate sharedMotionManager].accelerometerData.acceleration.y;
    double zData = [AppDelegate sharedMotionManager].accelerometerData.acceleration.z;

    float lerp = 0.2;
    
    float currentAngle = self.selectionView.rotation;
    if (currentAngle < 0) currentAngle += (M_PI * 2.0);
    float nextAngle = atan2f(yData, xData);
    if (nextAngle < 0) nextAngle += (M_PI * 2.0);
    
    float threshold = 0.985;
    if (zData > threshold || zData < -threshold) {
        // if the device is pretty flat, just leave it to minimize jitter
        self.selectionView.rotation = currentAngle;
        return;
    }
    
    float percent = 0;
    float offset = 0.55;
    float start = 0;
    
    if        (nextAngle >= 0            && nextAngle < M_PI/4) {
        
        percent = nextAngle / (M_PI/4);
        start = 0;
        
    } else if (nextAngle >= M_PI/4       && nextAngle < M_PI/2) {
        
        percent = ((M_PI/2) - nextAngle) / (M_PI/4);
        percent = -percent;
        start = M_PI/2;
        
    } else if (nextAngle >= M_PI/2       && nextAngle < (3*M_PI)/4) {
        
        percent = (nextAngle - (M_PI/2)) / (M_PI/4);
        start = M_PI/2;
        
    } else if (nextAngle >= (3*M_PI)/4   && nextAngle < M_PI) {
        
        percent = (M_PI - nextAngle) / (M_PI/4);
        percent = -percent;
        start = M_PI;
        
    } else if (nextAngle >= M_PI         && nextAngle < (5*M_PI)/4) {
        
        percent = (nextAngle - (M_PI)) / (M_PI/4);
        start = M_PI;
        
    } else if (nextAngle >= (5*M_PI)/4   && nextAngle < (3*M_PI)/2) {
        
        percent = (((3*M_PI)/2) - nextAngle) / (M_PI/4);
        percent = -percent;
        start = (3*M_PI)/2;
        
    } else if (nextAngle >= (3*M_PI)/2   && nextAngle < (7*M_PI)/4) {
        
        percent = (nextAngle - (3*M_PI/2)) / (M_PI/4);
        start = (3*M_PI)/2;
        
    } else if (nextAngle >= (7*M_PI)/4   && nextAngle < M_PI*2) {
        
        percent = ((2*M_PI) - nextAngle) / (M_PI/4);
        percent = -percent;
        start = 2*M_PI;
    }
    
    float otherPercent = 0;
    if (percent >=0) otherPercent = percent;
    else otherPercent = -percent;
    percent *= offset;
    nextAngle = start + ((percent*otherPercent)*(M_PI/4));
    
    float deltaAngle = (nextAngle - currentAngle);
    if (deltaAngle > M_PI) deltaAngle -= (M_PI * 2.0);
    if (deltaAngle < -M_PI) deltaAngle += (M_PI * 2.0);
    deltaAngle *= lerp;
    float newAngle = currentAngle + deltaAngle;
    
    self.selectionView.rotation = newAngle;
}
-(void)handleOrientation:(NSNotification*)notification {
    
    //NSLog(@"Received Notification: %@", notification.name);
    
    UIView* inView = nil;
    UIView* outView = self.currentInfoView;
    
    CGAffineTransform inRotation = CGAffineTransformIdentity;
    
    if ([notification.name isEqualToString:@"JTOrientationChangedCCW0"]) {
        inView = self.aboutMe;
    } else if ([notification.name isEqualToString:@"JTOrientationChangedCCW90"]) {
        inView = self.education;
        inRotation = CGAffineTransformMakeRotation(M_PI_2);
    } else if ([notification.name isEqualToString:@"JTOrientationChangedCCW180"]) {
        inView = self.professional;
        inRotation = CGAffineTransformMakeRotation(M_PI);
    } else if ([notification.name isEqualToString:@"JTOrientationChangedCCW270"]) {
        inView = self.programming;
        inRotation = CGAffineTransformMakeRotation(3*M_PI_2);
    }
    
    // if we are somehow going to display the same view, break
    if (inView == outView) return;
    
    // prepare in view to be animated
    inView.alpha = 0.0;
    [self.view addSubview:inView];
    
    // set scaling depending on which direction phone was turned
    CGAffineTransform outTarget;
    
    if ([self.selectionView getRotationDirection] == COUNTER_CLOCKWISE_ROTATION) {
        inView.transform = CGAffineTransformConcat(inRotation, CGAffineTransformMakeScale(0.1, 0.1));
        outTarget = CGAffineTransformConcat(outView.transform, CGAffineTransformMakeScale(5, 5));
    } else {
        inView.transform = CGAffineTransformConcat(inRotation, CGAffineTransformMakeScale(5, 5));
        outTarget = CGAffineTransformConcat(outView.transform, CGAffineTransformMakeScale(0.1, 0.1));
    }
    
    // make sure there are no stragglers
    if (self.aboutMe      != inView && self.aboutMe      != outView) [self.aboutMe removeFromSuperview];
    if (self.education    != inView && self.education    != outView) [self.education removeFromSuperview];
    if (self.professional != inView && self.professional != outView) [self.professional removeFromSuperview];
    if (self.programming  != inView && self.programming  != outView) [self.programming removeFromSuperview];
    
    // run animation
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         inView.transform = CGAffineTransformConcat(CGAffineTransformIdentity, inRotation);
                         inView.alpha = 1.0;
                         
                         outView.transform = outTarget;
                         outView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [outView removeFromSuperview];
                         self.currentInfoView = inView;
                     }];
}

@end
