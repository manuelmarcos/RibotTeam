RibotTeam
=========

RibotTeam is an iPhone App which, has a list of ribot team members with their details info. 
It uses a Rest API and It could have been implemented with the [restKit](https://github.com/RestKit/RestKit) for iOS but I considered that this project is not big enough to use such a big framework.

Requirements:
============
In order to install this application into your iPhone or simulator you have to have:

   Xcode 4.6 or later

   iOS 6.1 (iPhone device or iPhone simulator)
   

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







