//
//  Created by Bob Wieler on 4/7/15.
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


#import "ViewController.h"

@interface AttachmentData : NSObject<TMAttachmentData>
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) UIImage *image;
- (instancetype) initWithIdentifier:(NSString *)identifier image:(UIImage *)image;
@end

@implementation AttachmentData {
@private
    NSString *_identifier;
    UIImage *_image;
}
@synthesize identifier = _identifier;
@synthesize image = _image;

- (instancetype) initWithIdentifier:(NSString *)identifier image:(UIImage *)image {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _image = image;
    }

    return self;
}

@end

@implementation ViewController {
@private
    NSUInteger _identifierCounter;
}

- (void) viewDidLoad {
    [super viewDidLoad];

    _identifierCounter = 0;
    [self.textView becomeFirstResponder];
}

- (UIImage *) createImageWithText:(NSString *)text color:(UIColor *)color {
    NSAttributedString *attributedString = [[NSAttributedString alloc]
            initWithString:text
                attributes:@{
                        NSFontAttributeName : [UIFont systemFontOfSize:22],
                        NSForegroundColorAttributeName : [UIColor whiteColor]
                }];
    CGRect textRect = [attributedString boundingRectWithSize:(CGSize) {152, CGFLOAT_MAX}
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                     context:nil];
    CGSize imageSize = CGSizeMake(textRect.size.width + 20, 40);

    CALayer *imageLayer = [CALayer layer];
    imageLayer.bounds = CGRectMake(0, 0, imageSize.width, 40);
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = 10;
    imageLayer.backgroundColor = color.CGColor;

    UILabel *label = [[UILabel alloc] init];
    label.attributedText = attributedString;

    UIGraphicsBeginImageContext(imageSize);

    CGContextRef context = UIGraphicsGetCurrentContext();
    [imageLayer renderInContext:context];

    [label drawTextInRect:CGRectMake(10, 10, textRect.size.width, 20)];

    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    return finalImage;
}

- (UIImage*)scaleImage:(UIImage *)image toSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    CGRect contextRect = CGRectMake(0, 0, size.width, size.height);
    [image drawInRect: contextRect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return scaledImage;
}

- (CGRect) calculateImageBoundsWithImage:(UIImage *)image {
    CGFloat smallestSize;
    CGFloat insetX = 0.0f;
    CGFloat insetY = 0.0f;
    if (image.size.width > image.size.height) {
        smallestSize = image.size.height;
        insetX = image.size.width - smallestSize;
    }
    else {
        smallestSize = image.size.width;
        insetY = image.size.height - smallestSize;
    }

    return CGRectMake(insetX, insetY, smallestSize, smallestSize);
}

- (UIImage *) createCroppedImageWithImage:(UIImage *)image {
    CGRect imageBounds = [self calculateImageBoundsWithImage:image];
    UIGraphicsBeginImageContext(imageBounds.size);
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.0f, 0.0f, imageBounds.size.width, imageBounds.size.height)
                                cornerRadius:imageBounds.size.width / 8.0f] addClip];
    [image drawAtPoint:CGPointMake(-imageBounds.origin.x, -imageBounds.origin.y)];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return finalImage;
}

- (IBAction) addText:(id)sender {
    [self.textView attachData:[[AttachmentData alloc] initWithIdentifier:[NSString stringWithFormat:@"%lu", (unsigned long)_identifierCounter++]
                                                                   image:[self createImageWithText:@"Test" color:[UIColor redColor]]]];
}

- (IBAction) addImage:(id)sender {
    [self.textView attachData:[[AttachmentData alloc] initWithIdentifier:[NSString stringWithFormat:@"%lu", (unsigned long)_identifierCounter++]
                                                                   image:[self scaleImage:[self createCroppedImageWithImage:[UIImage imageNamed:@"MadisonSquarePark.jpg"]]
                                                                                   toSize:CGSizeMake(100.0f, 100.0f)]]];
}

- (void) pasteImage:(UIImage *)image {
    [self.textView attachData:[[AttachmentData alloc] initWithIdentifier:[NSString stringWithFormat:@"%lu", (unsigned long)_identifierCounter++]
                                                                   image:[self scaleImage:[self createCroppedImageWithImage:image] toSize:CGSizeMake(100.0f, 100.0f)]]];
}

- (void) didAddAttachmentData:(id <TMAttachmentData>)data {
    [self.textView animateData:data withAnimation:^(UIImageView *imageView) {
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.duration = 0.1;
        scaleAnimation.repeatCount = 0;
        scaleAnimation.autoreverses = NO;
        scaleAnimation.fromValue = @0.1f;
        scaleAnimation.toValue = @1.0f;
        [imageView.layer addAnimation:scaleAnimation forKey:@"scale"];
    }];
}

- (void) didInteractWithAttachmentData:(id <TMAttachmentData>)data {
    [self.textView animateData:data withAnimation:^(UIImageView *imageView) {
        CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotate.fromValue = @(0.0);
        rotate.toValue = @(M_PI * 2.0);
        rotate.repeatCount = 0;
        rotate.duration = 0.5;
        [imageView.layer addAnimation:rotate forKey:@"rotate"];
    }];
}

@end