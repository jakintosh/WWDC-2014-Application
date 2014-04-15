//
//  JTAboutMeView.h
//  WWDC2014
//
//  Created by Jak Tiano on 4/10/14.
//  Copyright (c) 2014 Jak Tiano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JTAboutMeView : UIView <UITextViewDelegate>

-(void)loadFromFileForCategory:(NSString*)category;

@end
