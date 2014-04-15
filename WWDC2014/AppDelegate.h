//
//  AppDelegate.h
//  WWDC2014
//
//  Created by Jak Tiano on 4/4/14.
//  Copyright (c) 2014 Jak Tiano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(CMMotionManager*)sharedMotionManager;

@end
