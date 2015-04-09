//
//  Created by Bob Wieler on 4/7/15.
//  Copyright (c) 2015 TapMesh. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "TMAnimatedTextView.h"

@class TMAnimatedTextView;

@interface ViewController : UIViewController<TMAnimatedTextViewDelegate>

@property (nonatomic, weak) IBOutlet TMAnimatedTextView *textView;

- (IBAction) addText:(id)sender;
- (IBAction) addImage:(id)sender;

@end
