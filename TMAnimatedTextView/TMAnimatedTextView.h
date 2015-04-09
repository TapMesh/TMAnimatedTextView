//
// Created by Bob Wieler on 9/22/14.
// Copyright (c) 2014 TapMesh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMAnimatedTextView;

@protocol TMAttachmentData <NSObject>
@required
- (NSString *) identifier;
- (UIImage *) image;
@end

@protocol TMAnimatedTextViewDelegate <NSObject>
@optional
- (void) viewBoundsWillChangeFrom:(CGRect)oldBounds to:(CGRect)newBounds;
- (void) viewBoundsDidChangeFrom:(CGRect)oldBounds to:(CGRect)newBounds;

- (BOOL) shouldAddAttachmentData:(id <TMAttachmentData>)data;
- (void) didAddAttachmentData:(id <TMAttachmentData>)data;

- (BOOL) shouldDeleteAttachmentData:(id <TMAttachmentData>)data;
- (void) didDeleteAttachmentData:(id <TMAttachmentData>)data;

- (BOOL) shouldInteractWithAttachmentData:(id <TMAttachmentData>)data;
- (void) didInteractWithAttachmentData:(id <TMAttachmentData>)data;

- (void) animatedTextViewDidChange:(TMAnimatedTextView *)textView;

- (void) pasteImage:(UIImage *)image;

@end

@interface TMAnimatedTextView : UITextView <UITextViewDelegate, UIGestureRecognizerDelegate>

@property(nonatomic) CGFloat maxHeight;
@property(nonatomic) CGFloat minHeight;

@property(weak, nonatomic) IBOutlet id <TMAnimatedTextViewDelegate> animatedTextViewDelegate;

- (void) attachData:(id <TMAttachmentData>)data;
- (void) animateData:(id <TMAttachmentData>)data withAnimation:(void (^)(UIImageView *imageView))animationBlock;

@end