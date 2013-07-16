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
"pragma marks" is a very useful functionality in Xcode when you are navigating within a class.

We can find them here:

![alt tag](http://emiliaregalado.com/ribotChallenge/pragmaMarkClick.png)

Once we have clicked there, we will be able to see the list of pragma marks that this class has.
Each pragma mark has a list of methods

![alt tag](http://emiliaregalado.com/ribotChallenge/pragmaMarks.png)


WHAT DO THEY DO? 
In order to make our lifes even easier, I have made a comment on top of every method which, follows this protocol:

* CALLED: it tells you when this method could be called
* IN: What parameters the method gets
* OUT: What parameters the method returns
* DO: What the method does



Navigation:
==========

We are going to have a look at the project in more detail. To do so, we will explain each group in the navigation view of the project in xcode.

--> Go to RibotTeam.xcodeproj--> RibotTeam --> **MVC**
Once we are there, we have another three folders, MODEL, VIEW and CONTROLLER. They implement the logic of our application.

![alt tag](http://emiliaregalado.com/ribotChallenge/navigationExample.png)

Model
-----

**Employee.h/.m** is our managed object which is a generic class that implements all the basic behavior required of a Core Data model object.

**RibotTeam.xcdatamodeld** is our data base.

View
----

**RBTPoppingView.h/.m** is a custom UIView. It has some animations in order to "POP" the view.

As we said at the beginning, we have already set up few settings for iPad development but we are not going to talk about them in this project.
--> Go to "iPhone" folder

**RBTMasterViewController_iPhone.xib** This file represents our table view which is the first view to be displayed.
**RBTDetailViewController_iPhone.xib** This file represents our detail view which will display the detail info of each ribot team member.

Controller
----------











