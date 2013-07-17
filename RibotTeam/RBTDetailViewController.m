//
//  RBTDetailViewController.m
//  RibotTeam
//
//  Created by Manuel Marcos Regalado on 13/07/13.
//  Copyright (c) 2013 Manuel Marcos Regalado. All rights reserved.
//

#import "RBTDetailViewController.h"
#import "RBTAppDelegate.h"
#import "UIImageView+WebCache.h"
#import "UIColor+UIColor_HexColor.h"
#import "RBTAnnotationMap.h"
#import "UIImage+OverlayTintColor.h"
#import "Reachability.h"

@implementation RBTDetailViewController

@synthesize profilePicture;
@synthesize activityImageView;
@synthesize masterPopoverController;

#pragma mark - Life Cycle

/* dealloc
 CALLED:This method is being called when the viewcontroller is being realeased
 IN: nothing
 OUT: void
 DO: Deallocates the memory occupied by the receiver.
 */
- (void)dealloc
{
   [activityImageView release];
   [profilePicture release];
   [_detailEmployee release];
   [_detailDescriptionLabel release];
   [_detailNickNameLabel release];
   [_detailFavSeasonLabel release];
   [_detailFavSweetLabel release];
    [super dealloc];
}

/* viewWillAppear
 CALLED:This method is being called when the view of the viewcontroller appears
 IN: animated--> Flag which tells you if it is animated or not
 OUT: void
 DO: We create a operation in order to refresh the data of our data base. 
 */
-(void) viewWillAppear:(BOOL)animated{
   [super viewWillAppear:YES];
   
   //create a new request to get team info
   NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://theribots.nodejitsu.com/api/team/%@",_detailEmployee.id]]];
   //assign that request to an operation and we give it a TAGOperation cos we might have more than one in the queue and we need to differentiate them
   RBTDownloadOperation *op = [[RBTDownloadOperation alloc] initWithURLRequest:request andDelegate:self andTagOperation:@"info_team"];
   [[NSOperationQueue mainQueue] addOperation:op];// add the operation to the queue
   [self setDownloadOperation:op]; //Hold onto a reference in case we want to cancel it
   [op release], op = nil;
   [self startLoader];//we start the animation for the loader while we are requesting the data
   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];//start spinner status bar
}

/* viewDidLoad
 CALLED:This method is being called when the view has finished loading.
 IN: nothing
 OUT: void
 DO: we set up/configure our controller and view with the right data.
 */
- (void)viewDidLoad
{
   [super viewDidLoad];
   //set up an action button on the top navigation bar, the method showActionSheet will get fired when the user press it
   UIBarButtonItem *actionButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                    target:self
                                    action:@selector(showActionSheet)];
   self.navigationItem.rightBarButtonItem = actionButton;
   [actionButton release];
   
   [self initLoader];//we initialize the loader view
   
   [self configureView];//display detail data for specific employee
}

/* didReceiveMemoryWarning
 CALLED:This method is being called when the system has low memory
 IN: nothing
 OUT: void
 DO: Nothing at the moment, but we will use it because we need to test the application and check the levels of memory.
 */
- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}

/* initWithNibName
 CALLED:This method is being called when we init the ViewController.
 IN: nibNameOrNil--> The name of the view file nibBundleOrNil--> the bundle
 OUT: It returns self which, is the ViewController.
 DO: It inits the viewcontroller with the view
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) {
      self.title = NSLocalizedString(@"Detail", @"Detail");
   }
   return self;
}


#pragma mark - Configure Views

/* configureLabelView
 CALLED:This method is being called when we initialize the view from "configureView"
 IN: label--> a reference of the label to configure; textLabel--> the text to display
 OUT: void
 DO: It resize the font in order to fit all the text into the label
 */
-(void)configureLabelView:(UILabel *)label textLabelTo:(NSString *)textLabel{
   label.text=textLabel;
   
   label.adjustsFontSizeToFitWidth = NO;
   label.numberOfLines = 0;
   CGFloat fontSize = 16;
   while (fontSize > 0.0)
   {
      CGSize size = [textLabel sizeWithFont:[UIFont fontWithName:@"Helvetica" size:fontSize] constrainedToSize:CGSizeMake(label.frame.size.width, 10000) lineBreakMode:NSLineBreakByWordWrapping];
      
      if (size.height <= label.frame.size.height) break;
      
      fontSize -= 1.0;
   }
   
   label.font=[ UIFont fontWithName: @"Helvetica" size:fontSize];
   label.textColor=[UIColor colorWithHexValue:self.detailEmployee.hexColor];
}

/* initLoader
 CALLED:This method is being called from "viewDidLoad"
 IN: nothing
 OUT: void
 DO: It initilizes the loader
 */
- (void)initLoader{
   
   //Create the first status image and the indicator view
   UIImage *statusImage = [UIImage imageNamed:@"status1.png"];
   activityImageView = [[UIImageView alloc]
                        initWithImage:statusImage];
   //Add more images which will be used for the animation
   activityImageView.animationImages = [NSArray arrayWithObjects:
                                        [UIImage imageNamed:@"status1.png"],
                                        [UIImage imageNamed:@"status2.png"],
                                        [UIImage imageNamed:@"status3.png"],
                                        [UIImage imageNamed:@"status4.png"],
                                        [UIImage imageNamed:@"status5.png"],
                                        [UIImage imageNamed:@"status6.png"],
                                        [UIImage imageNamed:@"status7.png"],
                                        [UIImage imageNamed:@"status8.png"],
                                        nil];
   //Set the duration of the animation
   activityImageView.animationDuration = 1.0;
   //Position the activity image view somewhere in
   //the middle of our current view
   activityImageView.frame = CGRectMake(
                                        self.view.frame.size.width/2
                                        -statusImage.size.width/2/2,
                                        self.view.frame.size.height/2
                                        -statusImage.size.height/2/2,
                                        statusImage.size.width/2,
                                        statusImage.size.height/2);
}

/* startLoader
 CALLED:This method is being called when we want to start the animation of the loader
 IN: nothing
 OUT: void
 DO: It starts the animation
 */
-(void)startLoader{
   
   //Start the animation
   [activityImageView startAnimating];
   
   //Add your custom activity indicator to your current view
   [self.view addSubview:activityImageView];
}

/* stopLoader
 CALLED:This method is being called when we want to stop the animation of the loader
 IN: nothing
 OUT: void
 DO: It stops the animation
 */
-(void)stopLoader{
   
   //Stop the animation
   [activityImageView stopAnimating];
   
   //remove your custom activity indicator from your current view
   [activityImageView removeFromSuperview];
}

/* configureView
 CALLED:This method is being called from "viewDidLoad"
 IN: nothing
 OUT: void
 DO: It display the content of a specific employee into the view
 */
- (void)configureView
{
   // Update the user interface for the detail item.
   if (self.detailEmployee) {
      //change the color of the navigation bar
      self.navigationController.navigationBar.tintColor=[UIColor colorWithHexValue:self.detailEmployee.hexColor];
      //change the title in our navigation bar
      self.title=[NSString stringWithFormat:@"%@ %@",self.detailEmployee.firstName,self.detailEmployee.lastName];
      //we configure the each label
      [self configureLabelView:self.detailNickNameLabel textLabelTo:[NSString stringWithFormat:@"NickName: %@",self.detailEmployee.nickname]];
      [self configureLabelView:self.detailRoleLabel textLabelTo:[NSString stringWithFormat:@"Role: %@",self.detailEmployee.role]];
      [self configureLabelView:self.detailDescriptionLabel textLabelTo:self.detailEmployee.descriptionEmployee];
      [self configureLabelView:self.detailFavSeasonLabel textLabelTo:[NSString stringWithFormat:@"Fav Season: %@",self.detailEmployee.favSeason]];
      [self configureLabelView:self.detailFavSweetLabel textLabelTo:[NSString stringWithFormat:@"Fav Sweet: %@",self.detailEmployee.favSweet]];
      
      //set up the location but first we check if it has location or not
      if (![self.detailEmployee.location isEqualToString:@"No location"]) {
         // description is null or empty
         [self setUpLocationMap:self.detailEmployee.location];
      }else{
         //in the case that an employee does not have a location we set up one by default, for example Brighton
         [self setUpLocationMap:@"Brighton, UK"];
      }
      //we download the web image with the SDWebImage and overlay the default image with our category
      NSString *urlPathAvatar=[NSString stringWithFormat:@"http://theribots.nodejitsu.com/api/team/%@/ribotar",self.detailEmployee.id];      
      [self.profilePicture setImageWithURL:[NSURL URLWithString:urlPathAvatar] placeholderImage:[[UIImage imageNamed:@"defaultRibot.png"] overlayTintColor:[UIColor colorWithHexValue:self.detailEmployee.hexColor]] options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {         
      }];
   }
}
#pragma mark - Operations

/* checkInternet
 CALLED:This method is being called before we want to do any request
 IN: nothing
 OUT: BOOL--> yes if it is internet connection, no if it is not.
 DO: Checks internet connection
 */
-(BOOL)checkInternet{
   
   Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
   NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
   if (networkStatus == NotReachable) {
      DLog(@"There IS NO internet connection");
      return FALSE;
   } else {
      DLog(@"There IS internet connection");
      return TRUE;
   }
}


/* setDownloadOperation
 CALLED:This method is being called when set up a new operation
 IN: downloadOperationTo--> reference of the operation
 OUT: void
 DO: his method is just in the case that we want to leave a reference to our operation in order to cancel it or do something with it
 */
-(void)setDownloadOperation:(RBTDownloadOperation *)downloadOperationTo{
   
   _downloadOperation=downloadOperationTo;
   
}

/* operation didFailWithError
 CALLED:This method is being called when the operation fails
 IN: operation--> the reference of the operation; error--> description of the error
 OUT: void
 DO: Change UI, Stop the loader on the UI
 */
- (void)operation:(RBTDownloadOperation*)operation didFailWithError:(NSError*)error;
{
   DLog(@"Failure to download: %@\n%@", [error localizedDescription], [error userInfo]);
   [self setDownloadOperation:nil];
   if ([NSThread isMainThread]) {
      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];//stop spinner status bar
      [self configureView];//we configure the view again
      [self stopLoader];//stop the loader
      //display error
      if([self checkInternet]==TRUE){
         UIAlertView *alert;
         alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                            message:@"Failure to download"
                                           delegate:self cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil];
         [alert show];
         [alert release];
      }else{
         UIAlertView *alert;
         alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                            message:@"No Internet Connection"
                                           delegate:self cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil];
         [alert show];
         [alert release];
      }

      
   } else {
      dispatch_sync(dispatch_get_main_queue(), ^{
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];//stop spinner status bar
         [self configureView];//we configure the view again
         [self stopLoader];//stop the loader
         //display error
         if([self checkInternet]==TRUE){
            UIAlertView *alert;
            alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                               message:@"Failure to download"
                                              delegate:self cancelButtonTitle:@"Ok"
                                     otherButtonTitles:nil];
            [alert show];
            [alert release];
         }else{
            UIAlertView *alert;
            alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                               message:@"No Internet Connection"
                                              delegate:self cancelButtonTitle:@"Ok"
                                     otherButtonTitles:nil];
            [alert show];
            [alert release];
         }

      });
   }
}

/* operation didCompleteWithData
 CALLED:This method is being called when the operation complete with data
 IN: operation--> the reference of the operation; data--> data from the API
 OUT: void
 DO: Change UI and store core data;
 1. Massage the data into whatever we want, Core Data, an array, whatever
 2. Update the UITableViewDataSource with the new data
 */
- (void)operation:(RBTDownloadOperation*)operation didCompleteWithData:(NSData*)data;
{
   //1. Massage the data into whatever we want, Core Data, an array, whatever
   //we check if the nsoperation is the one that we need
   if([operation.tagOperation isEqualToString:@"info_team"]){
      
      [self setDownloadOperation:nil];//release the reference of our operation
      NSError *jsonError = nil;
      id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
      //    validation of the JSON object
      if ([jsonObject isKindOfClass:[NSArray class]]) {
         DLog(@"its an array!");// we shouldn't get an array from here
         // NSArray *jsonArray = (NSArray *)jsonObject;
      }
      else {
         DLog(@"its probably a dictionary");
         NSDictionary *newEmployee = (NSDictionary *)jsonObject;
         //check the keys and values.
         //Instead of going trough kyes of the JSON object we go trough the attributes of the managedobject so we check if there is a
         //value in the jsondictionary for that key. If there is, we store, if there is not, we set up a default value
         //This is how KVC(key value coding) helps us to have better consistency in our data base
         NSDictionary *attributes = [[_detailEmployee entity] attributesByName];
         for (NSString *attribute in attributes) {
            id value;
            //we have to manage the description key specifically cos we CAN NOT have an attribute in our EMPLOYEE entity with the name
            //of "description" because it is a reserved word.
            if([attribute isEqualToString:@"descriptionEmployee"]){
               if ([newEmployee objectForKey:@"description"] == [NSNull null] || [[newEmployee objectForKey:@"description"] length] <1 || ![[[newEmployee objectForKey:@"description"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
                  // description is null or empty
                  value = [NSString stringWithFormat:@"No %@",attribute];
               }else{
                  value = [newEmployee objectForKey:@"description"];
               }
            }
            else{
               value = [newEmployee objectForKey:attribute];               
            }
            if (value == nil) {
               // KVC (key value coding)- overridden to access generic dictionary storage
               //we set up a default value
               [_detailEmployee setValue:[NSString stringWithFormat:@"No %@",attribute] forKey:attribute];
               continue;//we go to the next atttribute directly
            }
            // KVC (key value coding)- overridden to access generic dictionary storage 
            [_detailEmployee setValue:value forKey:attribute];
         }
      }
      //save the context
      NSError *error;
      if (![_detailEmployee.managedObjectContext save:&error]) {
         /*
          Replace this implementation with code to handle the error appropriately.
          
          abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
          */
         DLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
      }
      //2. Update the UITableViewDataSource with the new data
      //Note: We MIGHT be on a background thread here.
      if ([NSThread isMainThread]) {
         //we are already in the main thread
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         [self configureView];
         [self stopLoader];
      } else {
         dispatch_sync(dispatch_get_main_queue(), ^{
            //we are in a different thread
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self configureView];
            [self stopLoader];
            
         });
      }
   }
}


#pragma mark - Core data

/* setDetailEmployee 
 CALLED:This method is being called by RBTMasterViewController inside the method "didSelectRowAtIndexPath"
 IN: newDetailItem--> the reference of employee object
 OUT: void
 DO: set up the employee object in our controller
 */
- (void)setDetailEmployee:(id)newDetailItem
{
   if (_detailEmployee != newDetailItem) {
      [_detailEmployee release];
      _detailEmployee = [newDetailItem retain];
      
      // Update the view.
      [self configureView];
   }
}

#pragma mark - Maps

/* setUpLocationMap
 CALLED:This method is being called from "configureView" 
 IN: employeeLocation--> the location of the employee
 OUT: void
 DO: search for the employee location and display it in a map
 */
-(void)setUpLocationMap:(NSString *)employeeLocation{
   CLGeocoder *geocoder = [[CLGeocoder alloc] init];
   //we search the coordinates of a given location
   [geocoder geocodeAddressString:employeeLocation completionHandler:^(NSArray *placemarks, NSError *error) {
      
      if(placemarks!=NULL){
         //Again, we need to check in which thread we are cos we are going to change the UI and we have to be sure we are in the MainThread
         if ([NSThread isMainThread]) {
            //we are in the Main thread
            //remove annotations from previous searches
            [self.mapView removeAnnotations:self.mapView.annotations];
            //get the first location of the array and display it in the map
            CLLocation *location=[[placemarks objectAtIndex:0] location];
            RBTAnnotationMap *annotation = [[[RBTAnnotationMap alloc] initWithCoordinate:location.coordinate] autorelease];
            MKCoordinateRegion region;
            MKCoordinateSpan span;
            span.latitudeDelta=0.2;
            span.longitudeDelta=0.2;
            region.span=span;
            region.center=location.coordinate;
            [self.mapView addAnnotation:annotation];
            [self.mapView setRegion:region animated:TRUE];
            [self.mapView regionThatFits:region];
            
         } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
               //we are NOT in the main thread
               //remove annotations from previous searches
               [self.mapView removeAnnotations:self.mapView.annotations];
               //get the first location of the array and display it in the map
               CLLocation *location=[[placemarks objectAtIndex:0] location];
               RBTAnnotationMap *annotation = [[[RBTAnnotationMap alloc] initWithCoordinate:location.coordinate] autorelease];
               MKCoordinateRegion region;
               MKCoordinateSpan span;
               span.latitudeDelta=0.2;
               span.longitudeDelta=0.2;
               region.span=span;
               region.center=location.coordinate;
               [self.mapView addAnnotation:annotation];
               [self.mapView setRegion:region animated:TRUE];
               [self.mapView regionThatFits:region];
            });
         }                  
      }
      
   }];   
   [geocoder release];
}


#pragma mark - Action Sheet 

/* showActionSheet
 CALLED:This method is being called when the user taps on the action button which is at the top navigation bar
 IN: nothing
 OUT: void
 DO: display an action sheet with a list of optionss
 */
-(void)showActionSheet{
   //create a new actionsheet
   UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@",self.detailEmployee.firstName,self.detailEmployee.lastName]
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:@"Add to Contacts", @"Twitter", nil];
   
   // Show the sheet
   [actionSheet showInView:self.view];
   [actionSheet release];
}

/* actionAddtoContacts
 CALLED:This method is being called from "didDismissWithButtonIndex"
 IN: nothing
 OUT: void
 DO: it checks if the user gives access to his contact list
 */
-(void)actionAddtoContacts{
   DLog(@"actionAddtoContacts");
   // Request authorization to Address Book
   ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
   
   if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
      ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
         // First time access has been granted, add the contact
         [self addContactToAddressBook];
      });
   }
   else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
      // The user has previously given access, add the contact
      [self addContactToAddressBook];
   }
   else {
      // The user has previously denied access
      // Send an alert telling user to change privacy setting in settings app
      // Handle the error
      UIAlertView *alert;
      
      alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                         message:@"You denied access to your Contacts. Please update your privacy settings"
                                        delegate:self cancelButtonTitle:@"Ok"
                               otherButtonTitles:nil];
      
      [alert show];
      [alert release];
      
   }
}

/* actionTwitter
 CALLED:This method is being called from "didDismissWithButtonIndex"
 IN: nothing
 OUT: void
 DO: it opens twitter app and navigates to the user profile
 */
-(void)actionTwitter{
   DLog(@"actionTwitter");
   if(![self.detailEmployee.twitter isEqualToString:@"No twitter"]){
      NSString *twitterUser=[NSString stringWithFormat:@"twitter://user?screen_name=%@",self.detailEmployee.twitter];
      if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]){
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitterUser]];
         
      }
      
   }else{
      UIAlertView *alert;
      
      alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                         message:@"The user does not have twitter info"
                                        delegate:self cancelButtonTitle:@"Ok"
                               otherButtonTitles:nil];
      
      [alert show];
      [alert release];
   }
}

/* actionSheet
 CALLED:This method is being called when the user taps on an option of the action sheet
 IN: actionSheet--> reference of the actionsheet; buttonIndex--> tells you which button has been pressed
 OUT: void
 DO: it generates a selector which, will get fired the appropiate method for each option
 */
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
   //cancel button
   if (buttonIndex == [actionSheet cancelButtonIndex]) {
      return;
   }
   //check which button has been pressed
   NSString *methodName = [@"action" stringByAppendingString:[[actionSheet buttonTitleAtIndex:buttonIndex]stringByReplacingOccurrencesOfString:@" " withString:@""]];//generate the name of the method
   SEL actionMethod = NSSelectorFromString(methodName);
   if ([self respondsToSelector:actionMethod]) {
      [self performSelector:actionMethod];//call the method
   } else {
      DLog(@"Not yet implemented %@",methodName);
   }
}

/* newPersonViewController
 CALLED:This method is being called when the user adds a new contact on his contact list
 IN: newPersonViewController--> reference of the controller ; person-->info of the contact
 OUT: void
 DO: tells you what the user has done with the contact
 */
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
   if(person==NULL){
      DLog(@"WHAT!! it didnt work");      
   }else{
      DLog(@"It did work");
   }
   [newPersonViewController dismissViewControllerAnimated:YES completion:nil];
   
}

/* addContactToAddressBook
 CALLED:This method is being called when the user wants to add a new contact on his contact list
 IN: nothing
 OUT: void
 DO: it creates a new contact with the ribotar of the employee, name and lastname and displays the view controller
 */
-(void)addContactToAddressBook{
   
   NSData * dataRef = UIImagePNGRepresentation(self.profilePicture.image);

   ABRecordRef newPerson= ABPersonCreate();
   CFErrorRef error = NULL;
   
   ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (CFStringRef)self.detailEmployee.firstName, &error);
   ABRecordSetValue(newPerson, kABPersonLastNameProperty, (CFStringRef)self.detailEmployee.lastName, &error);
   ABPersonSetImageData(newPerson, (CFDataRef)dataRef, nil);
   NSAssert(!error, @"something bad happend here.");
   
   
   ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
   picker.newPersonViewDelegate = self;
   [picker setDisplayedPerson:newPerson];

   
   UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
   [self presentViewController:navigation animated:YES completion:nil];
   [picker release];
   [navigation release];
   
   
   CFRelease(newPerson);


}

#pragma mark - Split view
//iPad implementation
- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Ribot", @"Ribot");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
