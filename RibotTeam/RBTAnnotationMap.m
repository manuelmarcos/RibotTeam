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

/*  initWithCoordinate
 CALLED:This method is being called when we create a new annotation point for the map
 IN: coord--> coordinates of the annotation to display
 OUT: id--> itself
 DO: It initilize a annotation point in the map
 */
- (id) initWithCoordinate:(CLLocationCoordinate2D)coord
{
   coordinate = coord;
   return self;
}
@end