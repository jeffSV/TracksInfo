/*
//  CSecondaryTabSegmentVC.h
//  TracksTracker
//
//  Created by Jeff Behrbaum on 12/7/13.
//  Copyright (c) 2013 Jeff Behrbaum. All rights reserved.
*/

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface CSecondaryTabSegmentVC : UIViewController<MFMailComposeViewControllerDelegate>

	@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
