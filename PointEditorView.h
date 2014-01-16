//
//  PointEditorView.h
//  VoronoiFortune
//
//  Created by Mikko on 16/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointEditorViewController.h"
#import "VoronoiGraphics.h"

@class PointEditorViewController;
@class VoronoiGraphics;

@interface PointEditorView : UIView
@property (nonatomic, retain)PointEditorViewController *controller;
- (void)newSiteAt:(CGPoint)point;
@end
