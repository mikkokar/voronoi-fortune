//
//  VoronoiDiagram.m
//  DrawBoard
//
//  Created by Mikko on 05/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VoronoiDiagram.h"

@implementation VoronoiEdge
@synthesize src_vertex;
@synthesize dst_vertex;
@synthesize next;
@synthesize other;
@synthesize point;
@synthesize data;

- (void)dealloc
{
    NSLog(@"%s", __func__);
    self.src_vertex = nil;
    self.dst_vertex = nil;
    self.next = nil;
    self.other = nil;
    self.data = nil;
    [super dealloc];
}
@end



@implementation VoronoiVertex
@synthesize location;
@synthesize edge;
@synthesize data;

- (VoronoiVertex *) init
{
    self = [super init];
    if (self) {
        self.location = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    self.edge = nil;
    self.data = nil;
    [super dealloc];
}

- (bool)infinity
{
    return (self.location.x == CGFLOAT_MAX);
}

@end



@implementation VoronoiDiagram

- (VoronoiDiagram *)init
{
    self = [super init];
    if (self) {
        _edges = [[NSMutableArray alloc] init];
        _vertices = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)edges
{
    return (NSArray *)_edges;
}

- (NSArray *)vertices
{
    return (NSArray *)_vertices;
}

- (void)debugPrint
{
    for (VoronoiVertex *vertex in self.vertices) {
        NSLog(@"V %p (%f, %f) -> E %p -> V %p",
              vertex, vertex.location.x, vertex.location.y,
              vertex.edge, vertex.edge.dst_vertex);
    }
}

- (VoronoiEdge *)getNewEdge
{
    VoronoiEdge *newEdge = [[VoronoiEdge alloc] init];
    NSLog(@"VoronoiEdge alloc %p", newEdge);
    [_edges addObject:newEdge];
    [newEdge release];
    return newEdge;
}

- (VoronoiVertex *)getNewVertex
{
    VoronoiVertex *newVertex = [[VoronoiVertex alloc] init];
    NSLog(@"VoronoiVertex alloc %p", newVertex);
    [_vertices addObject:newVertex];
    [newVertex release];
    return newVertex;
}

- (void)dealloc 
{
    NSLog(@"%s", __func__);
    for (VoronoiVertex *v in _vertices) {
        v.data = nil;
    }
    for (VoronoiEdge *e in _edges) {
        e.data = nil;
    }
    [_edges removeAllObjects];
    [_vertices removeAllObjects];
    [_edges release];
    [_vertices release];
    [super dealloc];
}

@end
