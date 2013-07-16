//
//  RBTMasterViewController.h
//  RibotTeam
//
//  Created by Manuel Marcos Regalado on 13/07/13.
//  Copyright (c) 2013 Manuel Marcos Regalado. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

#import <Foundation/Foundation.h>

#import "RBTDownloadOperation.h"

#import "RBTPoppingView.h"

@class RBTDetailViewController;

@interface RBTMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate,RBTDownloadOperation>

@property (strong, nonatomic) RBTDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) UIRefreshControl *refreshControlView;
@property (nonatomic,retain)  RBTPoppingView *poppingView;

@property (strong, nonatomic) RBTDownloadOperation *downloadOperation;

-(void)configureView;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)setDownloadOperation:(RBTDownloadOperation *)downloadOperationTo;
@end
