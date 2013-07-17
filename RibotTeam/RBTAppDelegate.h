//
//  RBTAppDelegate.h
//  RibotTeam
//
//  Created by Manuel Marcos Regalado on 13/07/13.
//  Copyright (c) 2013 Manuel Marcos Regalado. All rights reserved.
//

#import <UIKit/UIKit.h>


//   LIST OF URLS
#define GetStudioInfoAPIServer @"http://theribots.nodejitsu.com/api/studio"
#define GetTeamInfoAPIServer @"http://theribots.nodejitsu.com/api/team"
#define GetRibotarAPIServer @"http://theribots.nodejitsu.com/api/team/%@/ribotar"
#define GetEmployeeInfoAPIServer @"http://theribots.nodejitsu.com/api/team/%@"


// LIST OF ERRORS

#define ErrorOperation @"Failure to download"
#define ErrorInternet @"No Internet Connection"
#define ErrorTwitterAccess @"You denied access to your Contacts. Please update your privacy settings"
#define ErrorTwitterInfo @"The user does not have twitter info"
#define ErrorTwitterApp @"You do not have Twitter App"


@interface RBTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) UISplitViewController *splitViewController;

@end
