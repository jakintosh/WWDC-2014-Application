//
//  JTAboutMeView.m
//  WWDC2014
//
//  Created by Jak Tiano on 4/10/14.
//  Copyright (c) 2014 Jak Tiano. All rights reserved.
//

#import "JTAboutMeView.h"

static NSString* const FILENAME = @"text-data";
static NSString* const FONT_NAME = @"HelveticaNeue-Light";
static const int TITLE_SIZE = 18;
static const int BODY_SIZE = 14;
static const int TEXT_INSETS = 35;

@interface JTAboutMeView() {
    
}

@property(nonatomic,strong) UILabel* titleLabel;
@property(nonatomic,strong) UITextView* bodyText;

@end

@implementation JTAboutMeView

// ------------- Public Methods ---------------
-(id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        // set up title label
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - (2*TEXT_INSETS), 20)];
        self.titleLabel.font = [UIFont fontWithName:FONT_NAME size:TITLE_SIZE];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.center = CGPointMake(160, TEXT_INSETS + self.titleLabel.frame.size.height/2);
        [self addSubview:self.titleLabel];
        
        // set up body text scroll view
        self.bodyText = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - (2*TEXT_INSETS) - 10,
                                                                     self.frame.size.height - (2*TEXT_INSETS) - 10 - self.titleLabel.frame.size.height)];
        self.bodyText.font = [UIFont fontWithName:FONT_NAME size:BODY_SIZE];
        self.bodyText.textAlignment = NSTextAlignmentLeft;
        self.bodyText.center = CGPointMake(self.frame.size.width/2, self.titleLabel.frame.size.height + (self.frame.size.height - self.titleLabel.frame.size.height)/2);
        self.bodyText.backgroundColor = [UIColor clearColor];
        self.bodyText.delegate = self;
        [self.bodyText setEditable:NO];
        [self addSubview:self.bodyText];
        
        // set up body text mask layer
        CAGradientLayer* maskLayer = [CAGradientLayer layer];
        maskLayer.locations = @[[NSNumber numberWithFloat:0.0],
                                [NSNumber numberWithFloat:0.2],
                                [NSNumber numberWithFloat:0.8],
                                [NSNumber numberWithFloat:1.0]];
        maskLayer.bounds = CGRectMake(0, 0, self.bodyText.frame.size.width, self.bodyText.frame.size.height);
        maskLayer.anchorPoint = CGPointZero;
        self.bodyText.layer.mask = maskLayer;
        [self scrollViewDidScroll:self.bodyText];
    }
    return self;
}
-(void)loadFromFileForCategory:(NSString*)category {
    NSDictionary* file = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:FILENAME ofType:@"plist"]] objectForKey:category];
    NSString* titleText = [file objectForKey:@"titleText"];
    NSString* bodyText = [file objectForKey:@"bodyText"];
    self.titleLabel.text = [titleText stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    self.bodyText.text = [bodyText stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
}

// --- ScrollViewDelegateMethods ----
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // This gradient implementation was done with the help ofa post by Aviel Gross on stackoverflow.com
    CGColorRef fadedColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
    CGColorRef solidColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
    NSArray* colors;
    
    if (scrollView.contentOffset.y + scrollView.contentInset.top <= 0) {
        colors = @[(__bridge id)solidColor, (__bridge id)solidColor,
                   (__bridge id)solidColor, (__bridge id)fadedColor];
    } else if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height) {
        colors = @[(__bridge id)fadedColor, (__bridge id)solidColor,
                   (__bridge id)solidColor, (__bridge id)solidColor];
    } else {
        colors = @[(__bridge id)fadedColor, (__bridge id)solidColor,
                   (__bridge id)solidColor, (__bridge id)fadedColor];
    }
    
    ((CAGradientLayer *)scrollView.layer.mask).colors = colors;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    scrollView.layer.mask.position = CGPointMake(0, scrollView.contentOffset.y);
    [CATransaction commit];
}

@end
