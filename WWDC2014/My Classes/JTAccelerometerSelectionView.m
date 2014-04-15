//
//  JTAccelerometerSelectionView.m
//  WWDC2014
//
//  Created by Jak Tiano on 4/6/14.
//  Copyright (c) 2014 Jak Tiano. All rights reserved.
//

#import "JTAccelerometerSelectionView.h"

#define TOUCH_RANGE 128.0
#define HIDDEN_SCALE 0.75
#define ANIMATION_SPEED 0.15
#define SELECTED_ALPHA 0.75

typedef enum : NSUInteger {
    INVALID_ORIENTATION = 0,
    CCW0,
    CCW90,
    CCW180,
    CCW270
} JTAccelerometerSelectionViewOrientation;

@interface JTAccelerometerSelectionView() {
    
    UIImage* _selectionOverlayImage;
    UIImage* _selectionArrowImage;
    
    UIImage* _wwdcIcon;
    UIImage* _meIcon;
    UIImage* _champIcon;
    UIImage* _nahcsIcon;
    UIImage* _wwdc13Icon;
}

@property(nonatomic) JTAccelerometerSelectionViewOrientation previousOrientation;
@property(nonatomic) JTAccelerometerSelectionViewOrientation currentOrientation;

@property(nonatomic,strong) UIImageView* currentIconBottom;
@property(nonatomic,strong) UIImageView* swapView;
@property(nonatomic,strong) UIImageView* selectionOverlay;
@property(nonatomic,strong) UIImageView* selectionArrow;
@property(nonatomic,strong) UIImageView* currentIconTop;

@end

@implementation JTAccelerometerSelectionView

// ------- Custom Getters and Setters ---------
-(void)setRotation:(float)rotation {
    _rotation = rotation;
    
    if (self.isEnabled) {
        
        // set the new orientation – -(void)setCurrentOrientation knows how to handle itself
        self.currentOrientation = [self getOrientation];
        
        // if the arrow is initialized, update its rotation
        if (self.selectionArrow) {
            self.selectionArrow.transform = CGAffineTransformMakeRotation( (-1.0 * _rotation) - M_PI_2 );
        }
    } else {
        if (self.currentIconTop) {
            //self.currentIconTop.transform = CGAffineTransformMakeRotation( (-1.0 * _rotation) - M_PI_2 );
        }
    }
}
-(void)setEnabled:(BOOL)enabled {
    if (_enabled != enabled) {
        if (enabled) {
            [self activate];
            //self.currentIconTop.transform = CGAffineTransformIdentity;
        }
        else [self deactivate];
    }
    _enabled = enabled;
}
-(void)setCurrentOrientation:(JTAccelerometerSelectionViewOrientation)currentOrientation {
    if (_currentOrientation != currentOrientation) {
        _previousOrientation = _currentOrientation;
        _currentOrientation = currentOrientation;
        
        [self notifyOrientationChange];
        
        self.swapView.image = [self getCurrentIconForOrientation:_currentOrientation];
        self.swapView.transform = [self getTransformForOrientation:_currentOrientation];
        [UIView animateWithDuration:ANIMATION_SPEED*2.0
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.swapView.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                             self.currentIconBottom.image = self.swapView.image;
                             self.currentIconBottom.transform = self.swapView.transform;
                             self.swapView.alpha = 0.0;
                         }
         ];
    }
}

// ------------- Public Methods ---------------
-(id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        _rotation = 0;
        _enabled = NO;
        
        _selectionOverlayImage = [UIImage imageNamed:@"Selection-Overlay"];
        _selectionArrowImage   = [UIImage imageNamed:@"Selection-Arrow"];
        
        _wwdcIcon   = [UIImage imageNamed:@"WWDC-icon"];
        _meIcon     = [UIImage imageNamed:@"Me-icon"];
        _champIcon  = [UIImage imageNamed:@"Champlain-icon"];
        _nahcsIcon  = [UIImage imageNamed:@"NAHCS-icon"];
        _wwdc13Icon = [UIImage imageNamed:@"WWDC-13-icon"];
        
        self.currentOrientation = INVALID_ORIENTATION;
        
        self.currentIconTop    = [[UIImageView alloc] initWithImage:_wwdcIcon];
        self.swapView          = [[UIImageView alloc] initWithImage:_wwdcIcon];
        self.currentIconBottom = [[UIImageView alloc] initWithImage:_wwdcIcon];
        self.selectionOverlay  = [[UIImageView alloc] initWithImage:_selectionOverlayImage];
        self.selectionArrow    = [[UIImageView alloc] initWithImage:_selectionArrowImage];
        
        self.currentIconTop.center    = self.center;
        self.swapView.center          = self.center;
        self.currentIconBottom.center = self.center;
        self.selectionOverlay.center  = self.center;
        self.selectionArrow.center    = self.center;
        
        self.swapView.alpha = 0.0;
        self.selectionArrow.alpha = 0.9;
        
        CGAffineTransform hiddenScaleTransform = CGAffineTransformMakeScale(HIDDEN_SCALE, HIDDEN_SCALE);
        self.selectionOverlay.transform = hiddenScaleTransform;
        self.selectionArrow.transform   = hiddenScaleTransform;
        
        [self addSubview:self.currentIconBottom];
        [self addSubview:self.swapView];
        [self addSubview:self.selectionOverlay];
        [self addSubview:self.selectionArrow];
        [self addSubview:self.currentIconTop];
    }
    return self;
}
-(JTRotationDirection)getRotationDirection{
    if (self.previousOrientation == INVALID_ORIENTATION) return COUNTER_CLOCKWISE_ROTATION;
    else if (self.currentOrientation == INVALID_ORIENTATION) return CLOCKWISE_ROTATION;
    else {
        NSUInteger prev = self.previousOrientation - 1;
        NSUInteger curr = self.currentOrientation - 1;
        
        if ((prev + 1)%4 == curr) return COUNTER_CLOCKWISE_ROTATION;
        else return CLOCKWISE_ROTATION;
    }
}

// ------------- Private Methods ---------------
-(void)activate {
    
    self.currentOrientation = [self getOrientation];

    [UIView animateWithDuration: ANIMATION_SPEED
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         self.center = CGPointMake(self.superview.frame.size.width/2, 160);
                         self.superview.backgroundColor = [UIColor whiteColor];
                     }
                     completion:nil];
    
    // if the screen is rotated, move it to that rotation first
    float rotationOffset = 0;
    if ( self.currentOrientation != CCW0) {
        rotationOffset = ANIMATION_SPEED*3;
        [UIView animateWithDuration: rotationOffset
                              delay: ANIMATION_SPEED
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^ {
                             self.currentIconTop.transform = [self getTransformForOrientation:self.currentOrientation];
                         }
                         completion:nil];
    }
    [UIView animateWithDuration: ANIMATION_SPEED
                          delay: rotationOffset + ANIMATION_SPEED
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^ {
                         CGAffineTransform fullScaleTransform = CGAffineTransformIdentity;
                         self.selectionOverlay.transform = fullScaleTransform;
                         self.selectionArrow.transform   = fullScaleTransform;
                     }
                     completion:nil];
    [UIView animateWithDuration: ANIMATION_SPEED
                          delay: rotationOffset + ANIMATION_SPEED/2.0 + ANIMATION_SPEED
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^ {
                         self.currentIconTop.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         self.currentIconTop.transform = CGAffineTransformIdentity;
                     }];
}
-(void)deactivate {
    
    BOOL shouldRotate = NO;
    
    if ( self.currentOrientation != CCW0) {
        shouldRotate = YES;
        self.currentIconTop.transform = [self getTransformForOrientation:self.currentOrientation];
    }
    
    self.currentOrientation = INVALID_ORIENTATION;
    
    [UIView animateWithDuration: ANIMATION_SPEED
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         self.currentIconTop.alpha = 1.0;
                     }
                     completion:nil];
    [UIView animateWithDuration: ANIMATION_SPEED
                          delay: ANIMATION_SPEED/2.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         CGAffineTransform hiddenScaleTransform = CGAffineTransformMakeScale(HIDDEN_SCALE, HIDDEN_SCALE);
                         self.selectionOverlay.transform = hiddenScaleTransform;
                         self.selectionArrow.transform   = hiddenScaleTransform;
                     }
                     completion:nil];
    
    float rotationOffset = 0;
    
    if (shouldRotate) {
        rotationOffset = ANIMATION_SPEED*3;
        [UIView animateWithDuration: rotationOffset
                              delay: ANIMATION_SPEED/2 + ANIMATION_SPEED
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^ {
                             self.currentIconTop.transform = CGAffineTransformIdentity;
                         }
                         completion:nil];
    }
    
    [UIView animateWithDuration: ANIMATION_SPEED
                          delay: ANIMATION_SPEED/2 + ANIMATION_SPEED + rotationOffset
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         self.center = CGPointMake(self.superview.frame.size.width/2, self.superview.frame.size.height/2);
                         self.superview.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1.0];
                     }
                     completion:nil];
}

-(JTAccelerometerSelectionViewOrientation)getOrientation {
    
    float adjustedRotation = self.rotation;
    while (adjustedRotation < 0) adjustedRotation += 2*M_PI;
    while (adjustedRotation > 2*M_PI) adjustedRotation -= 2*M_PI;
    
    if ( adjustedRotation >= 7*M_PI_4 || adjustedRotation < M_PI_4 ) {
        return CCW270;
    } else if ( adjustedRotation >= M_PI_4 && adjustedRotation < 3*M_PI_4 ) {
        return CCW180;
    } else if ( adjustedRotation >= 3*M_PI_4 && adjustedRotation < 5* M_PI_4 ) {
        return CCW90;
    } else if ( adjustedRotation >= 5*M_PI_4 && adjustedRotation < 7*M_PI_4 ) {
        return CCW0;
    }
    
    return INVALID_ORIENTATION;
}
-(UIImage*)getCurrentIconForOrientation:(JTAccelerometerSelectionViewOrientation)orientation {
    
    if ( orientation == CCW0 ) {
        return _meIcon;
    } else if ( orientation == CCW90 ) {
        return _champIcon;
    } else if ( orientation == CCW180 ) {
        return _nahcsIcon;
    } else if ( orientation == CCW270 ) {
        return _wwdc13Icon;
    }
    
    return _wwdcIcon;
}
-(CGAffineTransform)getTransformForOrientation:(JTAccelerometerSelectionViewOrientation)orientation {
    
    if ( orientation == CCW0 ) {
        return CGAffineTransformIdentity;
    } else if ( orientation == CCW90 ) {
        return CGAffineTransformMakeRotation(M_PI_2);
    } else if ( orientation == CCW180 ) {
        return CGAffineTransformMakeRotation(M_PI);
    } else if ( orientation == CCW270 ) {
        return CGAffineTransformMakeRotation(-M_PI_2);
    }
    
    return CGAffineTransformIdentity;
}

-(void)notifyOrientationChange {
    switch (self.currentOrientation) {
        case CCW0:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JTOrientationChangedCCW0" object:nil];
            break;
        case CCW90:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JTOrientationChangedCCW90" object:nil];
            break;
        case CCW180:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JTOrientationChangedCCW180" object:nil];
            break;
        case CCW270:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JTOrientationChangedCCW270" object:nil];
            break;
        case INVALID_ORIENTATION:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JTOrientationChangedINVALID" object:nil];
            break;
            
        default:
            break;
    }
}

// -------------- Touch Methods ----------------
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [UIView animateWithDuration: ANIMATION_SPEED
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^ {
                         CGAffineTransform inwardsTransform = CGAffineTransformMakeScale(0.95, 0.95);
                         self.transform = inwardsTransform;
                     }
                     completion:nil];
    self.alpha = SELECTED_ALPHA;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // if touch is too far away, give feedback
    UITouch* touch = [touches anyObject];
    if([self touchIsWithinRange:touch]) {
        self.alpha = SELECTED_ALPHA;
    } else self.alpha = 1.0;
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [UIView animateWithDuration: ANIMATION_SPEED
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^ {
                         CGAffineTransform inwardsTransform = CGAffineTransformIdentity;
                         self.transform = inwardsTransform;
                     }
                     completion:nil];
    
    self.alpha = 1.0;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // if the touch is within range when up, disable the view
    UITouch* touch = [touches anyObject];
    if([self touchIsWithinRange:touch]) [self setEnabled:!self.enabled];
    
    [UIView animateWithDuration: ANIMATION_SPEED
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^ {
                         CGAffineTransform inwardsTransform = CGAffineTransformIdentity;
                         self.transform = inwardsTransform;
                     }
                     completion:nil];
    
    self.alpha = 1.0;
}
-(BOOL)touchIsWithinRange:(UITouch*)touch {
    
    CGPoint location = [touch locationInView:self.superview];
    float xDist = location.x - self.center.x;
    float yDist = location.y - self.center.y;
    float distanceSquared = xDist*xDist + yDist*yDist;
    if(distanceSquared > (TOUCH_RANGE*TOUCH_RANGE)) {
        return NO;
    } else return YES;
}

@end
