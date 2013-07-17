//
//  RBTPoppingView.m
//  RibotTeam
//
//  Created by Manuel Marcos Regalado on 16/07/13.
//  Copyright (c) 2013 Manuel Marcos Regalado. All rights reserved.
//

#import "RBTPoppingView.h"

@implementation RBTPoppingView

/*
 CALLED:This method is being called when we have to DISPLAY the subview and start the animation
 IN:
 OUT: void
 DO: It scales the image in different sizes and makes the animation
 */
- (void) attachPopUpAnimation
{
   CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                     animationWithKeyPath:@"transform"];
   animation.delegate=self;
   
   CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
   CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
   CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
   CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
   
   NSArray *frameValues = [NSArray arrayWithObjects:
                           [NSValue valueWithCATransform3D:scale1],
                           [NSValue valueWithCATransform3D:scale2],
                           [NSValue valueWithCATransform3D:scale3],
                           [NSValue valueWithCATransform3D:scale4],
                           nil];
   [animation setValues:frameValues];
   
   NSArray *frameTimes = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0.0],
                          [NSNumber numberWithFloat:0.5],
                          [NSNumber numberWithFloat:0.9],
                          [NSNumber numberWithFloat:1.0],
                          nil];
   [animation setKeyTimes:frameTimes];
   
   animation.fillMode = kCAFillModeForwards;
   animation.removedOnCompletion = NO;
   animation.duration = .7;
   
   [self.layer addAnimation:animation forKey:@"popup"];
}

/*
 CALLED:This method is being called when we have to REMOVE the subview and start the animation
 IN:
 OUT: void
 DO: It scales the image in different sizes and makes the animation
 */
- (void) attachPopOutAnimation
{
   
   CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                     animationWithKeyPath:@"transform"];
   animation.delegate=self;
   
   CATransform3D scale4 = CATransform3DMakeScale(0.5, 0.5, 1);
   CATransform3D scale3 = CATransform3DMakeScale(1.2, 1.2, 1);
   CATransform3D scale2 = CATransform3DMakeScale(0.9, 0.9, 1);
   CATransform3D scale1 = CATransform3DMakeScale(1.0, 1.0, 1);
   
   NSArray *frameValues = [NSArray arrayWithObjects:
                           [NSValue valueWithCATransform3D:scale1],
                           [NSValue valueWithCATransform3D:scale2],
                           [NSValue valueWithCATransform3D:scale3],
                           [NSValue valueWithCATransform3D:scale4],
                           nil];
   [animation setValues:frameValues];
   
   NSArray *frameTimes = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0.0],
                          [NSNumber numberWithFloat:0.5],
                          [NSNumber numberWithFloat:0.9],
                          [NSNumber numberWithFloat:1.0],
                          nil];
   [animation setKeyTimes:frameTimes];
   
   animation.fillMode = kCAFillModeForwards;
   animation.removedOnCompletion = NO;
   animation.duration = .7;
   
   [self.layer addAnimation:animation forKey:@"popout"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
   if (theAnimation == [[self layer] animationForKey:@"popout"])
   {
      self.hidden=YES;
   }
   
   
   
}
- (void)animationDidStart:(CAAnimation *)theAnimation
{
   if (theAnimation == [[self layer] animationForKey:@"popup"])
   {
      self.hidden=NO;
   }
}

@end
