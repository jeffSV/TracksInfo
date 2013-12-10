/*
//  CSecondaryTabSegmentVC.m
//  TracksTracker
//
//  Created by Jeff Behrbaum on 12/7/13.
//  Copyright (c) 2013 Jeff Behrbaum. All rights reserved.
*/

#import "CSecondaryTabSegmentVC.h"

@interface CSecondaryTabSegmentVC ()

@property(nonatomic, strong) NSString *strHtml;

-(void)constructHtml;
-(void)displayEMailController;

@end

@implementation CSecondaryTabSegmentVC

@synthesize webView = _webView;
@synthesize strHtml = _strHtml;

-(void)viewDidLoad
{
	[super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
	if(self.webView != nil)
	{
		[self.webView setBackgroundColor:[UIColor clearColor]];
		[self.webView setOpaque:NO];

		[self constructHtml];

		[self.webView loadHTMLString:self.strHtml baseURL:nil];
	}
}

//Open Web Browser app when link is clicked
-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
	if ( inType == UIWebViewNavigationTypeLinkClicked )
	{
		//See if it's the webpage request or the email
		if([[[inRequest.URL absoluteString] lowercaseString] rangeOfString:@"sejavoo"].location != NSNotFound)
		{
			[[UIApplication sharedApplication] openURL:[inRequest URL]];
			return NO;
		}
		else
		{
			if([MFMailComposeViewController canSendMail] == TRUE)
				[self displayEMailController];
		}
	}

	return YES;
}

-(void)displayEMailController
{
	MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
	mailVC.mailComposeDelegate = self;
	
	[mailVC setSubject:@"Ref. Tracks App."];
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"jeff1172@gmail.com"];
	
	[mailVC setToRecipients:toRecipients];

	//Fill out the email body text
	NSString *emailBody = @"Contact From Tracks App. User";
	[mailVC setMessageBody:emailBody isHTML:NO];

	[self presentViewController:mailVC animated:TRUE completion:nil];
}

-(void)constructHtml
{
	NSMutableString *strHtmlConstruct = [[NSMutableString alloc]init];
	
	[strHtmlConstruct appendString:@"<html><head><title>Developer Info</title></head><body>"];//Open web page
	
	[strHtmlConstruct appendString:@"<center><h1>Jeff Behrbaum</h1></center>"];
	[strHtmlConstruct appendString:@"<center><h1>(202) 492-6369</h1></center>"];
	[strHtmlConstruct appendString:@"<center><a href=\"#Contact\">jeff1172@gmail.com</a></center><hr />"];
	
	[strHtmlConstruct appendString:@"<center><a href=\"http://www.sejavoo.com\">Home Page</a></center>"];

	[strHtmlConstruct appendString:@"</body></html>"];//Close web page
	
	self.strHtml = strHtmlConstruct;
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	NSString *strMsg = nil;
	
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			strMsg = @"EMail: canceled";
			break;
		case MFMailComposeResultSaved:
			strMsg = @"EMail: saved";
			break;
		case MFMailComposeResultSent:
			strMsg = @"EMail: sent";
			break;
		case MFMailComposeResultFailed:
			strMsg = @"EMail: failed";
			break;
		default:
			strMsg = @"EMail: not sent";
			break;
	}

	[self dismissViewControllerAnimated:TRUE completion:nil];

	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:strMsg message:@"Thank you for contacting me and for looking at this app. I hope you liked it." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

	[alert show];
}//End


@end