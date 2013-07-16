//
//  NSOperation+RBTDownloadOperation.h
//  RibotTeam
//
//  Created by Manuel Marcos Regalado on 15/07/13.
//  Copyright (c) 2013 Manuel Marcos Regalado. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RBTDownloadOperation;
@protocol RBTDownloadOperation <NSObject>

- (void)operation:(RBTDownloadOperation*)operation didCompleteWithData:(NSData*)data;
- (void)operation:(RBTDownloadOperation*)operation didFailWithError:(NSError*)error;

@end

@interface RBTDownloadOperation : NSOperation

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, retain) NSString *tagOperation;

- (id)initWithURLRequest:(NSURLRequest*)requestEMP andDelegate:(id<RBTDownloadOperation>)delegateEMP andTagOperation:(NSString *)tagOperationSet;
@end
