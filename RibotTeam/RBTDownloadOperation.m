//
//  NSOperation+RBTDownloadOperation.m
//  RibotTeam
//
//  Created by Manuel Marcos Regalado on 15/07/13.
//  Copyright (c) 2013 Manuel Marcos Regalado. All rights reserved.
//

#import "RBTDownloadOperation.h"


@interface RBTDownloadOperation()

@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, assign) id<RBTDownloadOperation> delegate;

@end


@implementation RBTDownloadOperation

@synthesize delegate;
@synthesize request;
@synthesize data;
@synthesize statusCode;
@synthesize tagOperation;

/* initWithURLRequest
 CALLED:This method is being called when we want initialize a new operation
 IN: requestEMP--> request to do; delegateEMP--> Who is the delegate of the operation; tagOperationSet--> value to differenciate the operation
 OUT: id--> itself
 DO: it inits the operation
 */
- (id)initWithURLRequest:(NSURLRequest*)requestEMP andDelegate:(id<RBTDownloadOperation>)delegateEMP andTagOperation:(NSString *)tagOperationSet
{
   if (!(self = [super init])) return nil;
   
   [self setDelegate:delegateEMP];
   [self setRequest:requestEMP];
   [self setTagOperation:tagOperationSet];
   return self;
}

/* dealloc
 CALLED:This method is being called when the operation is being realeased
 IN: nothing
 OUT: void
 DO: Deallocates the memory occupied by the receiver.
 */
- (void)dealloc
{
   [self setDelegate:nil];
   [self setRequest:nil];
   [self setData:nil];
   
   [super dealloc];
}

/* main
 CALLED:This method is being called when the operation is being executed
 IN: nothing
 OUT: void
 DO: Runs the operation
 */
- (void)main
{
   [NSURLConnection connectionWithRequest:[self request] delegate:self];
   //CFRunLoopRun();
}

/* connection didReceiveResponse
 CALLED:This method is being called when the operation receives a response
 IN: connection--> reference to the NSURLConnection; resp--> response of the request
 OUT: void
 DO: receives a response
 */
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)resp
{
   [self setStatusCode:[resp statusCode]];
   [self setData:[NSMutableData data]];
}

/* connection didReceiveData
 CALLED:This method is being called when the connection receives data
 IN: connection--> the reference of the NSURLConnection; newData--> data of the connection
 OUT: void
 DO: It receives the data from the connection
 */
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)newData
{
   [[self data] appendData:newData];
}

/* connectionDidFinishLoading 
 CALLED:This method is being called when the connection has finished
 IN: connection--> the reference of the NSURLConnection;
 OUT: void
 DO: It tells us that it has finished
 */
- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
   [[self delegate] operation:self didCompleteWithData:[self data]];
   CFRunLoopStop(CFRunLoopGetCurrent());
}
/* connection didFailWithError
 CALLED:This method is being called when the connection has failed
 IN: connection--> the reference of the NSURLConnection; error--> tell us what happened
 OUT: void
 DO: It tells us that it has finished
 */
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
   [[self delegate] operation:self didFailWithError:error];
   CFRunLoopStop(CFRunLoopGetCurrent());
}

@end

