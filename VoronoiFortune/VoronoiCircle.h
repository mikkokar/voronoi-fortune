//
//  VoronoiCircle.h
//  DrawBoard
//
//  Created by Mikko on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoronoiCommon.h"
#import "VoronoiSite.h"
#import "VoronoiBeachline.h"
#import "VoronoiDefs.h"

@class ParabolicArc;


@interface VoronoiCircle : NSObject <VoronoiEvent> {
@private
    VPoint _location; // Circle event location on beachline
    VDouble _radius;
    ParabolicArc *_arc;
    NSSet *_siteSet;
}
@property (nonatomic, readonly) VPoint center;
@property (nonatomic, readonly) VPoint location;
@property (nonatomic, readonly) VDouble radius;
@property (nonatomic, retain) ParabolicArc *arc;
@property (nonatomic, readonly) NSSet *sitesAsSet;

- (VoronoiCircle *)initWithCenter:(VPoint)centerPoint 
                        andRadius:(VDouble)radius;

- (void)falseAlarm;
@end


