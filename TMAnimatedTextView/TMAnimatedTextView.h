//
//  Created by Bob Wieler on 9/22/14.
//  Copyright (c) 2015 TapMesh, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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