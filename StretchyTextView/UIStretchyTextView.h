//
//  UIStretchyTextView.h
//  VoxNotes
//
//  Created by Logan Wright on 5/7/14.
//  Copyright (c) 2014 Logan Wright. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, StretchDirection) {
    /*!
     Bottom point fixed, stretches upwards
     */
    StretchDirectionUp,
    /*!
     Top point remains fixed, stretches downwards
     */
    StretchDirectionDown,
    /*!
     Center point remains fixed, stretches outwards
     */
    StretchDirectionOutward
};

@interface UIStretchyTextView : UITextView <UITextViewDelegate>

@property (nonatomic) StretchDirection stretchDirection;

@property (nonatomic) CGFloat maxHeight;

@property BOOL shouldContstrictHorizontallyAsWell;
@property CGFloat maxWidth;

@end
