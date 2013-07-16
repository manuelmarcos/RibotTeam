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

- (id)initWithURLRequest:(NSURLRequest*)requestEMP andDelegate:(id<RBTDownloadOperation>)delegateEMP andTagOperation:(NSString *)tagOperationSet
{
   if (!(self = [super init])) return nil;
   
   [self setDelegate:delegateEMP];
   [self setRequest:requestEMP];
   [self setTagOperation:tagOperationSet];
   return self;
}

- (void)dealloc
{
   [self setDelegate:nil];
   [self setRequest:nil];
   [self setData:nil];
   
   [super dealloc];
}

- (void)main
{
   [NSURLConnection connectionWithRequest:[self request] delegate:self];
   //CFRunLoopRun();
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)resp
{
   [self setStatusCode:[resp statusCode]];
   [self setData:[NSMutableData data]];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)newData
{
   [[self data] appendData:newData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
   [[self delegate] operation:self didCompleteWithData:[self data]];
   CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
   [[self delegate] operation:self didFailWithError:error];
   CFRunLoopStop(CFRunLoopGetCurrent());
}

@end

