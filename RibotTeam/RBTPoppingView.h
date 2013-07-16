//
//  RBTPoppingView.h
//  RibotTeam
//
//  Created by Manuel Marcos Regalado on 16/07/13.
//  Copyright (c) 2013 Manuel Marcos Regalado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CoreAnimation.h>

@interface RBTPoppingView : UIView

- (void) attachPopUpAnimation;
- (void) attachPopOutAnimation;

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag;
- (void)animationDidStart:(CAAnimation *)theAnimation;
@end
