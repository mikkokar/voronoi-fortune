//
//  VoronoiCircle.m
//  DrawBoard
//
//  Created by Mikko on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VoronoiCircle.h"
#import "VoronoiMath.h"

@implementation VoronoiCircle

@synthesize center;
@synthesize location = _location;
@synthesize radius = _radius;
@synthesize arc = _arc;


- (VoronoiCircle *)initWithCenter:(VPoint)centerPoint 
                        andRadius:(VDouble)radius
{
    self = [super init];
    if (self) {
        _radius = radius;
        _location.x = centerPoint.x;
        _location.y = centerPoint.y + radius;
        NSLog(@"VoronoiCircle %p (%f, %f)", self, 
              (double)_location.x, (double)_location.y);
    }
    return self;
}


- (VPoint)center
{
    VPoint _center = _location;
    _center.y -= _radius;
    return _center;
}


- (NSSet *)sitesAsSet
{
    if (_siteSet == nil) {
        VoronoiSite *site0 = self.arc.prev.site;
        VoronoiSite *site1 = self.arc.site;
        VoronoiSite *site2 = self.arc.next.site;
        _siteSet = [[NSSet alloc] 
                    initWithObjects:site0, site1, site2, nil];
    }
    return _siteSet;
}

- (void)unlinkArcs
{
    self.arc.circle = nil; // TODO: perhaps this shouldn't happen??
    self.arc = nil;
}

- (void)falseAlarm
{
    NSLog(@"VoronoiCircle %p (%Lf, %Lf).falseAlarm", self, _location.x, _location.y);
    [self unlinkArcs];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [self unlinkArcs];
    [_siteSet release];
    _siteSet = Nil;
    [super dealloc];
}

@end
