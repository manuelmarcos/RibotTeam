//
//  UIImage+OverlayTintColor.m
//  RibotTeam
//
//  Created by Manuel Marcos Regalado on 15/07/13.
//  Copyright (c) 2013 Manuel Marcos Regalado. All rights reserved.
//

#import "UIImage+OverlayTintColor.h"

@implementation UIImage (OverlayTintColor)

- (UIImage *)overlayTintColor:(UIColor *)tintColor{
   
   //  Create rect to fit the PNG image
   CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
   
   //  Start drawing
   UIGraphicsBeginImageContext(rect.size);
   CGContextRef context = UIGraphicsGetCurrentContext();
   CGContextSaveGState(context);
   
   //  Fill the rect by the final color
   [tintColor setFill];
   CGContextFillRect(context, rect);
   
   //  Make the final shape by masking the drawn color with the images alpha values
   CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
   [self drawInRect: rect blendMode:kCGBlendModeDestinationIn alpha:1];
   
   //  Create new image from the context
   UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
   
   //  Release context
   UIGraphicsEndImageContext();
   
   return img;
}

@end
