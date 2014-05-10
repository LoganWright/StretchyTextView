//
//  UIStretchyTextView.h
//  VoxNotes
//
//  Created by Logan Wright on 5/7/14.
//  Copyright (c) 2014 Logan Wright. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIStretchyTextViewDelegate

@end

@interface UIStretchyTextView : UITextView <UITextViewDelegate>

@property (nonatomic) CGFloat maxHeight;

@property BOOL shouldContstrictHorizontallyAsWell;
@property CGFloat maxWidth;

@end
