//
//  PointEditorViewController.h
//  VoronoiFortune
//
//  Created by Mikko on 16/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointEditorView.h"
@class PointEditorView;

@interface PointEditorViewController : UIViewController
{
    @private
    NSMutableSet *_pointSet;
    UITapGestureRecognizer *_tapRecognizer;
    PointEditorView *_pointEditorView;
}
@property (assign, nonatomic) IBOutlet PointEditorView *pointEditorView;
@property (retain, nonatomic) IBOutlet UITapGestureRecognizer *tapRecognizer;
@property (readonly, nonatomic)NSSet *pointSet;

@end
