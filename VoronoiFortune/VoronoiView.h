//
//  VoronoiView.h
//  VoronoiFortune
//
//  Created by Mikko on 19/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoronoiViewController.h"

@class VoronoiViewController;

@interface VoronoiView : UIView
- (void)updateContent;
@property (retain, nonatomic)VoronoiViewController *controller;
@property (retain, nonatomic)VoronoiFortuneAlgorithm *algorithm;
@property (assign, nonatomic)bool showCircles;

@end
