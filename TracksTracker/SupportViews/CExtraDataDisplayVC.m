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

	if( (self.imgVwBackGround != nil) && (self.urlBgImg != nil) )
		self.imgVwBackGround.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.urlBgImg]];
	//Otherwise we just leave in the default background image.
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if(self.webView != nil)
	{
		[self.webView setBackgroundColor:[UIColor clearColor]];
		[self.webView setOpaque:NO];
		
		if(self.strHtml == nil)
			[self constructHtmlForInvalidTrack];

		[self.webView loadHTMLString:self.strHtml baseURL:nil];
	}
}

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
}

@end
