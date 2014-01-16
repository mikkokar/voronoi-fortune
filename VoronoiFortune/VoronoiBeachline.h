//
//  VoronoiBeachline.h
//  DrawBoard
//
//  Created by Mikko on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoronoiSite.h"
#import "VoronoiCircle.h"
#import "VoronoiDiagram.h"
#import "VoronoiDefs.h"

@class VoronoiSite;
@class VoronoiCircle;


@interface ParabolaBreakpoint : NSObject {
@private
    VPoint _lastLocation;
    VDouble _lastX;
    id _edge;
    VoronoiVertex *_vertex;
}
@property (nonatomic, assign) VPoint location;
@property (nonatomic, assign) VDouble lastX;
@property (nonatomic, retain) VoronoiVertex *vertex;
@property (nonatomic, retain) id edge;
@end


@interface ParabolicArc : NSObject {
@private
    VoronoiSite *_site;
    VoronoiCircle *_circle;
    ParabolicArc *_next;
    ParabolicArc *_prev;
    ParabolaBreakpoint *_breakpoint;
}

@property (assign, nonatomic) VoronoiSite *site;
@property (assign, nonatomic) ParabolicArc *next;
@property (assign, nonatomic) ParabolicArc *prev;
@property (assign, nonatomic) VoronoiCircle *circle;
@property (assign, nonatomic) VDouble nextBreak;
@property (nonatomic, readonly) ParabolaBreakpoint *breakpoint;

- (ParabolicArc *)initWithSite:(VoronoiSite *)aSite;

@end


typedef struct BeachlineIterator {
    int currentIndex;
    VDouble domainLeft;
    VDouble domainRight;
    ParabolicArc *arc;
    VDouble scanline;
} BeachlineIterator_t;


@interface VoronoiBeachLine : NSObject {
@private
    NSMutableArray *arcList;
}
- (int)addNewSite:(VoronoiSite *)site oldArc:(ParabolicArc **)oldArc;
- (ParabolicArc *)siteAtIndex:(int)index;
- (int)count;
- (int)findSiteLocatedAbovePoint:(VPoint)newSite;
- (void)enumerateAtScanline:(VDouble)scanline 
                   iterator:(BeachlineIterator_t *)iterator;
- (int)enumerateNext:(BeachlineIterator_t *)iterator;
- (NSArray *)checkForTripleAtIndex:(int)index 
                       atDirection:(int)direction;
- (int)removeArc:(ParabolicArc *)arc;
- (void)debugPrintAtScanline:(VDouble)scanline;

- (VDouble)breakpointArcA:(ParabolicArc *)leftArc
                     arcB:(ParabolicArc *)rightArc
                 scanline:(VDouble)scanline;

- (NSArray *)arcsAsArray;

@end


