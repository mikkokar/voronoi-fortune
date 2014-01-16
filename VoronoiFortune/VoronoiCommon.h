//
//  VoronoiCommon.h
//  DrawBoard
//
//  Created by Mikko on 01/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef DrawBoard_VoronoiCommon_h
#define DrawBoard_VoronoiCommon_h
#import "VoronoiDefs.h"

@protocol VoronoiEvent <NSObject>
- (VPoint)location;
@end

#endif
