//
//  VoronoiDiagram.h
//  DrawBoard
//
//  Created by Mikko on 05/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoronoiDefs.h"

@class VoronoiSite;
@class VoronoiVertex;

@interface VoronoiEdge : NSObject
@property (nonatomic, retain) VoronoiVertex *src_vertex;
@property (nonatomic, retain) VoronoiVertex *dst_vertex;
@property (nonatomic, assign) VoronoiEdge *next;
@property (nonatomic, assign) VoronoiEdge *other;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, retain) id data;

@end

@interface VoronoiVertex : NSObject
@property (nonatomic, assign) CGPoint location;
@property (nonatomic, assign) VoronoiEdge *edge;
@property (nonatomic, retain) id data;
@property (nonatomic, readonly) bool infinity;
@end


@interface VoronoiDiagram : NSObject {
@private
    NSMutableArray *_edges;
    NSMutableArray *_vertices;
}
@property (nonatomic, readonly) NSArray *edges;
@property (nonatomic, readonly) NSArray *vertices;
- (VoronoiEdge *)getNewEdge;
- (VoronoiVertex *)getNewVertex;
- (void)debugPrint;
@end
