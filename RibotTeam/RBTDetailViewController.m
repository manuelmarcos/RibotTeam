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


@interface RBTDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation RBTDetailViewController

@synthesize profilePicture;
@synthesize activityImageView;


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

#pragma mark - Managing the detail item

- (void)setDetailEmployee:(id)newDetailItem
{
   if (_detailEmployee != newDetailItem) {
      [_detailEmployee release];
      _detailEmployee = [newDetailItem retain];
      
      // Update the view.
      [self configureView];
   }
}
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

-(void)setUpLocationMap:(NSString *)employeeLocation{
   CLGeocoder *geocoder = [[CLGeocoder alloc] init];
   
   
   [geocoder geocodeAddressString:employeeLocation completionHandler:^(NSArray *placemarks, NSError *error) {
      
      if(placemarks!=NULL){
         if ([NSThread isMainThread]) {
            //remove annotations from previous searches
            [self.mapView removeAnnotations:self.mapView.annotations];

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
               //remove annotations from previous searches
               [self.mapView removeAnnotations:self.mapView.annotations];

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
   
   
   //Set the duration of the animation (play with it
   //until it looks nice for you)
   activityImageView.animationDuration = 1.0;
   
   
   //Position the activity image view somewhere in
   //the middle of your current view
   activityImageView.frame = CGRectMake(
                                        self.view.frame.size.width/2
                                        -statusImage.size.width/2/2,
                                        self.view.frame.size.height/2
                                        -statusImage.size.height/2/2,
                                        statusImage.size.width/2,
                                        statusImage.size.height/2);
}

-(void)startLoader{
   //the call to this method has to be on the MAINTHREAD

   //Start the animation
   [activityImageView startAnimating];
   
   //Add your custom activity indicator to your current view
   [self.view addSubview:activityImageView];
}
-(void)stopLoader{
   //the call to this method has to be on the MAINTHREAD
   
   //Stop the animation
   [activityImageView stopAnimating];
   
   //remove your custom activity indicator from your current view
   [activityImageView removeFromSuperview];
}
- (void)configureView
{
   // Update the user interface for the detail item.
   if (self.detailEmployee) {
      self.title=[NSString stringWithFormat:@"%@ %@",self.detailEmployee.firstName,self.detailEmployee.lastName];
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
      self.navigationController.navigationBar.tintColor=[UIColor colorWithHexValue:self.detailEmployee.hexColor];
      //we overlay the default image with our category
      NSString *urlPathAvatar=[NSString stringWithFormat:@"http://theribots.nodejitsu.com/api/team/%@/ribotar",self.detailEmployee.id];
      
      [self.profilePicture setImageWithURL:[NSURL URLWithString:urlPathAvatar] placeholderImage:[[UIImage imageNamed:@"defaultRibot.png"] overlayTintColor:[UIColor colorWithHexValue:self.detailEmployee.hexColor]] options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
         DLog(@"IMAGE DOWNLOADED %@ IMAGE %f",error,image.size.width);
         
      }];
      
   }
}


-(void) viewWillAppear:(BOOL)animated{
   [super viewWillAppear:YES];
   
   NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://theribots.nodejitsu.com/api/team/%@",_detailEmployee.id]]];
   RBTDownloadOperation *op = [[RBTDownloadOperation alloc] initWithURLRequest:request andDelegate:self andTagOperation:@"info_team"];
   [[NSOperationQueue mainQueue] addOperation:op];
   [self setDownloadOperation:op]; //Hold onto a reference in case we want to cancel it
   [op release], op = nil;
   [self startLoader];


}
- (void)viewDidLoad
{
    [super viewDidLoad];
   UIBarButtonItem *actionButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                    target:self
                                    action:@selector(showActionSheet)];
   self.navigationItem.rightBarButtonItem = actionButton;
   [actionButton release];
   
   
   
   [self initLoader];

   
   // Do any additional setup after loading the view, typically from a nib.
   [self configureView];//download detail data for specific employee

}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) {
      self.title = NSLocalizedString(@"Detail", @"Detail");
   }
   return self;
}

-(void)showActionSheet{
   
   
   
   UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@",self.detailEmployee.firstName,self.detailEmployee.lastName]
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:@"Add to Contacts", @"Twitter", nil];
   
   // Show the sheet
   [actionSheet showInView:self.view];
   [actionSheet release];
}
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
   if(person==NULL){
      DLog(@"WHAT!! it didnt work");      
   }else{
      DLog(@"hola");
   }
   [newPersonViewController dismissViewControllerAnimated:YES completion:nil];
   
}
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

-(void)actionAddtoContacts{
   DLog(@"actionAddtoContacts");
   // Request authorization to Address Book
   ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
   
   if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
      ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
         // First time access has been granted, add the contact
         [self addContactToAddressBook];
         DLog(@"ohyeah");
      });
   }
   else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
      // The user has previously given access, add the contact
      [self addContactToAddressBook];
      DLog(@"ohyeah");
      
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

-(void)actionTwitter{
   DLog(@"actionTwitter");
   
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
   
   if (buttonIndex == [actionSheet cancelButtonIndex]) {
      return;
   }
   
   NSString *methodName = [@"action" stringByAppendingString:[[actionSheet buttonTitleAtIndex:buttonIndex]stringByReplacingOccurrencesOfString:@" " withString:@""]];
   SEL actionMethod = NSSelectorFromString(methodName);
   if ([self respondsToSelector:actionMethod]) {
      [self performSelector:actionMethod];
   } else {
      DLog(@"Not yet implemented %@",methodName);
   }
}



//this method is just in the case that we want to leave a reference to our operation in order to cancel it or do something with it
-(void)setDownloadOperation:(RBTDownloadOperation *)downloadOperationTo{
   
   _downloadOperation=downloadOperationTo;
   
}
- (void)operation:(RBTDownloadOperation*)operation didFailWithError:(NSError*)error;
{
   [self setDownloadOperation:nil];
   if ([NSThread isMainThread]) {
      [self configureView];
      [self stopLoader];
      
   } else {
      dispatch_sync(dispatch_get_main_queue(), ^{
         [self configureView];
         [self stopLoader];
      });
   }

   DLog(@"Failure to download: %@\n%@", [error localizedDescription], [error userInfo]);
}

- (void)operation:(RBTDownloadOperation*)operation didCompleteWithData:(NSData*)data;
{
   //1. Massage the data into whatever we want, Core Data, an array, whatever
   //we check if the nsoperation is the one that we need
   if([operation.tagOperation isEqualToString:@"info_team"]){
   
      [self setDownloadOperation:nil];
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
               //we set up a default value
               [_detailEmployee setValue:[NSString stringWithFormat:@"No %@",attribute] forKey:attribute];
               continue;//we go to the next atttribute directly
            }
            [_detailEmployee setValue:value forKey:attribute];
         }
      }
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
         [self configureView];
         [self stopLoader];
      } else {
         dispatch_sync(dispatch_get_main_queue(), ^{
            [self configureView];
            [self stopLoader];
            
         });
      }
   }
}




#pragma mark - Split view

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
