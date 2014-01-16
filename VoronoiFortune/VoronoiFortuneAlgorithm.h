//
//  VoronoiFortuneAlgorithm.h
//  DrawBoard
//
//  Created by Mikko on 01/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoronoiCommon.h"
#import "VoronoiBeachline.h"
#import "EventQueue.h"
#import "VoronoiDiagram.h"
#import "VoronoiDefs.h"

@class VoronoiCircle;
@class ParabolicArc;
@class VoronoiSite;
@class VoronoiBeachLine;
@class VoronoiDiagram;

@interface VoronoiFortuneAlgorithm : NSObject {
@private
    EventQueue *_eventQueue;
    int _evQueueCircleCookie;
    NSMutableArray *_pastEvents;
    VoronoiBeachLine *_beachline;
    
    VoronoiCircle *_lastCircle1;
    VoronoiCircle *_lastCircle2;
    VDouble _lastScanline;
    VoronoiDiagram *_diagram;
}

@property (nonatomic, readonly) NSArray *futureEvents;
@property (nonatomic, readonly) int evQueueCicleCookie;

@property (nonatomic, readonly) NSMutableArray *pastEvents;
@property (nonatomic, readonly) VoronoiBeachLine *beachline;
@property (nonatomic, readonly) VoronoiCircle *circle1;
@property (nonatomic, readonly) VoronoiCircle *circle2;
@property (nonatomic, readonly) VDouble scanline;
@property (nonatomic, readonly) VoronoiDiagram *diagram;

- (void)voronoiForPoints:(NSArray *)points;
- (void)interactiveVoronoiForPoints:(NSArray *)points;
- (bool)nextEvent;
- (id <VoronoiEvent>)peekNextEvent;

@end
