RibotTeam
=========

RibotTeam is an iPhone App which, has a list of ribot team members with their details info. 
It uses a Rest API and It could have been implemented with the [restKit](https://github.com/RestKit/RestKit) for iOS but I considered that this project is not big enough to use such a big framework.

Also, This project has been set up for iPad environment. It already has some settings and code for iPad implementation and it is quite simple to extend the project for iPad development.

Requirements:
============
In order to install this application into your iPhone or simulator you have to have:

   Xcode 4.6 or later

   iPhone device or iPhone simulator with iOS 6.1
   

Tips to follow the code:
=======================

FIND CLASSES: 
A good tip to find classes is have a look at the Navigation view (on the left hand side of Xcode) 
where I have organized the classes depending on their type.

![alt tag](http://emiliaregalado.com/ribotChallenge/navigationBar.png)

FIND METHODS: 
"pragma marks" is a very useful functionality in Xcode when we are navigating within a class.

We can find them here:

![alt tag](http://emiliaregalado.com/ribotChallenge/pragmaMarkClick.png)

Once we have clicked there, we will be able to see the list of pragma marks that this class has.
Each pragma mark has a list of methods

![alt tag](http://emiliaregalado.com/ribotChallenge/pragmaMarks.png)


WHAT DO THEY DO? 
In order to make our lifes even easier, I have made a comment on top of every method which, follows this protocol:

* CALLED: it tells us when this method could be called
* IN: What parameters the method gets
* OUT: What parameters the method returns
* DO: What the method does

The last tip is about Debug info.
If we open **RibotTeam-Prefix.pch** we could see that we have defined a DEBUG flag for print out info through Xcode console. In this case, whenever the App is ready for distribution we will only have to change that flag instead of remove all the debug info.


Navigation:
==========

We are going to have a look at the project in more detail. To do so, we will explain each group in the navigation view of the project in xcode.

--> Go to RibotTeam.xcodeproj--> RibotTeam --> **MVC**
Once we are there, we have another three folders:
   * MODEL 
   * VIEW 
   * CONTROLLER. 

They implement the logic of our application.

![alt tag](http://emiliaregalado.com/ribotChallenge/navigationExample.png)

Model
-----

**Employee.h/.m** is our managed object which is a generic class that implements all the basic behavior required of a Core Data model object.

**RibotTeam.xcdatamodeld** is our data base.

View
----

**RBTPoppingView.h/.m** is a subclass of UIView. This custom view has some animations in order to "POP" the view.

As we said at the beginning, we have already set up few settings for iPad development but we are not going to talk about them in this project.
--> Go to "iPhone" folder

**RBTMasterViewController_iPhone.xib**  represents our table view which is the first view to be displayed.

**RBTDetailViewController_iPhone.xib**  represents our detail view which will display the detail info of each ribot team member.

Controller
----------

**RBTMasterViewController.h/.m** is our first controller to be loaded. It deals (insert/edit/delete) with the Model (Employee.h/.m) and display content on the view (RBTMasterViewController_iPhone.xib)

**RBTDetailViewController.h/.m** navigates from RBTMasterViewController.h/.m and displays the detail info of each ribot team member. It also deals with Employee.h/.m and display the content into RBTDetailViewController_iPhone.xib




Now, -> Go to RibotTeam.xcodeproj--> RibotTeam --> **Resources**


Resources
---------
This folder has another six folders more: 
   
   * **Categories** An Objective-C category allows us to add methods to an existing class—effectively subclassing it without having to deal with the possible complexities of subclassing.
   
      * UIColor+UIColor_HexColor.h/.m is a category of UIColor and it implements a method which, changes HexColors into UIColors
      * UIImage+OverlayTintColor.h/.m is a category of UIImage and it overlays a UIColor on top of a PNG image. Basically, it paints a PNG with a given UIColor. 
      
   * **Operations**
   
      * RBTDownloadOperation.h/.m is a subclass of NSOperation and it implements a protocol which, will make our life easier when dealing with NSURLRequest. We will use it to communicate with the API. We have to be careful when we use it cos it adds the operation to the operation queue of the mainthread but does not guarantee when it will be executed. There could be other items in that queue still waiting to execute so we will have to make sure in which Thread we are when we want to change the UI.
      
   * **Maps**
   
      * RBTAnnotationMap.h/.m is just a MKAnnotation protocol which, is used to provide annotation-related information to a map view. In this case, the location of the ribot team member.
    
   * **Reachability** It demonstrates how to know when IP can be routed and when traffic will be routed through a Wireless Wide Area Network (WWAN) interface such as EDGE or 3G.

   * **SDWebImage** We can find this library [here](https://github.com/rs/SDWebImage). It is a great library for download web images asynchronously.
  
   * **Assets**
   
      * Most of the assets are available for retina and non-retina display.
   


Frameworks
----------

**QuartzCore.framework**  supports image processing and video image manipulation. It is being used by RBTPoppingView.

**ImageIO.framework**  contains classes for reading and writing image data. It is being used by the library SDWebImage

**MapKit.framework**  contains classes for embedding a map interface into your application and for reverse-geocoding coordinates. It is being used by the library SDWebImage and in RBTDetailViewController
 
**CoreLocation.framework**  contains the interfaces for determining the user’s location. It is being used by RBTDetailViewController.

**MessageUI.framework**  contains interfaces for composing and queuing email messages. It will be used by RBTDetailViewController.

**AddressBook.framework**  contains functions for accessing the user’s contacts database directly. It is being used by RBTDetailViewController.

**AddressBookUI.framework**  contains classes for displaying the system-defined people picker and editor interfaces.  It is being used by RBTDetailViewController.

**UIKit.framework**  contains classes and methods for the iOS application user interface layer. It is being used by main.m, RBTAppDelegate, RBTDetailViewController, RBTMasterViewController, RBTPoppingView, SDWebImage, prefix.pch, UIColor_HexColor, OverlayTintColor.

**Foundation.framework**  contains interfaces for managing strings, collections, and other low-level data types. It is being used by Employee, RBTAnnotationMap, RBTDetailViewController, RBTDownloadOperation, RBTMasterViewController, Prefix.pch, SDWebImage, 

**CoreGraphics.framework**  contains the interfaces for Quartz 2D.

**CoreData.framework**  contains interfaces for managing your application’s data model. It is being used by Employee, RBTMasterViewController, Prefix.pch

**SenTestingKit.framework** provides a set of classes and command-line tools that let you design test suites and run them on your code. Not being used yet.

**SystemConfiguration.framework** contains interfaces for determining the network configuration of a device.




Improvements
============



