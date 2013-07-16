//
//  RBTAnnotationMap.m
//  RibotTeam
//
//  Created by Manuel Marcos Regalado on 15/07/13.
//  Copyright (c) 2013 Manuel Marcos Regalado. All rights reserved.
//

#import "RBTAnnotationMap.h"

@implementation RBTAnnotationMap
@synthesize coordinate;
- (id) initWithCoordinate:(CLLocationCoordinate2D)coord
{
   coordinate = coord;
   return self;
}
@end