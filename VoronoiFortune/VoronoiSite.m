//
//  VoronoiSite.m
//  DrawBoard
//
//  Created by Mikko on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VoronoiSite.h"

@implementation VoronoiSite

@synthesize location;
// @synthesize arc;

- (VoronoiSite *)initWithLocation:(VPoint)siteLocation
{
    self = [super init];
    if (self) {
        location = siteLocation;
        parabolicArcs = Nil;
        NSLog(@"VoronoiSite %p (%Lf, %Lf)", self, location.x, location.y);
    }
    return self;
}

- (NSMutableArray *)parabolicArcs
{
    if (parabolicArcs == Nil) {
        parabolicArcs = [[NSMutableArray alloc] init];
    }
    return parabolicArcs;
}

- (void)addParabolicArc:(ParabolicArc *)arc
{
    [self.parabolicArcs addObject:arc];
//    NSLog(@"VoronoiSite %p (%f, %f).addParabolicArc %p", 
//          self, location.x, location.y, arc);
}

- (void)removeParabolicArc:(ParabolicArc *)arc
{
    [self.parabolicArcs removeObject:arc];
//    NSLog(@"VoronoiSite %p (%f, %f).removeParabolicArc(%p)", 
//          self, location.x, location.y, arc);
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    // NSLog(@"Stack Trace: %@", [NSThread callStackSymbols]);
    [self.parabolicArcs release];
    [super dealloc];
}
//
//- (oneway void)release {
//    NSLog(@"%p VoronoiSite.release", self);
//    [super release];
//}
//
//- (id)retain {
//    NSLog(@"%p VoronoiSite.retain", self);
//    return [super retain];
//}
//
//- (id)autorelease {
//    NSLog(@"%p VoronoiSite.autorelease", self);
//    return [self autorelease];
//}

@end
