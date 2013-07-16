//
//  RBTDetailViewController.h
//  RibotTeam
//
//  Created by Manuel Marcos Regalado on 13/07/13.
//  Copyright (c) 2013 Manuel Marcos Regalado. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

#import <AddressBook/AddressBook.h>

#import <Foundation/Foundation.h>

#import <MessageUI/MFMailComposeViewController.h>

#import <AddressBookUI/AddressBookUI.h>

#import "Employee.h"

#import "RBTDownloadOperation.h"


@interface RBTDetailViewController : UIViewController <UISplitViewControllerDelegate,RBTDownloadOperation,UIActionSheetDelegate,MFMailComposeViewControllerDelegate,ABNewPersonViewControllerDelegate>{
   
}

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) Employee *detailEmployee;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailNickNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailRoleLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailFavSeasonLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailFavSweetLabel;
@property (nonatomic, retain) IBOutlet UIImageView *profilePicture;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain)  UIImageView *activityImageView;
@property (strong, nonatomic) RBTDownloadOperation *downloadOperation;
-(void)setDownloadOperation:(RBTDownloadOperation *)downloadOperationTo;
- (void)initLoader;
-(void)startLoader;
-(void)stopLoader;
- (void)configureView;

@end

