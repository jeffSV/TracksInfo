/*
//  CExtraDataDisplayVC.h
//  TracksTracker
//
//  Created by Jeff Behrbaum on 12/7/13.
//  Copyright (c) 2013 Jeff Behrbaum. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class DBTrack;

@interface CExtraDataDisplayVC : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIImageView *imgVwBackGround;

-(BOOL)configureHtmlFromTrack:(DBTrack *)track;

@end