//
//  UIStretchyTextView.m
//  VoxNotes
//
//  Created by Logan Wright on 5/7/14.
//  Copyright (c) 2014 Logan Wright. All rights reserved.
//

/*  FEATURES
 
 Detect keyboard and figure out where textView is vs. keyboard.  Set insets to automatically account for keyboard
 
 */

/*  PROBLEMS
 
 Arrowing up causes problems sometimes.  Very rare since most people don't use a keyboard.
 
 Setting ContentInsets causes problems
 
 */

// Last Update
// 10 May 2014



NSString * const KVObserverPathBorderWidth = @"borderWidth";
NSString * const KVObserverPathCornerRadius = @"cornerRadius";

#import "UIStretchyTextView.h"


@interface UIStretchyTextView ()

// Theoretically to be used to find our maximum width
@property CGRect assignedFrame;

@end

@implementation UIStretchyTextView

@synthesize maxHeight = _maxHeight;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        // We'll just observe our own stuff
        self.delegate = self;
        
        // If these are changed, formatting must follow
        [self.layer addObserver:self
                     forKeyPath:KVObserverPathBorderWidth
                        options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                        context:nil];
        [self.layer addObserver:self
                     forKeyPath:KVObserverPathCornerRadius
                        options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                        context:nil];
        
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        _stretchDirection = StretchDirectionOutward;
    }
    return self;
    
}

- (void) dealloc {
    
    // Release KVO Observers
    [self.layer removeObserver:self forKeyPath:KVObserverPathBorderWidth];
    [self.layer removeObserver:self forKeyPath:KVObserverPathCornerRadius];
    
}

#pragma mark TEXT VIEW DELEGATE

- (void) textViewDidBeginEditing:(UITextView *)textView {
}
- (void) textViewDidChange:(UITextView *)textView {
}
- (void) textViewDidChangeSelection:(UITextView *)textView {
    [self resizeAndAlign];
}

#pragma mark SIZING AND ALIGNING

- (void) resizeAndAlign {
    [self resize];
    [self align];
}
- (void) resize {
    
    if (!_maxHeight) {
        _maxHeight = MAXFLOAT;
    }
    
    NSDictionary * attributes = @{NSFontAttributeName : self.font,
                                  NSStrokeColorAttributeName : self.textColor};
    
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithString:self.text attributes:attributes];
    
    // 10 less than our target because it seems to frame better -- Seriously, you're gonna want to keep the 10.0 . . . trust me.
    CGFloat width = CGRectGetWidth(self.bounds) - self.textContainerInset.left - self.textContainerInset.right - 10.0;
    
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    CGFloat height = rect.size.height;
    
    // Add an extra line for return characters
    if ([self.text hasSuffix:@"\n"]) {
        height = height + self.font.lineHeight;
    }
    
    // WORKING
    CGFloat offset = self.layer.borderWidth * 2.0;
    CGFloat targetHeight = height + offset;
    
    /// ADDING
    UIEdgeInsets contentInset = self.contentInset;
    targetHeight = targetHeight + contentInset.top + contentInset.bottom;
    /////////////////
    
    if (targetHeight > _maxHeight) {
        targetHeight = _maxHeight;
    }
    else if (targetHeight < (self.layer.cornerRadius * 2.0)) {
        // Make sure our height is at least 2x corner radius for smooth rounding
        targetHeight = self.layer.cornerRadius * 2.0;
    }
    
    CGFloat currentHeight = CGRectGetHeight(self.frame);
    
    if (targetHeight != currentHeight) {
        
        CGSize targetSize = CGSizeMake(CGRectGetWidth(self.bounds), targetHeight);
        
        if (_stretchDirection == StretchDirectionOutward) {
            self.bounds = (CGRect) {
                .origin = CGPointZero,
                .size = targetSize
            };
        }
        else if (_stretchDirection == StretchDirectionDown) {
            self.frame = (CGRect) {
                .origin = self.frame.origin,
                .size = targetSize
            };
        }
        else if (_stretchDirection == StretchDirectionUp) {
            self.frame = (CGRect) {
                .origin = CGPointMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame) + CGRectGetHeight(self.frame)),
                .size = CGSizeMake(targetSize.width, -targetSize.height)
            };
        }
    }
}
- (void) align {
    
    // The rectangle of the caret (the blinky thingy in textView's)
    CGRect line = [self caretRectForPosition:self.selectedTextRange.end];
    
    // Amount of scrollview above contents of view
    CGFloat contentOffsetTop = self.contentOffset.y;
    
    // The top of the caret
    CGFloat topOfLine = CGRectGetMinY(line);
    
    // The bottom of the caret
    CGFloat bottomOfLine = topOfLine + CGRectGetHeight(line);
    
    // The bottom of the visible text area
    UIEdgeInsets contentInset = self.contentInset;
    CGFloat bottomOfVisibleTextArea = contentOffsetTop + CGRectGetHeight(self.bounds) - contentInset.top - contentInset.bottom;
    
    // If the top point on the caret is less than offset, then some is offscreen, then that's too much and we need to adjust! (compensate for masterOffset buffer)
    if (CGRectGetMinY(line) < contentOffsetTop) {
        // Caret is offscreen TOP
        
        // The amount that the caret is hanging over the top of the textView's visible area
        CGFloat topOverflow = contentOffsetTop - topOfLine;
        // There is a slight overhang from letters like y, g, and j if the masterOffset is added.  Without it, the caret will rub the very top of the textView. Either is fine, just pick which one you prefer
        CGFloat minimumOverflow = topOverflow + self.layer.borderWidth; // + masterOffset;
        CGPoint offsetP = self.contentOffset;
        offsetP.y -= minimumOverflow;
        self.contentOffset = offsetP;
    }
    else if (bottomOfLine > bottomOfVisibleTextArea) {
        // Caret is offscreen BOTTOM
        
        // The amount that the caret is hanging over the bottom of the textView's visible area
        CGFloat bottomOverflow = bottomOfLine - bottomOfVisibleTextArea;
        
        // How much we need to adjust
        CGFloat minimumOverflow = bottomOverflow + self.layer.borderWidth;
        CGPoint offsetP = self.contentOffset;
        offsetP.y += minimumOverflow;
        self.contentOffset = offsetP;
    }
    else {
        // Caret is onscreen - Do nothing
    }
}

// Occasionally inconsistent!
- (void) centerVertically {
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat contentHeight = self.contentSize.height;
    CGFloat zoomScale = self.zoomScale;
    CGFloat topCorrect = (height - contentHeight * zoomScale) / 2.0;
    
    topCorrect = (topCorrect < 0.0) ? 0.0 : topCorrect ;
    self.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}

#pragma mark PROPERTY OVERRIDES

- (void) setFrame:(CGRect)frame {
    NSLog(@"SettingFrame: %@", NSStringFromCGRect(frame));
    _assignedFrame = frame;
    [super setFrame:frame];
}
- (CGRect) frame {
    return [super frame];
}

- (UIColor *) textColor {
    UIColor * textColor = [super textColor];
    if (!textColor) {
        textColor = [UIColor darkGrayColor];
        super.textColor = textColor;
    }
    return textColor;
}

- (UIFont *) font {
    UIFont * font = [super font];
    if (!font) {
        font = [UIFont systemFontOfSize:14.0];
        super.font = font;
    }
    return font;
}

- (void) setContentSize:(CGSize)contentSize {
    NSLog(@"Setting contentSize");
    [super setContentSize:contentSize];
    [self resizeAndAlign];
    
}

- (CGFloat) maxHeight {
    return _maxHeight;
}
- (void) setMaxHeight:(CGFloat)maxHeight {
    _maxHeight = maxHeight;
    // It's possible that someone might set a string before setting the maxHeight.  This will correct any errors.
    //[self resizeView];
    [self resizeAndAlign];
}

#pragma mark KEY VALUE OBSERVER

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:KVObserverPathBorderWidth]) {
        UIEdgeInsets insets =  self.textContainerInset;
        CGFloat borderWidth = self.layer.borderWidth;
        insets.left += borderWidth;
        insets.right += borderWidth;
        insets.top += borderWidth;
        insets.bottom += borderWidth;
        self.textContainerInset = insets;
        [self resizeAndAlign];
    }
    else if ([keyPath isEqualToString:KVObserverPathCornerRadius]) {
        UIEdgeInsets insets =  self.textContainerInset;
        CGFloat leftRightInset = self.layer.cornerRadius / 3.0; // 1 third corner radius appears to work ok
        insets.left += leftRightInset;
        insets.right += leftRightInset;
        self.textContainerInset = insets;
        [self resizeAndAlign];
    }
    
}
@end


