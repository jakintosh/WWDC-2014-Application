//
//  JTAccelerometerSelectionView.h
//  WWDC2014
//
//  Created by Jak Tiano on 4/6/14.
//  Copyright (c) 2014 Jak Tiano. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CLOCKWISE_ROTATION = 0,
    COUNTER_CLOCKWISE_ROTATION = 1,
} JTRotationDirection;

@interface JTAccelerometerSelectionView : UIView

@property(nonatomic, getter = isEnabled) BOOL enabled;
@property(nonatomic) float rotation;

-(JTRotationDirection)getRotationDirection;

@end
