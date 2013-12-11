/*
//  CExtraDataDisplayVC.m
//  TracksTracker
//
//  Created by Jeff Behrbaum on 12/7/13.
//  Copyright (c) 2013 Jeff Behrbaum. All rights reserved.
*/

#import "CExtraDataDisplayVC.h"
#import "DBTrack.h"

@interface CExtraDataDisplayVC ()
	@property(nonatomic, strong) NSURL *urlBgImg;
	@property(nonatomic, strong) NSString *strHtml;

	-(void)displayPage;
	-(void)displayImage;
	-(void)doIPadDisplaySequence;
	-(void)constructHtmlForInvalidTrack;
@end

@implementation CExtraDataDisplayVC

@synthesize strHtml = _strHtml;
@synthesize webView = _webView;
@synthesize urlBgImg = _urlBgImg;
@synthesize imgVwBackGround = _imgVwBackGround;

-(void)viewDidLoad
{
   [super viewDidLoad];

	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
		[self displayImage];//On the iPhone/iPod, since we're seguing, get the track's image started displaying as early as possible.
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[self.webView setBackgroundColor:[UIColor clearColor]];
	[self.webView setOpaque:NO];

	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
		[self displayPage];
}

-(void)displayImage
{
	if( (self.imgVwBackGround != nil) && (self.urlBgImg != nil) )
		self.imgVwBackGround.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.urlBgImg]];

	//Otherwise we just leave in the default background image.
}//End

-(void)displayPage
{
	if(self.webView != nil)
	{
		if(self.strHtml == nil)
			[self constructHtmlForInvalidTrack];
		
		[self.webView loadHTMLString:self.strHtml baseURL:nil];
	}
}//End

-(BOOL)configureHtmlFromTrack:(DBTrack *)track
{
	if (track == nil)
	{
		[self constructHtmlForInvalidTrack];
		return FALSE;
	}

	self.urlBgImg = [NSURL URLWithString:track.artUrl512x512];
	
	NSMutableString *strHtmlConstruct = [[NSMutableString alloc]init];

	[strHtmlConstruct appendFormat:@"<html><head><title>Track Info.</title></head><body text=\"#%@\">", track.displayColor];//Open web page
	
	[strHtmlConstruct appendFormat:@"<p><h1>Name: %@<h5>Ver: %@ ID: %ld</h5></p>", track.trkName, track.trkVersion, [track.trkID integerValue]];

	[strHtmlConstruct appendFormat:@"<h2>by: %@</h2><h4>$%0.2f</h4><hr />", track.artistName, [track.price floatValue]];
	[strHtmlConstruct appendFormat:@"<p>%@</p>", track.trkDescription];
	
	[strHtmlConstruct appendString:@"</body></html>"];//Close web page

	self.strHtml = strHtmlConstruct;
	
	[self doIPadDisplaySequence];

	return TRUE;
}

-(void)constructHtmlForInvalidTrack
{
	self.urlBgImg = nil;

	NSMutableString *strHtmlConstruct = [[NSMutableString alloc]init];
	
	[strHtmlConstruct appendString:@"<html><head><title>Invalid Track Info.</title></head><body>"];//Open web page
	
	[strHtmlConstruct appendString:@"<p><h1>Unknown Track</h1><h5>Ver: 0 ID: 0</h5></p>"];
	
	[strHtmlConstruct appendString:@"<h2>by: Unknown Artist</h2><h4>$0.0</h4><hr />"];
	[strHtmlConstruct appendString:@"<p>No Description</p>"];
	
	[strHtmlConstruct appendString:@"</body></html>"];//Close web page
	
	self.strHtml = strHtmlConstruct;

	[self doIPadDisplaySequence];
}

-(void)doIPadDisplaySequence
{
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		[self displayImage];
		[self displayPage];
	}//End

}//End

@end
