//
//  RBTMasterViewController.m
//  RibotTeam
//
//  Created by Manuel Marcos Regalado on 13/07/13.
//  Copyright (c) 2013 Manuel Marcos Regalado. All rights reserved.
//

#import "RBTMasterViewController.h"
#import "RBTDetailViewController.h"
#import "Employee.h"
#import "UIImageView+WebCache.h"
#import "UIColor+UIColor_HexColor.h"
#import "UIImage+OverlayTintColor.h"
#import "Reachability.h"


@implementation RBTMasterViewController

@synthesize refreshControlView;
@synthesize poppingView;

#pragma mark - Life Cycle

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
      self.title = NSLocalizedString(@"Ribot", @"Ribot");
      //iPad development
      if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
         self.clearsSelectionOnViewWillAppear = NO;
         self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
      }
   }
   return self;
}

/* dealloc
 CALLED:This method is being called when the viewcontroller is being realeased
 IN: nothing
 OUT: void
 DO: Deallocates the memory occupied by the receiver.
 */
- (void)dealloc
{
   [poppingView release];
   [refreshControlView release];
   [_detailViewController release];
   [_fetchedResultsController release];
   [_managedObjectContext release];
   [super dealloc];
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

/* viewWillAppear
 CALLED:This method is being called when the view of the viewcontroller appears
 IN: animated--> Flag which tells you if it is animated or not
 OUT: void
 DO: We change the color of the navigation bar to be always the same because we might come back from another view which has diferent navigation bar color.
 */
-(void)viewWillAppear:(BOOL)animated{
   [super viewWillAppear:YES];
   //change the color of the navigation bar
   self.navigationController.navigationBar.tintColor=[UIColor colorWithHexValue:@"#00a8e0"];
   
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
   //set up the view with the different components that we have
   [self configureView];
   //call to the nsoperation to download the data
   [self getDataRequest];
}

#pragma mark - Configure Views

/* configureView
 CALLED:This method is being called when we need to change de UI and display content in the view. called from viewdidload
 IN: nothing
 OUT: void
 DO: set up the RefreshControl, create a info button on the top bar, set up the PoppingView with a gesture
 */
-(void)configureView{
   
   //set up refreshview
   refreshControlView = [[UIRefreshControl alloc]
                         init];
   //the method getDataRequest will get fired when we pull to refresh
   [refreshControlView addTarget:self action:@selector(getDataRequest) forControlEvents:UIControlEventValueChanged];
   self.refreshControl = refreshControlView;//assign the viewcontroller refreshcontrol with ours.
   
   DLog(@"Manu testing");
   
   //add info button
   UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
   //the method infoButtonAction will be fire when the user taps on top of the info button
   [infoButton addTarget:self action:@selector(infoButtonAction) forControlEvents:UIControlEventTouchUpInside];
   UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
   [self.navigationItem setRightBarButtonItem:modalButton animated:YES];
   [modalButton release];
   
   //set up poppyview for studio info 
   poppingView=[[RBTPoppingView alloc] init];
   //add gesture on top view. If the user taps on top of the view it will fire the method poppyViewHandleSingleTap
   UITapGestureRecognizer *singleFingerTap =
   [[UITapGestureRecognizer alloc] initWithTarget:self
                                           action:@selector(poppyViewHandleSingleTap:)];
   [poppingView addGestureRecognizer:singleFingerTap];
   [singleFingerTap release];
   //add an Imageview on top of the view which, is the dialog image
   UIImageView *popyImage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"poppyView.png"]];
   [poppingView addSubview:popyImage];
   [popyImage release];
   poppingView.frame=CGRectMake(20,0, popyImage.frame.size.width, popyImage.frame.size.height);
   [self.view addSubview:poppingView];// add the poppy view on top of the view
   poppingView.hidden=YES;// we hide it until the user taps on the infobutton
   
}

/* poppyViewHandleSingleTap
 CALLED:This method is being called when the user tap on top of the poppyview. We set it up with the gesture in the method configureView
 IN: recognizer--> it tells you where/which the user did tap
 OUT: void
 DO: hide the view with an animation
 */
- (void)poppyViewHandleSingleTap:(UITapGestureRecognizer *)recognizer {
   
   if(!poppingView.hidden) {
      //hide the view with animation
      [poppingView attachPopOutAnimation];
   } else {
      //this shouldn´t happen but just in case the user taps when the animation is happening, we will display the view again cos its the common behaviour
      [poppingView attachPopUpAnimation];
      
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

/* infoButtonAction
 CALLED:This method is being called when the user press the info button which, is on the top navigation bar
 IN: nothing
 OUT: void
 DO: we display or hide the view depending if it is being displayed already or not. If we need to display it we set up a new request/operation to get the info of the studio.
 */
-(void)infoButtonAction{
   
   if(!poppingView.hidden) {
      //hide the view with animation
      [poppingView attachPopOutAnimation];
   } else {
      //display de the view with animation
      [poppingView attachPopUpAnimation];
      //create a new request to get studio info
      NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:GetStudioInfoAPIServer]];
      //assign that request to an operation and we give it a TAGOperation cos we might have more than one in the queue and we need to differentiate them
      RBTDownloadOperation *op = [[RBTDownloadOperation alloc] initWithURLRequest:request andDelegate:self andTagOperation:@"info_studio"];
      [[NSOperationQueue mainQueue] addOperation:op];// add the operation to the queue
      [self setDownloadOperation:op]; //Hold onto a reference in case we want to cancel it
      [op release], op = nil;
      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];//show spinner on status bar
   }
}

/* getDataRequest
 CALLED:This method is being called when the user pull to refresh the table view
 IN: nothing
 OUT: void
 DO: It creates a new request/operation in order to get the team info data from the api
 */
-(void)getDataRequest{
   //create a new request to get team info
   NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:GetTeamInfoAPIServer]];
   //assign that request to an operation and we give it a TAGOperation cos we might have more than one in the queue and we need to differentiate them
   RBTDownloadOperation *op = [[RBTDownloadOperation alloc] initWithURLRequest:request andDelegate:self andTagOperation:@"info_team"];
   [[NSOperationQueue mainQueue] addOperation:op];// add the operation to the queue
   [self setDownloadOperation:op]; //Hold onto a reference in case we want to cancel it
   [op release], op = nil;
   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];//show spinner on status bar
   // we display the loader for the table view in order to let the user know that the data is being downloaded
   [refreshControlView beginRefreshing];
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
 DO: Change UI, Stop the refreshing on the UI
 */
- (void)operation:(RBTDownloadOperation*)operation didFailWithError:(NSError*)error;
{
   DLog(@"Failure to download: %@\n%@", [error localizedDescription], [error userInfo]);
   [self setDownloadOperation:nil];// release the reference of the operation
   //we have to be careful when we modify the UI cos we might be in a different thread
   if ([NSThread isMainThread]) {
      //we are in the mainthread
      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];//stop spinner status bar
      if(refreshControlView.refreshing){
         [refreshControlView endRefreshing];//stop refreshing
      }
      //display error
      if([self checkInternet]==TRUE){
         UIAlertView *alert;
         alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                            message:ErrorOperation
                                           delegate:self cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil];
         [alert show];
         [alert release];
      }else{
         UIAlertView *alert;
         alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                            message:ErrorInternet
                                           delegate:self cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil];
         [alert show];
         [alert release];
      }
      
   } else {
      dispatch_sync(dispatch_get_main_queue(), ^{
         // we are not in the main Thread so we have to dispatch it in the main queue when it is ready
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];//stop spinner status bar
         if(refreshControlView.refreshing){
            [refreshControlView endRefreshing];//stop refreshing
         }
         //display error
         if([self checkInternet]==TRUE){
            UIAlertView *alert;
            alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                               message:ErrorOperation
                                              delegate:self cancelButtonTitle:@"Ok"
                                     otherButtonTitles:nil];
            [alert show];
            [alert release];
         }else{
            UIAlertView *alert;
            alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                               message:ErrorInternet
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
   [self setDownloadOperation:nil];//release the reference of the operation
   //convert the data into a JSON format
   NSError *jsonError = nil;
   id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
   
   //check which operation it is. We will know depending on the TAG.
   if([operation.tagOperation isEqualToString:@"info_studio"]){
      DLog(@"Download complete for studio %@", jsonObject);
      //we have to be careful when we modify the UI cos we might be in a different thread
      if ([NSThread isMainThread]) {
         // we are in the main thread
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];//stop spinner status bar
         NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;//get the dictionary from the json object
         UILabel *labelPopy=[[UILabel alloc] initWithFrame:CGRectMake(30, 50, 200, 300)];
         labelPopy.numberOfLines=6;
         labelPopy.text=[NSString stringWithFormat:@"Studio Address: \r\n \r\n Ribot \r\n %@, %@ \r\n %@, %@ \r\n %@, %@", [jsonDictionary objectForKey:@"addressNumber"],[jsonDictionary objectForKey:@"street"],[jsonDictionary objectForKey:@"city"],[jsonDictionary objectForKey:@"postcode"],[jsonDictionary objectForKey:@"county"],[jsonDictionary objectForKey:@"country"]];
         labelPopy.backgroundColor=[UIColor clearColor];
         //add a label into the poppingview with the studio info
         [poppingView addSubview:labelPopy];
         [labelPopy release];
         
      } else {
         dispatch_sync(dispatch_get_main_queue(), ^{
            // we are not in the main Thread so we have to dispatch it in the main queue when it is ready
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];//stop spinner status bar
            NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;//get the dictionary from the json object
            UILabel *labelPopy=[[UILabel alloc] initWithFrame:CGRectMake(30, 50, 200, 300)];
            labelPopy.numberOfLines=6;
            labelPopy.text=[NSString stringWithFormat:@"Studio Address: \r\n \r\n Ribot \r\n %@, %@ \r\n %@, %@ \r\n %@, %@", [jsonDictionary objectForKey:@"addressNumber"],[jsonDictionary objectForKey:@"street"],[jsonDictionary objectForKey:@"city"],[jsonDictionary objectForKey:@"postcode"],[jsonDictionary objectForKey:@"county"],[jsonDictionary objectForKey:@"country"]];
            labelPopy.backgroundColor=[UIColor clearColor];
            //add a label into the poppingview with the studio info
            [poppingView addSubview:labelPopy];
            [labelPopy release];
         });
      }
   }
   
   
   //check which operation it is. We will know depending on the TAG.
   if([operation.tagOperation isEqualToString:@"info_team"]){
      DLog(@"Download complete");
      //1. Manage the data into whatever we want, Core Data, an array, whatever      
      //Note: We MIGHT be on a background thread here.
      if ([NSThread isMainThread]) {
         //we are on the main thread
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];//stop spinner status bar
         if(refreshControlView.refreshing){
            [refreshControlView endRefreshing];//stop refreshing
         }
         if ([jsonObject isKindOfClass:[NSArray class]]) {
            NSArray *jsonArray = (NSArray *)jsonObject;//convert json object into dictionary
            DLog(@"jsonArray - %@",jsonArray);
            for(NSDictionary *item in jsonArray) {
               NSError *error = nil;
               //we check if the Employee already exists
               BOOL check=[self validateEmployee:[item objectForKey:@"id"] error:error];
               if(check==TRUE){
                    DLog(@"UNIQUE %@",error);
                    [self insertNewObject:item];//insert the new employee
                  
               }else{
                     DLog(@"NOT UNIQUE %@",error);                  
               }
            }
            //2. Update the UITableViewDataSource with the new data
            //once we have finished introduccing the data we update the images and data
            [self.tableView reloadData];
         }
         else {
            NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
            DLog(@"jsonDictionary - %@",jsonDictionary);
         }
      } else {
         dispatch_sync(dispatch_get_main_queue(), ^{
            //we are in a different thread
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];//stop spinner status bar
            if(refreshControlView.refreshing){
               [refreshControlView endRefreshing];//stop refreshing
            }
            if ([jsonObject isKindOfClass:[NSArray class]]) {
               NSArray *jsonArray = (NSArray *)jsonObject;
               DLog(@"jsonArray - %@",jsonArray);
               for(NSDictionary *item in jsonArray) {
                  NSError *error = nil;
                  //we check if the Employee already exists
                  BOOL check=[self validateEmployee:[item objectForKey:@"id"] error:error];
                  if(check==TRUE){
                     DLog(@"UNIQUE %@",error);
                     [self insertNewObject:item];//insert the new employee
                     
                  }else{
                     DLog(@"NOT UNIQUE %@",error);                     
                  }
                  
               }
               //2. Update the UITableViewDataSource with the new data
               //once we have finished introduccing the data we update the images and data
               [self.tableView reloadData];
            }
            else {
               NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
               DLog(@"jsonDictionary - %@",jsonDictionary);
            }
         });
      }
   }
}

#pragma mark - Core Data

/* validateEmployee
 CALLED:This method is being called before we insert into the data base.
 IN: value--> the id of the employee; error--> description of the error
 OUT: boolean--> exists or not
 DO: Check if an employee already exists in the data base
 */
-(BOOL)validateEmployee:(NSString *) value error:(NSError *) error {
   
   // Validate uniqueness of id
   NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
   [fetch setEntity:[NSEntityDescription entityForName:@"Employee"
                                inManagedObjectContext:self.managedObjectContext]];
   NSPredicate *predicate = [NSPredicate
                             predicateWithFormat:@"id = %@",value];//we do a query checking for the id of employee
   fetch.predicate = predicate;
   NSUInteger count = [self.managedObjectContext
                       countForFetchRequest:fetch error:&error];
   if (count > 0) {
      // Produce error message...
      // Failed validation:
      return NO;
   }
   return YES;
}

/* insertNewObject
 CALLED:This method is being called when we want to insert a new employee in the data base
 IN: sender--> it is the data of the employee
 OUT: void
 DO: Insert a new employee in the data base
 */
- (void)insertNewObject:(id)sender
{
   NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
   NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
   //create a new Employee object
   Employee *employee = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
   
   //GET THE DICTIONARY
   NSDictionary *newEmployee=(NSDictionary *)sender;
   //check the keys and values.
   //Instead of going trough kyes of the JSON object we go trough the attributes of the managedobject so we check if there is a
   //value in the jsondictionary for that key. If there is, we store, if there is not, we set up a default value
   //This is how KVC(key value coding) helps us to have better consistency in our data base
   NSDictionary *attributes = [[employee entity] attributesByName];
   for (NSString *attribute in attributes) {
      id value;
      //we have to manage the description key specifically cos we CAN NOT have an attribute in our EMPLOYEE entity with the name
      //of "description" because it is a reserved word.
      if([attribute isEqualToString:@"descriptionEmployee"]){
         //we check if the description which is coming from the server is empty
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
         [employee setValue:[NSString stringWithFormat:@"No %@",attribute] forKey:attribute];
         continue;//we go to the next atttribute directly
      }
      [employee setValue:value forKey:attribute];
   }   
   // Save the context.
   NSError *error = nil;
   if (![context save:&error]) {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      DLog(@"Unresolved error %@, %@", error, [error userInfo]);
      //abort();
   }
}


#pragma mark - Table View

/* numberOfSectionsInTableView
 CALLED:This method is being called when we set up the table view
 IN: tableView--> reference of our table view
 OUT: NSInteger--> it tells us how many employees we have
 DO: it tells us how many employees we have
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return [[self.fetchedResultsController sections] count];
}

/* tableView  numberOfRowsInSection
 CALLED:This method is being called when we set up the table view
 IN: tableView--> reference of our table view
 OUT: NSInteger--> it tells us how many employees we have
 DO: it tells us how many employees we have
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
   return [sectionInfo numberOfObjects];
}

/* tableView  cellForRowAtIndexPath
 CALLED:This method is being called when we set up the table view
 IN: tableView--> reference of our table view; indexPath--> the index of the cell
 OUT: UITableViewCell--> it sends the cell view with format
 DO: it gives format to a cell of the table view, basically, Customize the appearance of table view cells
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *CellIdentifier = @"Cell";
   
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      //we set up UITableViewCellStyleSubtitle cos it will display the name and the role
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
      //check if it is an iPhone
      if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
         cell.textLabel.font=[ UIFont fontWithName: @"Helvetica-Bold" size: 16.0 ];//set the font of the title
         cell.detailTextLabel.font=[ UIFont fontWithName: @"Helvetica" size: 14.0 ];//set the font of the subtitle
      }
   }
   
   [self configureCell:cell atIndexPath:indexPath];// we add the content to the cell
   return cell;
}

/* tableView  canEditRowAtIndexPath
 CALLED:This method is being called when we want to edit the table view
 IN: tableView--> reference of our table view; indexPath--> the index of the cell
 OUT: Boolean--> Return NO if you do not want the specified item to be editable.
 DO: Edit the table view
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
   // Return NO if you do not want the specified item to be editable.
   return YES;
}

/* tableView  commitEditingStyle
 CALLED:This method is being called when we want to edit the table view
 IN: tableView--> reference of our table view; editingStyle--> the style of the cell; indexPath--> the index of the cell
 OUT: void
 DO: Edit the table view
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (editingStyle == UITableViewCellEditingStyleDelete) {
      NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
      [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
      
      NSError *error = nil;
      if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         DLog(@"Unresolved error %@, %@", error, [error userInfo]);
         //abort();
      }
   }
}

/* tableView  canMoveRowAtIndexPath
 CALLED:This method is being called when we want to change the order the table view
 IN: tableView--> reference of our table view; indexPath--> the index of the cell
 OUT: BOOL--> it tells us if it is orderable or not
 DO: Change order of the table view
 */
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
   // The table view should not be re-orderable.
   return NO;
}

/* tableView  didSelectRowAtIndexPath
 CALLED:This method is being called when we the user taps on a cell/employee
 IN: tableView--> reference of our table view; indexPath--> the index of the cell
 OUT: void
 DO: detects tap on cell/employee and it navigates to the next level down.(detai view)
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   //get the employee object
   Employee *employee = (Employee *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
   //check if it is an iPhone
   if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      if (!self.detailViewController) {
         //navigate
         self.detailViewController = [[[RBTDetailViewController alloc] initWithNibName:@"RBTDetailViewController_iPhone" bundle:nil] autorelease];
      }
      self.detailViewController.detailEmployee = employee;//pass the employee object to the next level
      [self.navigationController pushViewController:self.detailViewController animated:YES];
   } else {
      self.detailViewController.detailEmployee = employee;//pass the employee object to the next level
   }
}

/* configureCell  atIndexPath
 CALLED:This method is being called from "cellForRowAtIndexPath"
 IN: cell--> reference of our cell view; indexPath--> the index of the cell
 OUT: void
 DO: display content of employee in the cell
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
   
   Employee *employee = [self.fetchedResultsController objectAtIndexPath:indexPath];//get the employee object
   cell.textLabel.text = employee.firstName;
   cell.detailTextLabel.text=employee.role;
   cell.textLabel.textColor=[UIColor colorWithHexValue:employee.hexColor];//text with employee color
   cell.detailTextLabel.textColor=[UIColor colorWithHexValue:employee.hexColor];//text with employee color

   //creates a arrow with the color of the employee
   UIImageView *imageViewArrow=[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tableViewArrow"] overlayTintColor:[UIColor colorWithHexValue:employee.hexColor]]];
   imageViewArrow.frame=CGRectMake(0, 0, 30, 30);
   cell.accessoryView=imageViewArrow;
   [imageViewArrow release];
   
   //we download the web image using SDWebImage library and overlay the default image with our category
   NSString *urlPathAvatar=[NSString stringWithFormat:GetRibotarAPIServer,employee.id];   
   [cell.imageView setImageWithURL:[NSURL URLWithString:urlPathAvatar]
                  placeholderImage:[[UIImage imageNamed:@"defaultRibot"] overlayTintColor:[UIColor colorWithHexValue:employee.hexColor]] options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                     DLog(@"IMAGE DOWNLOADED");
                  }
    ];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
   if (_fetchedResultsController != nil) {
      return _fetchedResultsController;
   }
   
   NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
   // Edit the entity name as appropriate.
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:self.managedObjectContext];
   [fetchRequest setEntity:entity];
   
   // Set the batch size to a suitable number.
   [fetchRequest setFetchBatchSize:20];
   
   // Edit the sort key as appropriate.
   NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES] autorelease];
   NSArray *sortDescriptors = @[sortDescriptor];
   
   [fetchRequest setSortDescriptors:sortDescriptors];
   
   // Edit the section name key path and cache name if appropriate.
   // nil for section name key path means "no sections".
   NSFetchedResultsController *aFetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Ribot"] autorelease];
   aFetchedResultsController.delegate = self;
   self.fetchedResultsController = aFetchedResultsController;
   
   NSError *error = nil;
   if (![self.fetchedResultsController performFetch:&error]) {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      //abort();
   }
   
   return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
   [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
   switch(type) {
      case NSFetchedResultsChangeInsert:
         [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
         break;
         
      case NSFetchedResultsChangeDelete:
         [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
         break;
   }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
   UITableView *tableView = self.tableView;
   
   switch(type) {
      case NSFetchedResultsChangeInsert:
         [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
         break;
         
      case NSFetchedResultsChangeDelete:
         [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
         break;
         
      case NSFetchedResultsChangeUpdate:
         [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
         break;
         
      case NSFetchedResultsChangeMove:
         [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
         [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
         break;
   }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
   [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */



@end
