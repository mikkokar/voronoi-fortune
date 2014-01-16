//
//  VoronoiViewController.h
//  VoronoiFortune
//
//  Created by Mikko on 19/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoronoiFortuneAlgorithm.h"
#import "VoronoiViewController.h"
#import "VoronoiView.h"
#import "VoronoiDefs.h"

typedef enum {
    VORC_DIAGRAM_EMPTY,
    VORC_PLAYING,
    VORC_PAUSED,
    VORC_DIAGRAM_READY
} VoronoiViewControllerState;

@class VoronoiView;
@interface VoronoiViewController : UIViewController
{
    @private
    NSTimer *_timer;
}

@property (retain, nonatomic) VoronoiFortuneAlgorithm *algorithm;
@property (retain, nonatomic) NSSet *voronoiSites;
@property (readonly, nonatomic) VoronoiView *voronoiView;
@property (retain, nonatomic) id <VoronoiEvent> currentEvent;
@property (retain, nonatomic) id <VoronoiEvent> nextEvent;
@property (assign, nonatomic) VoronoiViewControllerState state;
@property (assign, nonatomic) VDouble scanline;
@end
