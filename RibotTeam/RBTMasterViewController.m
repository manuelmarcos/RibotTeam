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



@implementation RBTMasterViewController

@synthesize refreshControlView;
@synthesize poppingView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Ribot", @"Ribot");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
    }
    return self;
}
							
- (void)dealloc
{
    [poppingView release];
    [refreshControlView release];
    [_detailViewController release];
    [_fetchedResultsController release];
    [_managedObjectContext release];
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated{
   [super viewWillAppear:YES];
   self.navigationController.navigationBar.tintColor=[UIColor colorWithHexValue:@"#00a8e0"];
   
}

-(void)configureView{
   
   //set up refreshview
   refreshControlView = [[UIRefreshControl alloc]
                         init];
   [refreshControlView addTarget:self action:@selector(getDataRequest) forControlEvents:UIControlEventValueChanged];
   self.refreshControl = refreshControlView;
   

   //add info button
   UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
   [infoButton addTarget:self action:@selector(infoButtonAction) forControlEvents:UIControlEventTouchUpInside];
   UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
   [self.navigationItem setRightBarButtonItem:modalButton animated:YES];
   [modalButton release];

   //add poppyview for info studio
   poppingView=[[RBTPoppingView alloc] init];
   //add gesture on top view
   UITapGestureRecognizer *singleFingerTap =
   [[UITapGestureRecognizer alloc] initWithTarget:self
                                           action:@selector(poppyViewHandleSingleTap:)];
   [poppingView addGestureRecognizer:singleFingerTap];
   [singleFingerTap release];
   
   UIImageView *popyImage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"poppyView.png"]];
   [poppingView addSubview:popyImage];  
   [popyImage release];
   poppingView.frame=CGRectMake(20,0, popyImage.frame.size.width, popyImage.frame.size.height);
   [self.view addSubview:poppingView];
   poppingView.hidden=YES;

}
- (void)poppyViewHandleSingleTap:(UITapGestureRecognizer *)recognizer {

   if(!poppingView.hidden) {
      [poppingView attachPopOutAnimation];
      
   } else {
      [poppingView attachPopUpAnimation];
   
   }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
   //set up the view with the different components that we have
   [self configureView];
   //call to the nsoperation to download the data
   [self getDataRequest];

}

-(void)infoButtonAction{
   
   if(!poppingView.hidden) {
      [poppingView attachPopOutAnimation];
      
   } else {
      [poppingView attachPopUpAnimation];
      NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://theribots.nodejitsu.com/api/studio"]];
      RBTDownloadOperation *op = [[RBTDownloadOperation alloc] initWithURLRequest:request andDelegate:self andTagOperation:@"info_studio"];
      
      [[NSOperationQueue mainQueue] addOperation:op];
      [self setDownloadOperation:op]; //Hold onto a reference in case we want to cancel it
      [op release], op = nil;
      
   }
}
-(void)getDataRequest{
   
   
   NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://theribots.nodejitsu.com/api/team"]];
   RBTDownloadOperation *op = [[RBTDownloadOperation alloc] initWithURLRequest:request andDelegate:self andTagOperation:@"info_team"];
   [[NSOperationQueue mainQueue] addOperation:op];
   [self setDownloadOperation:op]; //Hold onto a reference in case we want to cancel it
   [op release], op = nil;
   // we display the loader for the table view in order to let the user know that the data is being downloaded
   [refreshControlView beginRefreshing];
   
}

//this method is just in the case that we want to leave a reference to our operation in order to cancel it or do something with it
-(void)setDownloadOperation:(RBTDownloadOperation *)downloadOperationTo{
   
   _downloadOperation=downloadOperationTo;
   
}
- (void)operation:(RBTDownloadOperation*)operation didFailWithError:(NSError*)error;
{
   [self setDownloadOperation:nil];
   if([operation.tagOperation isEqualToString:@"info_studio"]){
      DLog(@"Download complete for studio");
      
   }
   if([operation.tagOperation isEqualToString:@"info_team"]){
      if ([NSThread isMainThread]) {
         if(refreshControlView.refreshing){
            [refreshControlView endRefreshing];//stop refreshing
         }
      } else {
         dispatch_sync(dispatch_get_main_queue(), ^{
            if(refreshControlView.refreshing){
               [refreshControlView endRefreshing];//stop refreshing
            }
         });
      }
   }

   DLog(@"Failure to download: %@\n%@", [error localizedDescription], [error userInfo]);
}

- (void)operation:(RBTDownloadOperation*)operation didCompleteWithData:(NSData*)data;
{
   [self setDownloadOperation:nil];
   NSError *jsonError = nil;
   id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];

   if([operation.tagOperation isEqualToString:@"info_studio"]){
      DLog(@"Download complete for studio %@", jsonObject);
      if ([NSThread isMainThread]) {
         NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
         UILabel *labelPopy=[[UILabel alloc] initWithFrame:CGRectMake(30, 50, 200, 300)];
         labelPopy.numberOfLines=6;
         labelPopy.text=[NSString stringWithFormat:@"Studio Address: \r\n \r\n Ribot \r\n %@, %@ \r\n %@, %@ \r\n %@, %@", [jsonDictionary objectForKey:@"addressNumber"],[jsonDictionary objectForKey:@"street"],[jsonDictionary objectForKey:@"city"],[jsonDictionary objectForKey:@"postcode"],[jsonDictionary objectForKey:@"county"],[jsonDictionary objectForKey:@"country"]];
         labelPopy.backgroundColor=[UIColor clearColor];
         [poppingView addSubview:labelPopy];
         [labelPopy release];

      } else {
         dispatch_sync(dispatch_get_main_queue(), ^{
            NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
            UILabel *labelPopy=[[UILabel alloc] initWithFrame:CGRectMake(30, 50, 200, 300)];
            labelPopy.numberOfLines=6;
            labelPopy.text=[NSString stringWithFormat:@"Studio Address: \r\n \r\n Ribot \r\n %@, %@ \r\n %@, %@ \r\n %@, %@", [jsonDictionary objectForKey:@"addressNumber"],[jsonDictionary objectForKey:@"street"],[jsonDictionary objectForKey:@"city"],[jsonDictionary objectForKey:@"postcode"],[jsonDictionary objectForKey:@"county"],[jsonDictionary objectForKey:@"country"]];
            labelPopy.backgroundColor=[UIColor clearColor];
            [poppingView addSubview:labelPopy];
            [labelPopy release];


         });
      }
   }
   if([operation.tagOperation isEqualToString:@"info_team"]){
   
      DLog(@"Download complete");
            
      //1. Massage the data into whatever we want, Core Data, an array, whatever
      
      //Note: We MIGHT be on a background thread here.
      if ([NSThread isMainThread]) {
         if(refreshControlView.refreshing){
            [refreshControlView endRefreshing];//stop refreshing
         }
         if ([jsonObject isKindOfClass:[NSArray class]]) {
            DLog(@"its an array!");
            NSArray *jsonArray = (NSArray *)jsonObject;
            DLog(@"jsonArray - %@",jsonArray);
            for(NSDictionary *item in jsonArray) {
               NSError *error = nil;
               BOOL check=[self validateEmployee:[item objectForKey:@"id"] error:error];
               if(check==TRUE){
                 //  DLog(@"UNIQUE %@",error);
                  [self insertNewObject:item];
                  
               }else{
                  // DLog(@"NOT UNIQUE %@",error);
                  
               }
               
            }
            //2. Update the UITableViewDataSource with the new data
            //once we have finished introduccing the data we update the images and data
            [self.tableView reloadData];
         }
         else {
            DLog(@"its probably a dictionary");
            NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
            DLog(@"jsonDictionary - %@",jsonDictionary);
         }
      } else {
         dispatch_sync(dispatch_get_main_queue(), ^{
            if(refreshControlView.refreshing){
               [refreshControlView endRefreshing];//stop refreshing
            }
            if ([jsonObject isKindOfClass:[NSArray class]]) {
               NSArray *jsonArray = (NSArray *)jsonObject;
               DLog(@"jsonArray - %@",jsonArray);
               for(NSDictionary *item in jsonArray) {
                  NSError *error = nil;
                  BOOL check=[self validateEmployee:[item objectForKey:@"id"] error:error];
                  if(check==TRUE){
                     // DLog(@"UNIQUE %@",error);
                     [self insertNewObject:item];
                     
                  }else{
                    // DLog(@"NOT UNIQUE %@",error);
                     
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

-(BOOL)validateEmployee:(NSString *) value error:(NSError *) error {
   
   // Validate uniqueness of my_unique_id
   NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
   [fetch setEntity:[NSEntityDescription entityForName:@"Employee"
                                inManagedObjectContext:self.managedObjectContext]];
   
   NSPredicate *predicate = [NSPredicate
                             predicateWithFormat:@"id = %@",value];
   
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





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)insertNewObject:(id)sender
{
   NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
   NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
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
      abort();
   }
}


#pragma mark - Table View


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
           cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
           cell.textLabel.font=[ UIFont fontWithName: @"Helvetica-Bold" size: 16.0 ];
           cell.detailTextLabel.font=[ UIFont fontWithName: @"Helvetica" size: 14.0 ];
        }
    }

    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

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
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   Employee *employee = (Employee *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    if (!self.detailViewController) {
	        self.detailViewController = [[[RBTDetailViewController alloc] initWithNibName:@"RBTDetailViewController_iPhone" bundle:nil] autorelease];
	    }
        self.detailViewController.detailEmployee = employee;
        [self.navigationController pushViewController:self.detailViewController animated:YES];
    } else {
        self.detailViewController.detailEmployee = employee;
    }
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
	    abort();
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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
   
   Employee *employee = [self.fetchedResultsController objectAtIndexPath:indexPath];
   cell.textLabel.text = employee.firstName;
   cell.detailTextLabel.text=employee.role;
   cell.detailTextLabel.text=employee.role;
   cell.textLabel.textColor=[UIColor colorWithHexValue:employee.hexColor];
   cell.detailTextLabel.textColor=[UIColor colorWithHexValue:employee.hexColor];
   //create the url
   
   UIImageView *imageViewArrow=[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tableViewArrow"] overlayTintColor:[UIColor colorWithHexValue:employee.hexColor]]];
   imageViewArrow.frame=CGRectMake(0, 0, 30, 30);
   cell.accessoryView=imageViewArrow;
   [imageViewArrow release];

   
   NSString *urlPathAvatar=[NSString stringWithFormat:@"http://theribots.nodejitsu.com/api/team/%@/ribotar",employee.id];
   
   [cell.imageView setImageWithURL:[NSURL URLWithString:urlPathAvatar]
                  placeholderImage:[[UIImage imageNamed:@"defaultRibot"] overlayTintColor:[UIColor colorWithHexValue:employee.hexColor]] options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                     //DLog(@"COMPLETADISIMO %@ %f %f",error,image.size.height,image.size.width);
                  }
    ];
}

@end
