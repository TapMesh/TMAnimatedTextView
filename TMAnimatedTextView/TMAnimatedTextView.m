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

#import "TMAnimatedTextView.h"

#pragma mark - TMAnimatedTextView (Private)

@interface TMAnimatedTextView ()

- (BOOL) attachmentExistsWithIdentifier:(NSString *)identifier;
- (CGRect) frameOfIdentifier:(NSString *)identifier;
- (id <TMAttachmentData>) attachmentDataAtPoint:(CGPoint)point;

@end

#pragma mark - TMTextAttachment (Interface)

@interface TMTextAttachment : NSTextAttachment

@property(nonatomic, readonly) CGSize expectedSize;
@property(nonatomic, readonly) id<TMAttachmentData> data;

- (instancetype) initWithAttachmentData:(id<TMAttachmentData>)data bounds:(CGRect)bounds;

@end

#pragma mark - TMTextAttachment (Implementation)

@implementation TMTextAttachment {
@private
    CGSize _expectedSize;
    id <TMAttachmentData> _data;
}

@synthesize expectedSize = _expectedSize;
@synthesize data = _data;

- (instancetype) initWithAttachmentData:(id <TMAttachmentData>)data bounds:(CGRect)bounds {
    self = [super init];
    if (self) {
        _data = data;
        _expectedSize = bounds.size;
        self.bounds = bounds;
    }
    return self;
}

@end

#pragma mark - Overview

@interface TMAnimatedTextViewOverview : UIView

@property(nonatomic, weak) TMAnimatedTextView *textView;

- (instancetype) initWithFrame:(CGRect)frame chatTextView:(TMAnimatedTextView *)textView;

- (void) registerData:(id<TMAttachmentData>)data actualImage:(UIImage *)image;
- (void) unregisterData:(id<TMAttachmentData>)data;

- (void) animateData:(id <TMAttachmentData>)data withAnimation:(void (^)(UIImageView *imageView))animationBlock;

@end

@implementation TMAnimatedTextViewOverview {
@private
    NSMutableDictionary *_attachmentViews;
}

- (instancetype) initWithFrame:(CGRect)frame chatTextView:(TMAnimatedTextView *)textView {
    self = [super initWithFrame:frame];
    if (self) {
        self.textView = textView;
        _attachmentViews = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)calculateAll {
    NSMutableArray *cardIdsToRemove = [NSMutableArray array];
    for (NSString *identifier in _attachmentViews.keyEnumerator) {
        UIImageView *imageView = _attachmentViews[identifier];

        if ([self.textView attachmentExistsWithIdentifier:identifier]) {
            imageView.frame = [self.textView frameOfIdentifier:identifier];
        }
        else {
            [cardIdsToRemove addObject:identifier];
            [imageView stopAnimating];
            [imageView removeFromSuperview];
        }
    }
    [_attachmentViews removeObjectsForKeys:cardIdsToRemove];
}

- (void) registerData:(id<TMAttachmentData>)data actualImage:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:imageView];
    _attachmentViews[data.identifier] = imageView;
}

- (void) unregisterData:(id<TMAttachmentData>)data {
    UIImageView *existingImageView = _attachmentViews[data.identifier];
    if (existingImageView) {
        [existingImageView removeFromSuperview];
        [existingImageView stopAnimating];
        [_attachmentViews removeObjectForKey:data.identifier];
    }
}

- (void) animateData:(id <TMAttachmentData>)data withAnimation:(void (^)(UIImageView *imageView))animationBlock {
    UIImageView *imageView = _attachmentViews[data.identifier];
    animationBlock(imageView);
}

@end

#pragma mark - ChatTextView

@implementation TMAnimatedTextView {
@private
    NSLayoutConstraint *_heightConstraint;
    UITapGestureRecognizer *_tapGestureRecognizer;
    __weak id <TMAnimatedTextViewDelegate> _animatedTextViewDelegate;
    TMAnimatedTextViewOverview *_overview;
}

@synthesize animatedTextViewDelegate = _animatedTextViewDelegate;

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitializer];
    }

    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitializer];
    }

    return self;
}

- (void) commonInitializer {
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            _heightConstraint = constraint;
            break;
        }
    }

    if (!_heightConstraint) {
        [NSException raise:NSInternalInconsistencyException format:@"Animated text view requires a height constraint"];
    }

    self.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;

    self.font = [UIFont systemFontOfSize:14];
    self.typingAttributes = @{
            NSFontAttributeName : self.font
    };

    self.delegate = self;

    _tapGestureRecognizer = [[UITapGestureRecognizer alloc]
            initWithTarget:self action:@selector(handleTextViewTapGestureRecognizer:)];
    _tapGestureRecognizer.delegate = self;
    _tapGestureRecognizer.numberOfTouchesRequired = 1;
    _tapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:_tapGestureRecognizer];

    _overview = [[TMAnimatedTextViewOverview alloc] initWithFrame:CGRectMake(0, 0, 400, 400) chatTextView:self];
    _overview.backgroundColor = [UIColor clearColor];
    _overview.userInteractionEnabled = NO;
    [self addSubview:_overview];
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {

}

- (void) setBounds:(CGRect)bounds {
    BOOL changed = NO;
    CGSize currentSize = self.bounds.size;
    CGSize newSize = bounds.size;
    if (newSize.height != currentSize.height || newSize.width != currentSize.width) {
        changed = YES;
        if (_animatedTextViewDelegate && [_animatedTextViewDelegate respondsToSelector:@selector(viewBoundsWillChangeFrom:to:)]) {
            [_animatedTextViewDelegate viewBoundsWillChangeFrom:CGRectMake(0, 0, currentSize.width, currentSize.height)
                                                             to:CGRectMake(0, 0, newSize.width, newSize.height)];
        }
    }
    [super setBounds:bounds];
    if (changed) {
        if (_animatedTextViewDelegate && [_animatedTextViewDelegate respondsToSelector:@selector(viewBoundsDidChangeFrom:to:)]) {
            [_animatedTextViewDelegate viewBoundsDidChangeFrom:CGRectMake(0, 0, currentSize.width, currentSize.height)
                                                            to:CGRectMake(0, 0, newSize.width, newSize.height)];
        }
    }
}

- (void) layoutSubviews {
    [super layoutSubviews];

    CGSize intrinsicSize = self.intrinsicContentSize;
    if (self.minHeight) {
        intrinsicSize.height = MAX(intrinsicSize.height, self.minHeight);
    }
    if (self.maxHeight) {
        intrinsicSize.height = MIN(intrinsicSize.height, self.maxHeight);
    }
    _heightConstraint.constant = intrinsicSize.height;

    if (self.intrinsicContentSize.height <= self.bounds.size.height) {
        CGFloat topCorrect = (CGFloat) ((self.bounds.size.height - self.contentSize.height * [self zoomScale]) / 2.0);
        topCorrect = (CGFloat) (topCorrect < 0.0 ? 0.0 : topCorrect);
        self.contentOffset = (CGPoint) {.x = 0, .y = -topCorrect};
    }
    [_overview calculateAll];
}

- (CGSize) intrinsicContentSize {
    CGSize intrinsicContentSize = self.contentSize;

    intrinsicContentSize.width += (self.textContainerInset.left + self.textContainerInset.right) / 2.0f;

    return intrinsicContentSize;
}

- (UIImage *) createPlaceholderImageForImage:(UIImage *)image {
    CALayer *imageLayer = [CALayer layer];
    imageLayer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = 10;
    imageLayer.backgroundColor = [UIColor clearColor].CGColor;

    UIGraphicsBeginImageContext(image.size);

    CGContextRef context = UIGraphicsGetCurrentContext();
    [imageLayer renderInContext:context];

    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    return finalImage;
};

- (void) attachData:(id<TMAttachmentData>)data {
    BOOL shouldAdd = YES;
    if (_animatedTextViewDelegate && [_animatedTextViewDelegate respondsToSelector:@selector(shouldAddAttachmentData:)]) {
        shouldAdd = [_animatedTextViewDelegate shouldAddAttachmentData:data];
    }

    if (shouldAdd) {
        UIImage *visibleImage = data.image;
        UIImage *placeholderImage = [self createPlaceholderImageForImage:visibleImage];

        UITextRange *selRange = self.selectedTextRange;
        UITextPosition *selStartPos = selRange.start;
        NSUInteger index = (NSUInteger) [self offsetFromPosition:self.beginningOfDocument toPosition:selStartPos];

        TMTextAttachment *attachment = [[TMTextAttachment alloc] initWithAttachmentData:data bounds:CGRectMake(0, -5, visibleImage.size.width / 2, visibleImage.size.height / 2)];
        attachment.image = placeholderImage;
        [_overview registerData:data actualImage:visibleImage];

        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];

        NSMutableAttributedString *attributedString = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
        [attributedString addAttribute:NSFontAttributeName value:self.font range:(NSRange){0,[attributedString length]}];
        [string insertAttributedString:attributedString atIndex:index];

        self.attributedText = string;
        [self layoutSubviews];

        if (_animatedTextViewDelegate && [_animatedTextViewDelegate respondsToSelector:@selector(didAddAttachmentData:)])
            [_animatedTextViewDelegate didAddAttachmentData:data];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self becomeFirstResponder];
            [TMAnimatedTextView selectTextForInput:self atRange:NSMakeRange((NSUInteger)index + 1, 0)];
        });
    }
}

- (void) animateData:(id <TMAttachmentData>)data withAnimation:(void (^)(UIImageView *imageView))animationBlock {
    [_overview animateData:data withAnimation:animationBlock];
}

+ (void) selectTextForInput:(UITextView *)input atRange:(NSRange)range {
    UITextPosition *startPosition = [input positionFromPosition:[input beginningOfDocument]
                                                 offset:range.location];
    UITextPosition *endPosition = [input positionFromPosition:startPosition
                                               offset:range.length];
    [input setSelectedTextRange:[input textRangeFromPosition:startPosition toPosition:endPosition]];
}

- (BOOL) attachmentExistsWithIdentifier:(NSString *)identifier {
    __block BOOL result = NO;

    NSRange limitRange = NSMakeRange(0, [self.attributedText length]);
    [self.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:limitRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSTextAttachment *attachment, NSRange range, BOOL *stop) {
        if (attachment) {
            TMTextAttachment *textAttachment = (TMTextAttachment *) attachment;
            if ([textAttachment.data.identifier isEqualToString:identifier]) {
                result = YES;
                *stop = YES;
            }
        }
    }];

    return result;
}

- (CGRect) frameOfIdentifier:(NSString *)identifier {
    __block CGRect result = CGRectMake(0, 0, 0, 0);

    NSRange limitRange = NSMakeRange(0, [self.attributedText length]);
    [self.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:limitRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSTextAttachment *attachment, NSRange range, BOOL *stop) {
        if (attachment) {
            TMTextAttachment *textAttachment = (TMTextAttachment *) attachment;
            if ([textAttachment.data.identifier isEqualToString:identifier]) {
                result = [self.layoutManager boundingRectForGlyphRange:range inTextContainer:self.textContainer];
                result.origin.x += self.textContainerInset.left;
                result.origin.y += self.textContainerInset.top;

                if (result.size.height > textAttachment.expectedSize.height) {
                    result.origin.y += (result.size.height - textAttachment.expectedSize.height);
                    result.size.height -= (result.size.height - textAttachment.expectedSize.height);
                }
                *stop = YES;
            }
        }
    }];

    return result;
}

- (id <TMAttachmentData>) attachmentDataAtPoint:(CGPoint)point {
    NSTextContainer *textContainer = self.textContainer;
    NSLayoutManager *layoutManager = self.layoutManager;

    point.x -= self.textContainerInset.left;
    point.y -= self.textContainerInset.top;

    NSUInteger characterIndex = [layoutManager characterIndexForPoint:point inTextContainer:textContainer fractionOfDistanceBetweenInsertionPoints:nil];
    if (characterIndex >= self.text.length)
        return nil;

    NSRange range;
    TMTextAttachment *attachment = [self.attributedText attribute:NSAttachmentAttributeName atIndex:characterIndex effectiveRange:&range];

    // The NSLayoutManager characterIndexForPoint:inTextContainer:fractionOfDistanceBetweenInsertionPoints method returns the closest glyph but we want
    // to only select one if it's actually under the point.
    CGRect boundingRect = [layoutManager boundingRectForGlyphRange:range inTextContainer:textContainer];
    if (CGRectContainsPoint(boundingRect, point))
        return attachment.data;

    return nil;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)recognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // If we're touching an attachment then we don't want the normal selection functionality to be done
    CGPoint point = [recognizer locationInView:self];
    id <TMAttachmentData> data = [self attachmentDataAtPoint:point];
    return data == nil;
}

- (void) handleTextViewTapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateFailed) return;

    CGPoint point = [recognizer locationInView:self];
    id <TMAttachmentData> data = [self attachmentDataAtPoint:point];
    if (data) {
        BOOL shouldInteract = YES;
        if (_animatedTextViewDelegate && [_animatedTextViewDelegate respondsToSelector:@selector(shouldInteractWithAttachmentData:)]) {
            shouldInteract = [_animatedTextViewDelegate shouldInteractWithAttachmentData:data];
        }

        if (shouldInteract && _animatedTextViewDelegate && [_animatedTextViewDelegate respondsToSelector:@selector(didInteractWithAttachmentData:)]) {
            [_animatedTextViewDelegate didInteractWithAttachmentData:data];
        }
    }
}

#pragma mark - UITextViewDelegate

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)textRange replacementText:(NSString *)text {
    __block BOOL shouldDelete = YES;

    if (_animatedTextViewDelegate && [_animatedTextViewDelegate respondsToSelector:@selector(shouldDeleteAttachmentData:)]) {
        [textView.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:textRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSTextAttachment *attachment, NSRange range, BOOL *stop) {
            if (attachment && shouldDelete) {
                TMTextAttachment *textAttachment = (TMTextAttachment *) attachment;
                shouldDelete &= [_animatedTextViewDelegate shouldDeleteAttachmentData:textAttachment.data];
            }
        }];
    }

    if (shouldDelete && _animatedTextViewDelegate && [_animatedTextViewDelegate respondsToSelector:@selector(didDeleteAttachmentData:)]) {
        [textView.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:textRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSTextAttachment *attachment, NSRange range, BOOL *stop) {
            if (attachment) {
                TMTextAttachment *textAttachment = (TMTextAttachment *) attachment;
                [_overview unregisterData:textAttachment.data];
                [_animatedTextViewDelegate didDeleteAttachmentData:textAttachment.data];
            }
        }];
    }

    return shouldDelete;
}

- (void) textViewDidChange:(UITextView *)textView {
    [_overview calculateAll];
    if (_animatedTextViewDelegate && [_animatedTextViewDelegate respondsToSelector:@selector(animatedTextViewDidChange:)]) {
        [_animatedTextViewDelegate animatedTextViewDidChange:self];
    }
}

#pragma mark - Pasteboard

- (BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(paste:)) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        if (pasteboard.image != nil)
            return YES;
    }

    return [super canPerformAction:action withSender:sender];
}

- (void) paste:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    UIImage *image = pasteboard.image;
    if (image) {
        if ([_animatedTextViewDelegate respondsToSelector:@selector(pasteImage:)]) {
            [_animatedTextViewDelegate pasteImage:image];
        }
    }
    else
        [super paste:sender];
}

@end
