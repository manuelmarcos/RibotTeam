//
//  Employee.h
//  RibotTeam
//
//  Created by Manuel Marcos Regalado on 16/07/13.
//  Copyright (c) 2013 Manuel Marcos Regalado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Employee : NSManagedObject

@property (nonatomic, retain) NSString * descriptionEmployee;
@property (nonatomic, retain) NSString * favSeason;
@property (nonatomic, retain) NSString * favSweet;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * hexColor;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * role;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSString * url;

@end
