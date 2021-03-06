//
//  UIColor+UIColor_HexColor.m
//  RibotTeam
//
//  Created by Manuel Marcos Regalado on 15/07/13.
//  Copyright (c) 2013 Manuel Marcos Regalado. All rights reserved.
//

#import "UIColor+UIColor_HexColor.h"

@implementation UIColor (UIColor_HexColor)

/* colorWithHexValue
 CALLED:This method is being called when we want to change a HEXCOLOR into a UIColor
 IN: hexValue--> hex value for the color 
 OUT: UIColor--> the uicolor from the hexcolor
 DO: hide the view with an animation
 */
+ (UIColor*)colorWithHexValue:(NSString*)hexValue
{
   UIColor *defaultResult = [UIColor blackColor];
   
   // Strip leading # if there is one
   if ([hexValue hasPrefix:@"#"] && [hexValue length] > 1) {
      hexValue = [hexValue substringFromIndex:1];
   }
   
   NSUInteger componentLength = 0;
   if ([hexValue length] == 3)
      componentLength = 1;
   else if ([hexValue length] == 6)
      componentLength = 2;
   else
      return defaultResult;
   
   BOOL isValid = YES;
   CGFloat components[3];
   
   for (NSUInteger i = 0; i < 3; i++) {
      NSString *component = [hexValue substringWithRange:NSMakeRange(componentLength * i, componentLength)];
      if (componentLength == 1) {
         component = [component stringByAppendingString:component];
      }
      NSScanner *scanner = [NSScanner scannerWithString:component];
      unsigned int value;
      isValid &= [scanner scanHexInt:&value];
      components[i] = (CGFloat)value / 256.0;
   }
   
   if (!isValid) {
      return defaultResult;
   }
   
   return [UIColor colorWithRed:components[0]
                          green:components[1]
                           blue:components[2]
                          alpha:1.0];
}

@end
