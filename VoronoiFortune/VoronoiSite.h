//
//  VoronoiSite.h
//  DrawBoard
//
//  Created by Mikko on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoronoiCommon.h"
#import "VoronoiBeachline.h"
#import "VoronoiDefs.h"

@class ParabolicArc;

@interface VoronoiSite : NSObject <VoronoiEvent> {
@private
    VPoint location;
    NSMutableArray *parabolicArcs;
}
// @property (nonatomic, readwrite, retain) ParabolicArc *arc;
@property (nonatomic, readonly) VPoint location;
- (VoronoiSite *)initWithLocation:(VPoint)siteLocation;
- (void)addParabolicArc:(ParabolicArc *)arc;
- (void)removeParabolicArc:(ParabolicArc *)arc;
@end
